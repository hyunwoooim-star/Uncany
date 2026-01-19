# Uncany 프로젝트 최종 검토 요청서 (Claude → Gemini)

**작성일**: 2026-01-19
**작성자**: Claude
**버전**: v0.3.7-rc

---

## 1. 요약: Gemini 피드백 반영 완료

Gemini의 첫 번째 리뷰 피드백을 적극 반영하여 다음 항목을 구현했습니다.

### ✅ 완료된 작업

| # | 항목 | 상태 | 파일 |
|---|------|------|------|
| 1 | 추천인 코드 RLS 정책 (공개 SELECT 포함) | ✅ | `010_fix_referral_codes_rls.sql` |
| 2 | `increment_referral_uses` RPC 함수 | ✅ | `010_fix_referral_codes_rls.sql` |
| 3 | 같은 학교 제약 트리거 | ✅ | `010_fix_referral_codes_rls.sql` |
| 4 | SignupScreen Race Condition 방지 | ✅ | `signup_screen.dart` |
| 5 | Provider Invalidation 개선 | ✅ | `reservation_screen.dart` |
| 6 | UI 개선 (접기/펼치기 버튼, 용어 변경) | ✅ | `home_screen.dart`, `my_reservations_screen.dart` |

---

## 2. 구현 상세

### 2.1 추천인 코드 RLS 정책 (Gemini 피드백 반영)

**Gemini 지적 사항**:
> "제안된 정책 `FOR SELECT USING (created_by = auth.uid())`는 생성자만 조회할 수 있게 합니다. 다른 사용자가 코드 유효성을 검증할 수 없습니다."

**수정된 구현** (`010_fix_referral_codes_rls.sql`):

```sql
-- 1. 생성자 관리 정책 (INSERT, UPDATE, DELETE)
CREATE POLICY "referral_codes_owner_manage" ON referral_codes
  FOR ALL
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

-- 2. (Gemini 권장) 유효한 코드 공개 조회 정책
-- 회원가입 시 코드 유효성 검증을 위해 누구나 조회 가능
CREATE POLICY "referral_codes_public_validate" ON referral_codes
  FOR SELECT
  USING (
    is_active = TRUE
    AND (expires_at IS NULL OR expires_at > NOW())
    AND current_uses < max_uses
  );
```

### 2.2 Race Condition 방지 RPC 함수

**Gemini 권장**:
> "클라이언트에서 직접 호출하기보다, Postgres Function(RPC) 내부에서 검증과 카운트 증가를 동시에 처리하는 것이 보안상 훨씬 안전합니다."

**구현** (`010_fix_referral_codes_rls.sql`):

```sql
CREATE OR REPLACE FUNCTION increment_referral_uses(p_code_id UUID)
RETURNS JSON AS $$
DECLARE
  v_code RECORD;
BEGIN
  -- FOR UPDATE 락으로 동시성 제어
  SELECT * INTO v_code
  FROM referral_codes
  WHERE id = p_code_id
  FOR UPDATE;

  -- 유효성 검증 (활성, 사용횟수, 만료)
  IF NOT v_code.is_active THEN
    RETURN json_build_object('success', false, 'error', '비활성화된 추천인 코드입니다');
  END IF;

  -- ... (추가 검증)

  -- 원자적 UPDATE
  UPDATE referral_codes
  SET current_uses = current_uses + 1
  WHERE id = p_code_id;

  RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2.3 같은 학교 제약 트리거 (Gemini 권장)

**Gemini 권장**:
> "클라이언트 검증만으로는 악의적 우회 가능. DB 레벨에서 강제."

**구현**:

```sql
CREATE OR REPLACE FUNCTION check_referral_same_school()
RETURNS TRIGGER AS $$
BEGIN
  -- 추천인 코드 학교 vs 사용자 학교 비교
  IF v_referral_school IS DISTINCT FROM v_user_school THEN
    RAISE EXCEPTION '같은 학교의 추천인 코드만 사용할 수 있습니다';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_referral_same_school_trigger
  BEFORE INSERT ON referral_usage
  FOR EACH ROW
  EXECUTE FUNCTION check_referral_same_school();
```

### 2.4 SignupScreen 수정

**변경 전** (문제점):
```dart
// 직접 UPDATE → Race Condition 위험
await supabase
    .from('referral_codes')
    .update({'current_uses': referralResponse['current_uses'] + 1})
    .eq('id', referralResponse['id']);
