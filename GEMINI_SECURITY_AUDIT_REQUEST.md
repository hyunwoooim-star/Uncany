# 🔐 Uncany 프로젝트 보안 감사 요청서

**작성일**: 2026-01-13
**프로젝트**: Uncany - 학교 커뮤니티 플랫폼 (교사용 리소스 예약 시스템)
**플랫폼**: Flutter Web + Supabase (PostgreSQL)
**목적**: 프로덕션 배포 전 최종 보안 검증 및 코드 품질 확인

---

## 📋 감사 요청 배경

시니어 개발자로부터 다음과 같은 **치명적인 보안 취약점**을 지적받았습니다:

1. ❌ **RLS 정책 오류**: 타인의 예약을 삭제/수정할 수 있음
2. ❌ **Race Condition**: 동시 예약 시 중복 데이터 삽입
3. ❌ **API 키 노출**: 클라이언트 코드에 나이스 API 키 하드코딩
4. ❌ **성능 문제**: 이미지 압축 시 UI 프리즈
5. ❌ **안티 패턴**: Riverpod를 쓰면서도 setState 남발

**모든 문제를 수정했다고 판단하지만**, Gemini의 전문적인 검증이 필요합니다.

---

## 🎯 검증 요청 사항

### 1. 보안 감사 (최우선)

**RLS(Row Level Security) 정책 검증**
- `supabase/migrations/004_production_ready_security.sql` 파일 전체 검토
- SELECT/INSERT/UPDATE/DELETE 정책이 올바르게 분리되었는지
- `auth.uid()` 기반 본인 확인이 우회 가능한지
- `users.role` 변경 차단이 완벽한지

**동시성 제어 검증**
- `check_and_prevent_reservation_conflict()` 함수의 락 메커니즘
- `FOR UPDATE` 락이 제대로 작동하는지
- 트랜잭션 격리 수준이 적절한지
- 데드락 가능성은 없는지

**API 키 보안**
- Edge Function 구조가 안전한지
- 환경 변수 관리 방식이 적절한지
- CORS 설정에 취약점은 없는지

---

### 2. 코드 품질 검토

**Riverpod 아키텍처**
- `reservation_state_provider.dart`의 Notifier 패턴
- AsyncValue 사용 방식이 올바른지
- Provider 의존성 관리가 적절한지

**성능 최적화**
- `image_compressor_v2.dart`의 compute() 사용
- DB 인덱스 전략의 효율성
- 쿼리 최적화 여부

---

### 3. 프로덕션 준비도

**배포 전 위험 요소 식별**
- 빠뜨린 보안 설정은 없는지
- 롤백 계획이 충분한지
- 모니터링 전략이 있는지

---

## 📂 검토 대상 파일

### 🚨 Critical (필수 검토)

#### 1. `supabase/migrations/004_production_ready_security.sql` (전체)

**핵심 코드 발췌**:

```sql
-- RLS 정책: 본인 예약만 수정/삭제
CREATE POLICY "reservations_update_own" ON reservations
  FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND teacher_id = auth.uid()
    AND deleted_at IS NULL
  )
  WITH CHECK (teacher_id = auth.uid());

-- Race Condition 방지 함수
CREATE OR REPLACE FUNCTION check_and_prevent_reservation_conflict()
RETURNS TRIGGER AS $$
DECLARE
  conflict_count INTEGER;
BEGIN
  -- ⚠️ FOR UPDATE 락
  SELECT COUNT(*)
  INTO conflict_count
  FROM reservations
  WHERE classroom_id = NEW.classroom_id
    AND DATE(start_time) = DATE(NEW.start_time)
    AND deleted_at IS NULL
    AND periods && NEW.periods
  FOR UPDATE;

  IF conflict_count > 0 THEN
    RAISE EXCEPTION '이미 예약된 교시가 포함되어 있습니다';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- users 테이블 UPDATE 정책 (role 변경 차단)
CREATE POLICY "users_update_own" ON users
  FOR UPDATE
  USING (auth.role() = 'authenticated' AND id = auth.uid())
  WITH CHECK (
    id = auth.uid()
    AND (role = (SELECT role FROM users WHERE id = auth.uid()))
  );
```

