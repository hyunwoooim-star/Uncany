# Uncany 프로젝트 분석 보고서 (Gemini 리뷰용)

**작성일**: 2026-01-19
**작성자**: Claude
**버전**: v0.3.6

---

## 1. 프로젝트 개요

### 1.1 앱 설명
- **이름**: Uncany (언캐니)
- **목적**: 학교 교실 예약 시스템 (교사용)
- **플랫폼**: Flutter Web (PWA)
- **백엔드**: Supabase (PostgreSQL + Auth + Storage + Edge Functions)
- **상태**: Staging 테스트 진행 중

### 1.2 핵심 기능
- 교시 기반 교실 예약 (1~7교시)
- 종합 시간표 대시보드 (모든 교실 × 교시 그리드)
- 사용자 인증 및 관리자 승인 시스템
- 학교별 격리 (Multi-tenancy)
- 추천인 코드 시스템

### 1.3 기술 스택
```
Frontend: Flutter 3.32.0 (Dart 3.7.0)
State Management: Riverpod
Backend: Supabase (PostgreSQL 15)
Authentication: Supabase Auth (PKCE Flow)
Deployment: Firebase Hosting (Web)
CI/CD: GitHub Actions
```

---

## 2. 현재 구조 분석

### 2.1 디렉토리 구조
```
lib/src/
├── core/                     # 핵심 인프라
│   ├── config/              # 환경 설정
│   ├── constants/           # 상수
│   ├── extensions/          # Dart 확장 메서드
│   ├── providers/           # 글로벌 Riverpod Provider
│   ├── router/              # GoRouter 라우팅
│   ├── services/            # 비즈니스 서비스
│   └── utils/               # 유틸리티
├── features/                # 도메인별 모듈 (Clean Architecture)
│   ├── auth/                # 인증 (presentation/data/domain)
│   ├── reservation/         # 예약 관리
│   ├── classroom/           # 교실 관리
│   ├── school/              # 학교 검색 (NEIS API)
│   ├── audit/               # 감사 로그
│   └── settings/            # 설정
└── shared/                  # 공용 계층
    ├── theme/               # 토스 스타일 테마
    └── widgets/             # 재사용 컴포넌트
```

### 2.2 상태 관리 (Riverpod)

**글로벌 Provider**:
```dart
authSessionProvider       // StreamProvider<Session?>
currentUserProvider       // FutureProvider<User?>
isAuthenticatedProvider   // Provider<bool>
supabaseProvider         // Provider<SupabaseClient>
```

**Feature Provider 패턴**:
```
Screen → Provider.watch() → Repository.fetch() → Supabase
                                                      ↓
                              Provider.invalidate() ← UI 액션
```

### 2.3 데이터 모델 (Freezed)

| 모델 | 필드 수 | 특징 |
|------|--------|------|
| User | 13 | 인증 상태, 학교 격리, 검증 문서 |
| Reservation | 15 | 교시 배열, 예약자 정보 JOIN |
| Classroom | 10 | 교실 유형, 공지사항 |
| School | 8 | 교육청, NEIS 코드 |
| ReferralCode | 6 | 추천인 코드 |

---

## 3. 완료된 보안 구현

### 3.1 동시 예약 Race Condition 방지 (v0.3.5)

**문제**: 두 사용자가 동시에 같은 교시를 예약할 때 충돌

**해결책 (2중 방어)**:

1. **Advisory Lock** (`005_fix_critical_vulnerabilities.sql`)
```sql
CREATE FUNCTION check_and_prevent_reservation_conflict_v2()
RETURNS TRIGGER AS $$
BEGIN
  -- 교실 + 날짜 조합에 대한 배타적 락
  lock_key := hashtext(NEW.classroom_id || '|' || DATE(NEW.start_time));
  PERFORM pg_advisory_xact_lock(lock_key);

  -- 충돌 검사 (원자적 실행)
  SELECT COUNT(*) INTO conflict_count
  FROM reservations
  WHERE classroom_id = NEW.classroom_id
    AND DATE(start_time) = DATE(NEW.start_time)
    AND periods && NEW.periods;  -- 교시 배열 겹침

  IF conflict_count > 0 THEN
    RAISE EXCEPTION '이미 예약된 교시입니다';
  END IF;
END;
```

2. **Exclusion Constraint** (물리적 방어선)
```sql
ALTER TABLE reservations
ADD CONSTRAINT prevent_time_overlap
EXCLUDE USING GIST (
  classroom_id WITH =,
  tstzrange(start_time, end_time, '[)') WITH &&
) WHERE (deleted_at IS NULL);
```

### 3.2 RLS (Row Level Security) 정책

- users: 같은 학교 사용자만 조회 가능
- reservations: 본인 ID로만 생성, 미래 날짜만 예약
- classrooms: 같은 학교 교실만 접근

### 3.3 인증 흐름