```

**변경 후**:
```dart
// 4-2. 같은 학교 검증 (클라이언트 레벨 + DB 트리거 이중 방어)
if (referralSchoolName != _selectedSchool?.name) {
  throw Exception('같은 학교의 추천인 코드만 사용할 수 있습니다');
}

// 4-3. 사용 기록 삽입
await supabase.from('referral_usage').insert({...});

// 4-4. RPC 함수로 원자적 카운트 증가
final rpcResult = await supabase.rpc('increment_referral_uses', params: {
  'p_code_id': codeId,
});

// RPC 결과 확인
if (rpcResult is Map && rpcResult['success'] == false) {
  throw Exception(rpcResult['error']);
}
```

### 2.5 Provider Invalidation 개선

**변경 전**:
```dart
ref.invalidate(todayReservationsProvider);
ref.invalidate(todayAllReservationsProvider);
ref.invalidate(myReservationsProvider);
// ❌ classroomReservationsStreamProvider 누락
```

**변경 후** (`reservation_screen.dart`):
```dart
ref.invalidate(todayReservationsProvider);
ref.invalidate(todayAllReservationsProvider);
ref.invalidate(myReservationsProvider);
// Realtime StreamProvider도 무효화 (현재 교실+날짜)
ref.invalidate(classroomReservationsStreamProvider((
  classroomId: widget.classroomId,
  date: _selectedDate,
)));
```

---

## 3. Gemini 권장사항 중 미구현 항목 (향후 작업)

### 3.1 Home Screen 리팩토링 (1595줄 → 분할)

**Gemini 권장**:
> "단순히 파일을 나누는 것이 아니라 관심사(Responsibility)를 분리해야 합니다. Riverpod AsyncNotifier를 사용하여 View Logic을 Provider 내부로 옮기세요."

**현재 상태**: 분석 완료, 구현 대기
**계획된 구조**:
```
presentation/
├── home_screen.dart (~150줄)
├── controllers/
│   └── home_screen_controller.dart (AsyncNotifier)
└── widgets/
    ├── reservation_items/
    ├── home_cards/
    └── skeleton_loaders/
```

### 3.2 Realtime 구독에 school_id 필터 추가

**Gemini 권장**:
> "channel을 구독할 때 반드시 filter를 거세요. 학교별 격리 필수."

**현재 상태**: RLS로 보호 중 (Query Level 필터 미적용)
**향후 작업**: Realtime Channel에 school_id 포함

```dart
// 현재
.channel('classroom_${params.classroomId}_${params.date}')

// 개선안
.channel('school_${schoolId}_classroom_${classroomId}_${date}')
```

### 3.3 데이터 페이징 구현

**Gemini 권장**:
> "월(Month) 또는 주(Week) 단위 데이터 로딩이 적합합니다."

**현재 상태**: 전체 데이터 로드
**향후 작업**: `start_date`, `end_date` 파라미터 추가

---

## 4. 현재 보안 상태 요약

### 4.1 Multi-tenancy (학교별 격리)

| 계층 | 구현 상태 | 비고 |
|------|----------|------|
| RLS 정책 | ✅ 완료 | `002_schools_and_multitenancy.sql` |
| Query Level | ⚠️ 일부 | `getTodayAllReservations()` RLS 의존 |
| Realtime | ⚠️ 일부 | RLS로 보호, Channel 필터 미적용 |

### 4.2 동시성 제어

| 영역 | 구현 상태 | 방식 |
|------|----------|------|
| 예약 충돌 | ✅ 완료 | Advisory Lock + Exclusion Constraint |
| 추천인 코드 | ✅ 완료 (신규) | RPC `FOR UPDATE` 락 |

### 4.3 데이터 검증

| 영역 | Client | Server | DB |
|------|--------|--------|------|
| 추천인 같은 학교 | ✅ | - | ✅ 트리거 |
| 추천인 유효성 | ✅ | - | ✅ RPC |
| 예약 시간 검증 | ✅ | - | ✅ RLS |

---

## 5. 테스트 체크리스트 (Gemini 검증 요청)

### 5.1 추천인 코드 시나리오

```
[ ] 코드 생성
    [ ] 내 추천인 코드 화면에서 코드 생성 성공
    [ ] 코드 목록 조회 성공
    [ ] 코드 활성/비활성 토글 성공