**질문**:
1. `FOR UPDATE` 락이 제대로 작동하나요? 데드락 가능성은?
2. `WITH CHECK` 절에서 `role` 변경을 완벽히 차단하나요?
3. `periods && NEW.periods` (배열 겹침 체크)가 빠르게 작동하나요?
4. 트리거가 성능에 미치는 영향은 얼마나 되나요?

---

#### 2. `lib/src/features/reservation/presentation/providers/reservation_state_provider.dart`

**핵심 코드**:

```dart
@riverpod
class ReservationScreenNotifier extends _$ReservationScreenNotifier {
  String? _classroomId;

  @override
  Future<ReservationState> build({required String classroomId}) async {
    _classroomId = classroomId;
    final today = DateTime.now();
    final reservedMap = await _loadReservations(today);

    return ReservationState(
      reservedPeriods: reservedMap,
      selectedPeriods: {},
      selectedDate: today,
    );
  }

  Future<void> selectDate(DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final reservedMap = await _loadReservations(date);
      final current = await future;
      return current.copyWith(
        selectedDate: date,
        reservedPeriods: reservedMap,
        selectedPeriods: {},
      );
    });
  }

  Future<void> createReservation() async {
    final current = state.value;
    if (current == null || current.selectedPeriods.isEmpty) {
      throw Exception('교시를 선택해주세요');
    }

    final repository = ref.read(reservationRepositoryProvider);
    await repository.createReservation(
      classroomId: _classroomId!,
      date: current.selectedDate,
      periods: current.selectedPeriods.toList(),
    );

    await selectDate(current.selectedDate);
  }
}
```

**질문**:
1. `AsyncValue.guard()` 사용이 올바른가요?
2. `state.value`가 null인 경우 예외 처리가 적절한가요?
3. `_classroomId`를 인스턴스 변수로 저장하는 게 안전한가요?
4. 메모리 누수 가능성은 없나요?

---

#### 3. `supabase/functions/neis-api/index.ts`

**핵심 코드**:

```typescript
const NEIS_API_KEY = Deno.env.get('NEIS_API_KEY');

serve(async (req: Request) => {
  // 인증 확인
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return createResponse({ error: '인증이 필요합니다' }, { status: 401 });
  }

  // API 키 확인
  if (!NEIS_API_KEY) {
    console.error('NEIS_API_KEY가 설정되지 않았습니다');
    return createResponse({ error: '서버 설정 오류' }, { status: 500 });
  }

  const url = new URL(req.url);
  const action = url.searchParams.get('action');

  switch (action) {
    case 'search_schools':
      return await handleSchoolSearch(url.searchParams);
    case 'get_school_info':
      return await handleSchoolInfo(url.searchParams);
    default:
      return createResponse({ error: '지원하지 않는 액션입니다' }, { status: 400 });
  }
});

async function handleSchoolSearch(params: URLSearchParams) {
  const query = params.get('query');
  if (!query || query.length < 2) {
    return createResponse({ error: '검색어는 2자 이상이어야 합니다' }, { status: 400 });
  }

  const apiUrl = new URL(`${NEIS_BASE_URL}/schoolInfo`);
  apiUrl.searchParams.set('KEY', NEIS_API_KEY!);
  apiUrl.searchParams.set('Type', 'json');
  apiUrl.searchParams.set('SCHUL_NM', query);

  const response = await fetch(apiUrl.toString());
  const data = await response.json();

  const schools = data?.schoolInfo?.[1]?.row || [];
  const transformedSchools = schools.map((school: any) => ({
    schoolId: school.SD_SCHUL_CODE,
    name: school.SCHUL_NM,
    address: school.ORG_RDNMA,
  }));

  return createResponse({ schools: transformedSchools });
}
```

**질문**:
1. Authorization 헤더만 확인하는 게 충분한가요? JWT 토큰 검증이 필요하지 않나요?
2. SQL Injection 같은 공격이 가능한가요?
3. Rate Limiting이 필요하지 않나요?
4. 에러 로그에 민감한 정보가 노출되지 않나요?

---

#### 4. `lib/src/core/utils/image_compressor_v2.dart`

**핵심 코드**:

```dart
static Future<Uint8List> compressToWebP(Uint8List imageBytes) async {
  if (kIsWeb) {
    // Web: Isolate 미지원, 메인 스레드 실행
    return _compressImageSync(imageBytes);
  } else {
    // 모바일: compute()로 별도 Isolate 실행
    return await compute(_compressImageSync, _CompressionParams(...));
  }
}

static Uint8List _compressImageSync(dynamic params) {
  Uint8List imageBytes;
  int maxWidth = 1920;
  int maxHeight = 1920;
  int quality = 85;

  if (params is _CompressionParams) {
    imageBytes = params.imageBytes;
    maxWidth = params.maxWidth;
    maxHeight = params.maxHeight;
    quality = params.quality;
  } else {
    imageBytes = params as Uint8List;
  }

  try {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('이미지 디코딩 실패');

    img.Image resized = image;
    if (image.width > maxWidth || image.height > maxHeight) {
      final aspectRatio = image.width / image.height;
      int targetWidth = image.width;
      int targetHeight = image.height;

      if (aspectRatio > 1) {
        targetWidth = maxWidth;
        targetHeight = (maxWidth / aspectRatio).round();
      } else {
        targetHeight = maxHeight;
        targetWidth = (maxHeight * aspectRatio).round();
      }

      resized = img.copyResize(image, width: targetWidth, height: targetHeight);
    }

    final webpBytes = img.encodeWebP(resized, quality: quality);
    return Uint8List.fromList(webpBytes);
  } catch (e) {
    return imageBytes; // fallback
  }
}
```

**질문**:
1. Web 환경에서 메인 스레드 실행이 불가피한가요? 대안은 없나요?
2. `params as Uint8List` 캐스팅이 안전한가요?
3. 이미지 디코딩 실패 시 원본을 반환하는 게 올바른가요?
4. 메모리 사용량이 폭증할 위험은 없나요?

---

## 🔍 구체적인 검증 항목

### A. 보안 취약점 점검

- [ ] **SQL Injection**: RLS 정책에서 우회 가능한 구멍은 없는지
- [ ] **IDOR(Insecure Direct Object Reference)**: UUID 추측으로 타인 데이터 접근 가능한지
- [ ] **XSS(Cross-Site Scripting)**: 사용자 입력값 검증이 충분한지
- [ ] **CSRF(Cross-Site Request Forgery)**: Supabase Auth로 충분히 방어되는지
- [ ] **권한 상승**: 일반 사용자가 admin으로 권한 변경 가능한지
- [ ] **민감 정보 노출**: 로그나 에러 메시지에 API 키, 비밀번호 등이 포함되는지

### B. 동시성 및 무결성

- [ ] **Race Condition**: 정말 100% 방지되는지 (2명이 정확히 동시에 클릭)
- [ ] **데드락**: FOR UPDATE 락이 서로를 기다리는 상황은 없는지
- [ ] **트랜잭션 격리**: READ COMMITTED 수준이 적절한지
- [ ] **Optimistic Locking**: version 컬럼이 필요하지 않은지

### C. 성능 및 확장성

- [ ] **N+1 쿼리**: 예약 목록 조회 시 불필요한 반복 쿼리는 없는지
- [ ] **인덱스 효율**: GIN 인덱스가 실제로 사용되는지 (EXPLAIN ANALYZE)
- [ ] **메모리 누수**: Provider나 Notifier에서 dispose 누락은 없는지
- [ ] **이미지 압축**: 10MB 이미지도 문제없이 처리되는지

### D. 에러 처리 및 사용자 경험

- [ ] **에러 메시지**: 사용자에게 기술적 내용이 노출되는지
- [ ] **Fallback**: 네트워크 끊김 시 앱이 크래시하지 않는지
- [ ] **로딩 상태**: AsyncValue.loading이 적절히 표시되는지
- [ ] **입력 검증**: 클라이언트와 서버 양쪽에서 검증하는지

---

## 📊 수정 전/후 비교 (참고)