```
스플래시 → authSessionProvider 구독
         ↓
로그인 상태 확인
├─ 로그인됨 → 승인 상태 체크
│  ├─ 승인 완료 → 홈 화면
│  └─ 승인 대기 → 대기 화면
└─ 미로그인 → 로그인 화면
```

---

## 4. 완료된 성능 최적화

### 4.1 N+1 쿼리 최적화 (v0.3.5)

**Before**:
```dart
// 교실 10개 × 개별 쿼리 = 10+ 쿼리
for (final classroom in classrooms) {
  await getReservationsForClassroom(classroom.id);
}
```

**After**:
```dart
// 병렬 쿼리 = 2개 쿼리
final results = await Future.wait([
  classroomRepo.getClassrooms(),
  reservationRepo.getAllReservationsForDate(_selectedDate),
]);
```

**결과**: 약 80% 쿼리 감소

### 4.2 에러 UX 개선

- PostgrestException → 한글 에러 메시지 변환
- TossSnackBar 전역 적용 (성공/에러/경고/정보)
- Skeleton 로딩 적용

---

## 5. 발견된 문제점

### 5.1 추천인 코드 생성 실패 (Critical)

**증상**: 추천인 코드 생성 시 에러 발생

**원인 분석**:

1. **RLS 정책 누락**
   - `referral_codes` 테이블에 RLS 활성화됨 (001_initial_schema.sql:122)
   - BUT 정책(POLICY)이 정의되지 않음
   - INSERT/SELECT/UPDATE/DELETE 불가

2. **RPC 함수 누락**
   - `increment_referral_uses` 함수가 migrations에 없음
   - referral_code_repository.dart:156에서 호출함:
   ```dart
   await _supabase.rpc('increment_referral_uses', params: {
     'code_id': codeId,
   });
   ```

3. **referral_usage 테이블 RLS**
   - RLS 미활성화 또는 정책 누락

**필요한 마이그레이션**:
```sql
-- referral_codes RLS 정책
CREATE POLICY "Users can read own referral codes" ON referral_codes
  FOR SELECT USING (created_by = auth.uid());

CREATE POLICY "Users can create referral codes" ON referral_codes
  FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can update own referral codes" ON referral_codes
  FOR UPDATE USING (created_by = auth.uid());

-- increment_referral_uses RPC 함수
CREATE OR REPLACE FUNCTION increment_referral_uses(code_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE referral_codes
  SET current_uses = current_uses + 1
  WHERE id = code_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 5.2 Provider Invalidation 불완전

**문제**: 예약 생성/취소 후 일부 Provider가 업데이트되지 않음

**현재 상태** (reservation_screen.dart):
```dart
ref.invalidate(todayReservationsProvider);
ref.invalidate(todayAllReservationsProvider);
ref.invalidate(myReservationsProvider);
// ❌ classroomReservationsStreamProvider 누락
```

**권장 개선**:
```dart
// 상수로 관리
const invalidateAfterReservationChange = [
  todayReservationsProvider,
  todayAllReservationsProvider,
  myReservationsProvider,
  classroomReservationsStreamProvider,
];

// 사용
for (final p in invalidateAfterReservationChange) {
  ref.invalidate(p);
}
```

### 5.3 Realtime 미활용

**현재**: FutureProvider + 수동 invalidate
**권장**: StreamProvider + Realtime 구독 전환

```dart
// 현재 (폴링 방식)
final myReservationsProvider = FutureProvider.autoDispose<List<Reservation>>(...);

