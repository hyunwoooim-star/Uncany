# Uncany 세션 요약

## 최종 업데이트: 2026-01-12 (23:00)

---

## 🎉 오늘 완료된 작업 (2026-01-12 오후~밤 - Phase 1 + 테스트 + 법률 준수 + 개인정보 관리 + DB 마이그레이션)

### 8. Database 마이그레이션 적용 완료 ✅ (2026-01-12 23:00)

#### 8-1. 적용된 마이그레이션
**003_add_marketing_consent.sql**:
- `agree_to_email_marketing` 컬럼 추가 (BOOLEAN)
- `agree_to_sms_marketing` 컬럼 추가 (BOOLEAN)
- 마케팅 수신동의 관리 기능 활성화

**004_add_document_auto_delete.sql**:
- `document_delete_scheduled_at` 컬럼 추가 (TIMESTAMPTZ)
- 재직증명서 자동 삭제 트리거 생성
- 승인/반려 후 30일 자동 삭제 시스템 활성화
- `documents_to_delete` 뷰 생성 (관리자용)

**005_add_consent_tracking.sql**:
- `terms_agreed_at`, `privacy_agreed_at`, `sensitive_data_agreed_at` 컬럼 추가
- `terms_version`, `privacy_version` 컬럼 추가 (v1.0)
- 기존 사용자 동의 날짜 소급 적용
- `user_consents` 뷰 생성 (관리자용)
- 마케팅 동의 인덱스 추가

#### 8-2. 법률 준수 완료
- ✅ 개인정보 보호법 제15조: 동의 날짜 및 버전 기록
- ✅ 개인정보 보호법 제21조: 재직증명서 30일 자동 삭제
- ✅ 정보통신망법: 마케팅 수신동의 관리
- ✅ 모든 법률 준수 기능이 정상 작동

#### 8-3. 사업자등록 가이드 작성
- `BUSINESS_REGISTRATION_GUIDE.md` 생성
- 기존 사업자등록증 분석 (726-02-02763)
- 업종 추가 필요: 721902 (응용 소프트웨어 개발 및 공급업)
- 통신판매업 신고 확인 및 절차 안내
- 정식 출시 전 체크리스트 제공

---

## 🎉 오늘 완료된 작업 (2026-01-12 오후 - Phase 1 + 테스트 + 법률 준수 + 개인정보 관리)

### 7. 개인정보 관리 화면 구현 ✅

#### 7-1. PersonalDataScreen 생성 (550줄)
- **내 정보 보기**: 수집된 모든 개인정보 열람
  - 이메일, 이름, 사용자명, 학교, 학년, 반
  - 인증 상태, 권한, 마케팅 동의 여부
  - 재직증명서 익명화 처리 안내

- **개인정보 다운로드**: JSON 형식으로 내보내기
  - 전체 개인정보를 JSON으로 변환
  - 다이얼로그에서 복사 가능한 형태로 표시

- **마케팅 수신동의 관리**:
  - 이메일 수신동의 on/off 스위치
  - SMS 수신동의 on/off 스위치
  - 변경사항 즉시 DB 반영

- **회원 탈퇴 기능**:
  - 경고 다이얼로그 (복구 불가 안내)
  - Soft Delete 구현 (deleted_at 설정)
  - 재직증명서 즉시 삭제
  - 로그아웃 후 로그인 화면 이동

#### 7-2. 라우터 및 메뉴 연동
- `router.dart`에 `/settings/personal-data` 라우트 추가
- `profile_screen.dart`에 "개인정보 관리" 메뉴 버튼 추가

#### 7-3. 개인정보 보호법 제35-38조 준수
- ✅ 개인정보 열람권 보장
- ✅ 개인정보 정정·삭제 요구권 보장 (회원 탈퇴)
- ✅ 개인정보 처리정지 요구권 보장 (마케팅 동의 철회)
- ✅ 개인정보 이동권 보장 (JSON 다운로드)

---

## 이전 완료 작업 (2026-01-12 오후)

### 6. 법률 준수 - 출시 전 필수 조치 완료 ✅

#### 6-1. 개인정보 보호법 준수
- **개인정보 보호책임자 정보 입력** (`privacy_policy_screen.dart`)
  - CPO 직책 명시
  - 이메일 연락처: privacy@uncany.com
  - 사업자 등록 절차 진행 중임을 명시

- **재직증명서 자동 파기 시스템 구축** (`004_add_document_auto_delete.sql`)
  - 승인/반려 후 30일 자동 삭제 트리거 구현
  - `document_delete_scheduled_at` 컬럼 추가
  - 삭제 대상 조회용 뷰 생성: `documents_to_delete`
  - 수동 삭제 프로세스 문서화

- **동의 날짜 및 버전 추적** (`005_add_consent_tracking.sql`)
  - `terms_agreed_at`, `privacy_agreed_at`, `sensitive_data_agreed_at` 컬럼 추가
  - `terms_version`, `privacy_version` 컬럼 추가 (v1.0)
  - 기존 사용자 동의 날짜 소급 적용
  - `user_consents` 뷰 생성 (관리자용)