| 항목 | 수정 전 | 수정 후 |
|------|---------|---------|
| **RLS 정책** | `FOR ALL` (보안 취약) | SELECT/INSERT/UPDATE/DELETE 분리 ✅ |
| **동시성** | 조회 후 저장 (Race Condition) | FOR UPDATE 락 + 트리거 ✅ |
| **상태 관리** | setState 지옥 | AsyncValue 패턴 ✅ |
| **API 키** | 클라이언트 노출 | Edge Function 숨김 ✅ |
| **이미지 압축** | 메인 스레드 (UI 프리즈) | compute() 비동기 ✅ |
| **periods 컬럼** | 없음 (DB 오류) | INTEGER[] 추가 ✅ |

---

## 🎯 검증 결과 기대 사항

### 통과 기준
- **보안**: Critical/High 취약점 0개
- **성능**: 동시 접속 100명 이상 처리 가능
- **코드 품질**: Lint 경고 0개, 테스트 커버리지 60% 이상 (이상적)

### 개선 제안 환영
- 더 나은 아키텍처 패턴
- 성능 최적화 방법
- 추가 보안 강화 방안
- 프로덕션 운영 팁

---

## 📝 특별 요청 사항

### 1. 비판적 시각 필수
- "잘했어요" 보다 **"여기가 위험해요"** 중심으로 검토
- 작은 실수도 놓치지 말고 지적
- 프로덕션에서 발생 가능한 최악의 시나리오 제시

### 2. 구체적인 코드 예시
- 추상적인 조언보다 **실제 수정 코드** 제시
- "보안 강화 필요" → "이 쿼리를 이렇게 수정하세요"

### 3. 우선순위 명확화
- Critical (즉시 수정) / High (배포 전 필수) / Medium (개선 권장) / Low (선택)

### 4. 한국 법규 준수
- 개인정보보호법 위반 여부
- 파일명 익명화가 충분한지
- EXIF 데이터 제거가 되는지

---

## 🔗 참고 자료

### 프로젝트 정보
- **GitHub**: https://github.com/hyunwoooim-star/Uncany (브랜치: `musing-thompson`)
- **기술 스택**: Flutter 3.24+ / Supabase / Riverpod 2.5+ / Freezed
- **목표 사용자**: 한국 교사 (약 50만명 규모)
- **배포 예정일**: 2026년 2월 중순

### 관련 문서
- `docs/CODE_REVIEW_FIXES.md` - 수정 사항 상세 설명
- `GEMINI_CODE_REVIEW_REQUEST.md` - 이전 검토 요청서
- `SESSION_SUMMARY.md` - 개발 이력

### 기술 참고
- [Supabase RLS](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL FOR UPDATE](https://www.postgresql.org/docs/current/sql-select.html#SQL-FOR-UPDATE-SHARE)
- [Riverpod AsyncNotifier](https://riverpod.dev/docs/concepts/providers#asyncnotifier)
- [Flutter compute()](https://api.flutter.dev/flutter/foundation/compute-constant.html)

---

## 💡 검토 요청 핵심 질문

1. **RLS 정책이 완벽한가요?** 타인의 예약을 수정/삭제할 수 있는 구멍이 정말 없나요?

2. **Race Condition이 100% 방지되나요?** 2명이 나노초 단위로 동시에 클릭해도 안전한가요?

3. **Edge Function이 안전한가요?** API 키가 정말 노출될 방법이 없나요?

4. **성능이 프로덕션급인가요?** 1만명이 동시 접속해도 버틸 수 있나요?

5. **빠뜨린 게 있나요?** 제가 생각하지 못한 위험 요소는 무엇인가요?

---

## 🙏 검토 부탁드립니다

**Gemini님께**:

이 프로젝트는 한국 교사 50만명이 사용할 수 있는 서비스입니다.
작은 보안 실수가 대형 사고로 이어질 수 있습니다.

**가혹할 정도로 엄격하게** 검토해 주세요.
"이 정도면 괜찮다"가 아니라 **"이건 위험하다"**를 찾아주세요.

특히:
- 개인정보 유출 가능성
- 악의적 공격 시나리오
- 프로덕션 장애 가능성

이 세 가지를 중점적으로 검토해 주시면 감사하겠습니다.

---

**작성자**: Claude Sonnet 4.5 + 임현우
**검토 요청일**: 2026-01-13
**긴급도**: ⭐️⭐️⭐️⭐️⭐️ (최고)

감사합니다! 🙏