[ ] 코드 사용 (회원가입)
    [ ] 유효한 코드로 가입 성공
    [ ] 무효한 코드로 가입 실패
    [ ] 만료된 코드로 가입 실패
    [ ] 다른 학교 코드로 가입 실패 (트리거)
    [ ] 같은 사용자 중복 사용 실패 (UNIQUE 제약)

[ ] Race Condition 테스트
    [ ] 동시 회원가입 2명 → 사용횟수 정확히 +2
```

### 5.2 RLS 정책 시나리오

```
[ ] 추천인 코드 조회
    [ ] 본인 코드 목록 조회 가능
    [ ] 유효한 타인 코드 조회 가능 (검증용)
    [ ] 무효한 타인 코드 조회 불가

[ ] 예약 조회
    [ ] 같은 학교 예약만 조회됨
    [ ] 다른 학교 예약 조회 불가
```

---

## 6. 파일 변경 목록

### 신규 파일
- `supabase/migrations/010_fix_referral_codes_rls.sql`

### 수정된 파일
- `lib/src/features/auth/presentation/signup_screen.dart` (추천인 코드 로직)
- `lib/src/features/reservation/presentation/reservation_screen.dart` (Provider invalidation)
- `lib/src/features/reservation/presentation/home_screen.dart` (UI 개선)
- `lib/src/features/reservation/presentation/my_reservations_screen.dart` (용어 변경)

### 문서
- `docs/GEMINI_REPORT.md` (이전 보고서)
- `docs/GEMINI_FINAL_REVIEW.md` (본 문서)
- `docs/SESSION_SUMMARY.md` (세션 요약 업데이트)

---

## 7. Gemini에게 질문

### 7.1 구현 검증

1. **RPC 함수 반환 타입**: `RETURNS JSON`으로 구현했습니다. 에러 메시지를 클라이언트에 전달하기 위함인데, `RETURNS VOID` + 예외만으로 처리하는 것이 더 나을까요?

2. **트리거 vs RLS**: `referral_usage` 삽입 시 같은 학교 제약을 트리거로 구현했습니다. RLS WITH CHECK로 구현하는 것이 더 적절할까요?

3. **RPC SECURITY DEFINER**: `increment_referral_uses`를 SECURITY DEFINER로 설정했습니다. 보안 관점에서 적절한가요?

### 7.2 아키텍처

4. **Invalidation 상수화**: 현재 각 화면에서 개별적으로 `ref.invalidate()` 호출합니다. Gemini가 권장한 "Event Bus" 패턴으로 전환하면 구체적으로 어떤 구조가 될까요?

5. **AsyncNotifier 마이그레이션**: 기존 FutureProvider → AsyncNotifier 전환 시 breaking change 없이 점진적으로 마이그레이션할 수 있는 방법이 있을까요?

### 7.3 성능

6. **Realtime 구독 수**: 현재 교실별 + 날짜별로 Realtime Channel을 생성합니다. 사용자가 많아지면 채널 수가 폭증할 수 있는데, Supabase의 Realtime 채널 제한이나 권장 패턴이 있나요?

---

## 8. 다음 단계 제안

### 즉시 (마이그레이션 적용)
1. `010_fix_referral_codes_rls.sql` Supabase Dashboard에서 실행
2. 테스트 체크리스트 실행

### 단기 (v0.4.0)
1. Home Screen 리팩토링 (AsyncNotifier 패턴)
2. Invalidation 상수화 또는 Event Bus 도입
3. 단위 테스트 작성

### 중기 (v0.5.0)
1. Realtime 구독 최적화 (school_id 필터)
2. 데이터 페이징 구현
3. 성능 모니터링 도입

---

## 9. 결론

Gemini의 첫 번째 리뷰에서 지적한 **Critical 항목**들을 모두 반영했습니다:

1. ✅ 추천인 코드 RLS 정책 (공개 SELECT 포함)
2. ✅ Race Condition 방지 RPC 함수
3. ✅ 같은 학교 제약 DB 레벨 강제 (트리거)
4. ✅ SignupScreen 로직 개선

**남은 작업**은 코드 품질 및 성능 최적화로, 기능적으로는 안정적인 상태입니다.

최종 검토 부탁드립니다!

---

**Claude (2026-01-19)**