// 권장 (실시간)
final myReservationsStreamProvider = StreamProvider.autoDispose<List<Reservation>>((ref) {
  return supabase
    .from('reservations')
    .stream(primaryKey: ['id'])
    .eq('teacher_id', currentUserId)
    .map((data) => data.map(Reservation.fromJson).toList());
});
```

### 5.4 큰 화면 파일

| 파일 | 줄 수 | 권장 |
|------|-------|------|
| home_screen.dart | 1569 | 5-6개 위젯으로 분할 |
| signup_screen.dart | 1028 | 폼 검증 로직 분리 |
| admin_users_screen.dart | 786 | 테이블/필터 로직 분리 |

### 5.5 캐싱 부재

- Repository에 캐싱 메커니즘 없음
- 매번 DB에서 전체 조회
- 권장: SharedPreferences 또는 HTTP 캐싱

---

## 6. Gemini에게 질문할 사항

### 6.1 아키텍처

1. **Flutter Web 최적화**
   - 현재 큰 화면 파일들을 어떻게 분할하는 것이 좋을까요?
   - Widget 분할 vs. 별도 파일 vs. Mixin 사용?

2. **Riverpod 베스트 프랙티스**
   - FutureProvider vs StreamProvider 선택 기준?
   - Provider invalidation을 효율적으로 관리하는 방법?
   - ProviderScope 중첩 사용 시 주의사항?

3. **상태 관리 패턴**
   - 현재 Repository 패턴이 적절한가요?
   - BLoC vs Riverpod에서 Riverpod을 선택한 것이 맞나요?

### 6.2 Supabase 관련

1. **RLS 정책 설계**
   - referral_codes 테이블의 RLS 정책을 어떻게 설계하면 좋을까요?
   - 같은 학교 사용자끼리만 추천인 코드 공유 제약 구현?

2. **Realtime 구독**
   - Realtime 구독이 많아지면 성능에 영향이 있나요?
   - 구독 수 제한이나 최적화 방법?

3. **Edge Functions**
   - 현재 delete-account, neis-api 함수 사용 중
   - 복잡한 비즈니스 로직을 Edge Function으로 옮겨야 할까요?

### 6.3 보안 관련

1. **Advisory Lock**
   - 현재 구현이 충분한가요?
   - 데드락 가능성은?

2. **개인정보보호**
   - 한국 개인정보보호법 준수를 위한 추가 조치?
   - 데이터 암호화 필요 여부?

### 6.4 성능 관련

1. **데이터 페이징**
   - 예약 목록이 많아질 경우 페이징 구현 방법?
   - Infinite scroll vs. 페이지네이션?

2. **이미지 최적화**
   - 현재 클라이언트 사이드 WebP 압축 사용 중
   - 서버 사이드 처리로 옮겨야 할까요?

### 6.5 테스트 관련

1. **테스트 전략**
   - Flutter Web 앱에서 E2E 테스트 도구 추천?
   - Supabase 모킹 방법?

---

## 7. 코드 품질 분석

### 7.1 강점

- **Clean Architecture 준수**: feature별 presentation/data/domain 분리
- **타입 안전성**: Freezed 모델로 immutable 데이터 클래스
- **에러 처리**: 한글화된 사용자 친화적 메시지
- **UI 일관성**: 토스 스타일 컴포넌트 시스템

### 7.2 개선 필요

- **코드 중복**: Provider invalidation 로직 반복
- **로깅 불일치**: 일부 Repository만 AppLogger 사용
- **주석 부족**: 복잡한 로직에 주석 없음

### 7.3 TODO/FIXME 목록

| 파일 | 내용 | 우선순위 |
|------|------|---------|
| audit_log_screen.dart | 실제 데이터 연결 | 낮음 |
| business_info_screen.dart | 실제 사업자 정보 | 중간 |
| user_repository.dart | 승인/반려 알림 (Phase 3) | 낮음 |

---

## 8. 제안 개선 로드맵

### 즉시 (Critical)

1. **referral_codes RLS 정책 추가** - 마이그레이션 파일 작성
2. **increment_referral_uses RPC 함수 추가**
3. **007_fix_user_email_sync.sql 적용** (수동)

### 단기 (1-2주)

1. Provider invalidation 표준화
2. home_screen.dart 분할 리팩토링
3. Realtime 구독 전역 적용

### 중기 (1개월)

1. 단위 테스트 작성 (목표 70% 커버리지)
2. 데이터 페이징 구현
3. 로컬 캐싱 전략 적용

### 장기 (분기)

1. 알림 시스템 (FCM)
2. 오프라인 지원 (Service Worker)
3. 성능 모니터링 (Sentry, Analytics)

---

## 9. 마이그레이션 파일 위치

```
supabase/migrations/
├── 001_initial_schema.sql           # 초기 스키마
├── 002_schools_and_multitenancy.sql # 학교 기반 격리
├── 003_fix_rls_and_add_periods.sql  # RLS 세분화
├── 004_production_ready_security.sql # 동시성 제어
├── 005_fix_critical_vulnerabilities.sql # Advisory Lock
├── 006_auth_helpers.sql             # 인증 헬퍼
├── 007_fix_user_email_sync.sql      # 이메일 동기화 (미적용)
├── 008_admin_password_reset.sql     # 관리자 암호 재설정
├── 009_fix_admin_approval_rls.sql   # 관리자 승인 RLS
└── 010_fix_referral_codes_rls.sql   # (신규 필요) 추천인 코드 RLS
```

---

## 10. 요약

### 잘 된 점
- 동시 예약 Race Condition 완벽 방지 (Advisory Lock + Exclusion Constraint)
- Clean Architecture 구조
- 한글화된 에러 메시지
- 토스 스타일 UI 통일

### 개선 필요
- referral_codes RLS 정책 누락 (Critical)
- Provider invalidation 불완전
- Realtime 미활용
- 큰 화면 파일 분할 필요

### Gemini 리뷰 요청 사항
1. RLS 정책 설계 검토
2. Riverpod 패턴 개선안
3. Flutter Web 성능 최적화 조언
4. 테스트 전략 제안

---

**피드백 부탁드립니다!**