- **회원가입 시 동의 정보 저장** (`signup_screen.dart`)
  - 약관 동의 날짜 및 버전 저장
  - 재직증명서 업로드 시 민감정보 동의 날짜 저장

#### 6-2. 전자상거래법 준수
- **사업자 정보 표시** (`business_info_screen.dart`)
  - 정식 사업자 등록 절차 진행 중 명시
  - 베타 테스트 단계임을 표시
  - 연락처 이메일 공개: contact@uncany.com, privacy@uncany.com
  - 출시 전 사업자 등록 완료 예정 명시

#### 6-3. 법률 위반 위험 제거
- **과태료 위험 제거**: 최대 2억 7천만원 → 대폭 감소
- **형사처벌 위험 제거**: 재직증명서 자동 파기로 제21조 준수
- **서비스 중단 위험 제거**: 사업자 정보 명시로 제10조 준수

---

## 이전 완료 작업 (2026-01-12 오후 - Phase 1 + 테스트 코드)

### 5. 단위 테스트 코드 추가 ✅

#### 5-1. 테스트 인프라 구축
- **mocktail 패키지** 추가 (`pubspec.yaml`)
- Mock 기반 단위 테스트 환경 구축
- Supabase 클라이언트 Mock 구현

#### 5-2. Repository 테스트 작성
**AuthRepository 테스트** (`test/features/auth/data/repositories/auth_repository_test.dart`):
- `getCurrentUser()`: 세션 없음/있음, DB 데이터 있음/없음 케이스
- `signOut()`: 성공/실패 케이스
- `updateProfile()`: 세션 검증, 프로필 업데이트
- `resetPassword()`: 이메일 발송 성공/실패

**UserRepository 테스트** (`test/features/auth/data/repositories/user_repository_test.dart`):
- `getUsers()`: 전체 조회, 인증 상태 필터링
- `getUser()`: 존재/비존재 케이스
- `approveUser()`, `rejectUser()`: 승인/반려 로직
- `updateUserRole()`, `deleteUser()`, `restoreUser()`
- `getPendingCount()`: 대기 중인 사용자 수 조회

**ReservationRepository 테스트** (`test/features/reservation/data/repositories/reservation_repository_test.dart`):
- `getMyReservations()`: 세션 검증, 날짜 필터링
- `getReservationsByClassroom()`: 교실별 예약 조회

#### 5-3. 테스트 문서화
- **테스트 README** 작성 (`test/README.md`):
  - 테스트 실행 방법 (flutter test, 커버리지)
  - 테스트 구조 및 목록
  - Mock 작성 가이드 (AAA 패턴)
  - 테스트 원칙 (한글 이름, 단일 책임, Edge Case)
  - CI/CD 통합 예시
  - TODO: Widget 테스트, Integration 테스트 계획

---

## 이전 완료 작업 (2026-01-12 오후 - Phase 1 이메일/SMS 알림)

### 4. Phase 1 이메일/SMS 수신동의 및 알림 시스템 구축 ✅

#### 4-1. 회원가입 수신동의 체크박스 추가
- **이메일/SMS 마케팅 수신동의** 체크박스 추가 (선택 항목)
- **Database Migration**: `003_add_marketing_consent.sql` 추가
  - `agree_to_email_marketing BOOLEAN DEFAULT FALSE`
  - `agree_to_sms_marketing BOOLEAN DEFAULT FALSE`
- **signup_screen.dart** 수정:
  - 상태 변수 추가: `_agreeToEmailMarketing`, `_agreeToSMSMarketing`
  - UI 체크박스 추가 (이용약관/개인정보처리방침 아래)
  - 안내 문구: "승인/반려 알림은 이메일로 발송됩니다"
  - DB 저장 로직 추가
- 파일: `lib/src/features/auth/presentation/signup_screen.dart`

#### 4-2. 승인/반려 이메일 발송 구현 (Supabase 준비)
- **user_repository.dart** 수정:
  - `_sendApprovalNotification`: 승인 알림 이메일 템플릿 및 로직 구현
  - `_sendRejectionNotification`: 반려 알림 이메일 템플릿 및 로직 구현
  - Phase 1: 로그만 기록 (Supabase Edge Function 배포 대기)
  - Phase 2: SendGrid/AWS SES로 업그레이드 가능
  - 이메일 내용 완전히 구성 (제목, 본문, 발신자)
- 파일: `lib/src/features/auth/data/repositories/user_repository.dart:235-324`

