# Uncany 세션 요약

## 마지막 업데이트: 2026-01-14 13:00

---

## 프로젝트 현재 상태: ✅ v0.3.1 (Staging 테스트 진행 중)

### 완료된 핵심 기능
- 인증 시스템 (로그인/회원가입/로그아웃/비밀번호 재설정)
- 예약 시스템 (교시 기반, Advisory Lock으로 동시성 제어)
- 교실 관리 (CRUD)
- 프로필 관리 (학년/반 정보)
- 관리자 기능 (사용자 승인/반려/삭제)
- 법적 문서 (이용약관, 개인정보처리방침, 사업자 정보)
- 아이디 찾기/비밀번호 찾기
- **학교 검색 (NEIS API 연동)**
- **승인 대기 온보딩 화면 (토스 스타일)**

---

## 오늘 완료된 작업 (2026-01-14)

### Supabase 수동 설정 완료
- [x] Edge Functions 배포 (Dashboard에서 직접)
  - `neis-api`: NEIS 학교 검색 API 프록시
  - `delete-account`: 회원 탈퇴 처리
- [x] NEIS_API_KEY 시크릿 설정
- [x] Storage 버킷 (`verification-documents`) 확인
- [x] Redirect URL 화이트리스트 추가
  - `http://localhost:3000/auth/reset-password`
  - `https://uncany-staging.web.app/auth/reset-password`
  - `https://uncany-staging.web.app/reset-password`
- [x] RPC 함수 생성 (`get_username_by_email`)
- [x] 회원가입 트리거 생성 (`handle_new_user`)

### 버그 수정
- [x] 학교 검색 드롭다운 선택 안 되는 문제 (`onTapDown` 사용)
- [x] 회원가입 후 "사용자 정보를 불러올 수 없습니다" 오류 (DB 트리거로 해결)
- [x] 승인 상태 확인 버튼 피드백 없음 (상태별 스낵바 추가)
- [x] 아이디 찾기 RLS 문제 (RPC 함수로 우회)
- [x] 비밀번호 재설정 Redirect URL 하드코딩 (환경별 동적 URL)

### 커밋 내역
```
29e1468 fix: 아이디 찾기/비밀번호 재설정 기능 수정
4604e6f fix: 승인 상태 확인 버튼 피드백 개선
5a3618a fix: 학교 선택 - onTapDown으로 포커스 변경 전 즉시 처리
3266061 fix: 학교 검색 목록 선택 문제 수정
d435ac0 fix: 학교 검색 결과 선택 버그 수정
```

---

## 다음에 할 작업

### 즉시 테스트 필요
1. **아이디 찾기** - RPC 함수 적용 확인
2. **비밀번호 재설정** - 이메일 발송 및 링크 작동 확인
3. **회원가입 전체 플로우** - 가입 → 승인 대기 → 승인 후 홈 이동

### 우선순위 높음
- Staging 전체 기능 E2E 테스트
- 관리자 계정으로 사용자 승인 테스트

### 우선순위 중간
- SHA-1 키 Supabase 등록 (Android Google 로그인)
- 알림 시스템 (FCM)
- Production 환경 설정

### 우선순위 낮음
- 앱스토어 등록 준비

---

## Supabase 설정 현황

### Dashboard에서 완료한 작업
| 항목 | 상태 | 비고 |
|------|------|------|
| Edge Functions | ✅ | neis-api, delete-account |
| Secrets | ✅ | NEIS_API_KEY |
| Storage Bucket | ✅ | verification-documents |
| Redirect URLs | ✅ | localhost + staging |
| RPC 함수 | ✅ | get_username_by_email |
| Auth 트리거 | ✅ | handle_new_user |

### 마이그레이션 파일 (참고용)
```
supabase/migrations/
├── 001_initial_schema.sql
├── 002_schools_and_multitenancy.sql
├── 003_fix_rls_and_add_periods.sql
├── 004_production_ready_security.sql
├── 005_fix_critical_vulnerabilities.sql
└── 006_auth_helpers.sql  ← NEW (RPC 함수)
```

---

## GitHub Secrets 설정 완료

- [x] SUPABASE_URL_STAGING
- [x] SUPABASE_ANON_KEY_STAGING
- [x] FIREBASE_SERVICE_ACCOUNT
- [x] NEIS_API_KEY

---

## 배포 현황

| 환경 | URL | 상태 |
|------|-----|------|
| Staging | https://uncany-staging.web.app | ✅ 배포됨 |
| Production | - | 미설정 |

---

## 개발 환경 참고

### 주요 파일 위치
```
lib/src/core/router/router.dart       # 라우트 정의
lib/src/features/auth/               # 인증 관련
lib/src/features/reservation/        # 예약 관련
lib/src/features/school/             # 학교 검색 (NEIS API)
supabase/migrations/                 # DB 마이그레이션
supabase/functions/                  # Edge Functions
```

### 오늘 수정된 주요 파일
```
lib/src/features/auth/presentation/find_username_screen.dart  # RPC 호출
lib/src/features/auth/data/repositories/auth_repository.dart  # 동적 Redirect URL
lib/src/features/auth/presentation/pending_approval_screen.dart  # 상태 피드백
lib/src/features/school/presentation/widgets/school_search_field.dart  # onTapDown
```

---

## 알려진 이슈

1. **audit_log_screen.dart**: 모의 데이터 사용 중
2. **Deploy Web Preview**: GitHub 권한 문제 (앱 동작에 영향 없음)