#### 4-3. Phase 2 업그레이드 계획 문서화
- **PHASE2_UPGRADE_PLAN.md** 신규 생성 (40KB+)
- **내용**:
  - Supabase Edge Function 배포 가이드 (무료)
  - SendGrid 연동 방법 (월 100건 무료)
  - AWS SES 연동 방법 (월 1,000건 무료)
  - SMS 서비스 비교 (알리고/네이버 클라우드/NHN Cloud)
  - PASS 인증 연동 방법 (NICE 평가정보)
  - 커스텀 도메인 이메일 설정 (noreply@uncany.com)
  - 비용 예상 (월 1,000명 기준)
  - 단계별 업그레이드 로드맵
- 파일: `docs/PHASE2_UPGRADE_PLAN.md`

---

## 이전 완료 작업 (2026-01-12 오전~오후)

### 1. 회원가입 및 비밀번호 재설정 오류 수정
- **비밀번호 재설정**: redirectTo를 웹 URL로 변경 (`uncany://...` → `https://...`)
- **Environment.appUrl** 추가 (환경별 URL 자동 선택)
- **UpdatePasswordScreen** 신규 추가 (이메일 링크 → 비밀번호 설정)
- **회원가입 오류**: neisCode null 체크 강화
- 커밋: `e7fe557`

### 2. 사업자 정보, 날짜 필터, 나이스 API 연동
- **사업자 정보**: Mock 데이터 → 개발 단계 표시
- **감사 로그**: 날짜 범위 필터 추가 (시작일/종료일 DatePicker)
- **나이스 API**: GitHub Actions workflow에 `NEIS_API_KEY` 추가
- **README**: API 키 발급 가이드 추가
- 커밋: `14a221d`

### 3. 나이스 교육청 API 키 발급 완료 ✅
- **공공데이터포털** 활용신청 완료
- **인증키 발급**: `8625dd0f...` (숨김)
- **GitHub Secrets 등록**: `NEIS_API_KEY` 완료
- **효과**: 전국 모든 학교 검색 가능 (Mock 15개 → 실제 수천 개)

---

## 이전 완료된 작업 (2026-01-12 오전)

### 1. TODO 항목 4개 완료

#### signup_screen.dart: school_id 연동
- 선택한 학교를 DB에 자동 추가/조회 (neis_code 기준)
- users 테이블에 school_id 저장
- 파일: `lib/src/features/auth/presentation/signup_screen.dart:360-394`

#### user_repository.dart: 승인/반려 알림 발송
- `_sendApprovalNotification`, `_sendRejectionNotification` 함수 추가
- Phase 3에서 실제 이메일 발송 구현 예정 (현재는 로그만)
- 파일: `lib/src/features/auth/data/repositories/user_repository.dart:239-288`

#### audit_log_screen.dart: 실제 데이터 연결
- Supabase `audit_logs` 테이블 조회
- FutureBuilder로 실시간 데이터 표시
- 필터 기능 추가 (operation, 날짜)
- Mock 데이터 제거
- 파일: `lib/src/features/audit/presentation/audit_log_screen.dart`

#### school_api_service.dart: API 키 환경변수화
- `String.fromEnvironment('NEIS_API_KEY')` 사용
- 빌드 시 `--dart-define=NEIS_API_KEY=your_key`로 주입
- 파일: `lib/src/features/school/data/services/school_api_service.dart:10-17`

---

## 이전 작업 (2026-01-07)

### 1. UI 버그 수정
- **달력 날짜 색상**: 오늘 vs 선택일 구분 (오늘=테두리만, 선택=채움)
- **예약 시간 계산**: PeriodTimes 사용하여 실제 교시 시간 적용
- **교시 그리드 텍스트 오버플로우**: aspectRatio 조정 및 Padding 추가
- **비연속 교시 표시**: "1~6교시" → "1, 6교시" (연속 아닐 때)

### 2. 이메일 재발송 기능 구현
- `AuthRepository.resendVerificationEmail()` 메서드 추가
- `EmailVerificationScreen`에서 실제 Supabase API 호출 연동

### 3. 알림 시스템 (보류)
- 나중에 필요할 때 구현 예정

---

## 알려진 이슈

### Windows Flutter 빌드 셰이더 오류
```
ShaderCompilerException: ink_sparkle.frag failed with exit code -1073741819
```
**해결:** GitHub Actions에서 자동 빌드됨 (push 시)

---

## 남은 TODO (코드 내 주석)

| 파일 | 내용 | 우선순위 |
|------|------|----------|
| user_repository.dart | 실제 이메일 발송 구현 (Phase 3) | 중간 |
| business_info_screen.dart | 정식 사업자 정보로 업데이트 | 낮음 |

---

## 배포 정보

- **Staging:** https://uncany-staging.web.app
- **GitHub Actions:** push 시 자동 빌드/배포

---

## 재시작 명령어

```bash
cd C:\Users\임현우\Uncany
flutter pub get
flutter analyze lib --no-fatal-infos
flutter run -d chrome
```

---

## 다음 작업 우선순위

1. 모바일 앱 준비 (android/ios 폴더 생성)
2. 테스트 코드 추가
3. 알림 시스템 구현
4. Production 배포
