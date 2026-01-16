# Uncany 세션 요약

## 마지막 업데이트: 2026-01-16

---

## 프로젝트 현재 상태: ✅ v0.3.4 (Staging 테스트 진행 중)

### 완료된 핵심 기능
- 인증 시스템 (로그인/회원가입/로그아웃/비밀번호 재설정)
- 예약 시스템 (교시 기반, Advisory Lock으로 동시성 제어)
- 교실 관리 (CRUD + 수정 UI)
- 프로필 관리 (학년/반 정보)
- 관리자 기능 (사용자 승인/반려/삭제)
- 법적 문서 (이용약관, 개인정보처리방침, 사업자 정보)
- 아이디 찾기/비밀번호 찾기
- 학교 검색 (NEIS API 연동)
- 승인 대기 온보딩 화면 (토스 스타일)
- 토스 스타일 UI 컴포넌트 (bouncing button, skeleton, animations 등)
- **아이디 저장 / 자동 로그인 기능** (NEW)

---

## 최근 완료된 작업 (2026-01-15 ~ 01-16)

### UI/UX 개선
- [x] **아이폰 로딩 화면 개선** (web/index.html)
  - 흰색 → 앱 배경색(#F2F4F6)으로 변경
  - 로딩 스피너 + 로고 애니메이션 추가
  - iOS PWA 메타 태그 보강

- [x] **수업 예약 화면 교실 정보 개선** (classroom_list_screen.dart)
  - 교실 유형별 아이콘 표시
  - 위치 + 수용인원 표시
  - **수정 버튼(설정 아이콘) 추가** → 교실 정보 수정 가능
  - 공지사항 강조 표시 (오렌지 배경)

- [x] **홈 화면 레이아웃 개선** (home_screen.dart)
  - 빠른 메뉴를 컴팩트한 2열 그리드로 변경
  - "빠른 메뉴" 섹션 제목 제거 → 상단에 바로 배치
  - 중복 느낌 해소
  - 관리자 메뉴도 컴팩트하게 개선

### 버그 수정
- [x] **프로필 화면 "위험 구역" 계정 삭제** → "계정 관리"로 변경
- [x] **교시 표시 버그 수정** (3,6교시 → "3, 6교시"로 올바르게 표시)
- [x] **날짜 변경 시 이전 데이터 초기화**

### v0.3.4 업데이트 (2026-01-16)

#### 아이디/비밀번호 찾기 버그 수정
- [x] **이메일 동기화 트리거 추가** (007_fix_user_email_sync.sql)
  - auth.users → public.users 이메일 자동 동기화
  - 기존 사용자 이메일 일괄 동기화 SQL 포함
  - get_username_by_email 함수 대소문자 무시 개선
- [x] **회원가입 시 이메일 명시적 저장** (signup_screen.dart)

#### 로그인 설정 기능 추가
- [x] **아이디 저장 체크박스** - 다음 로그인 시 자동 입력
- [x] **자동 로그인 체크박스** - 세션 유지
- [x] **LoginPreferencesService** 서비스 추가 (SharedPreferences 사용)
- [x] 로그아웃 시 자동 로그인 해제
- [x] 계정 삭제 시 모든 로그인 설정 초기화

### 커밋 내역
```
6efab51 feat: 아이디/비밀번호 찾기 버그 수정 및 로그인 설정 기능 추가
191e85c feat: UI/UX 대폭 개선
7a070c1 docs: 세션 요약 업데이트 (2026-01-15 작업 내역)
19db533 fix: 프로필 화면 UX 개선 및 교시 표시 버그 수정
```

---

## 다음에 할 작업

### 즉시 수동 작업 필요 (Supabase Dashboard)
1. **⚠️ SQL 마이그레이션 적용** - `007_fix_user_email_sync.sql` 실행
   - Supabase Dashboard → SQL Editor → 파일 내용 복사 후 실행
   - 기존 사용자 이메일 동기화 + 트리거 생성

### 즉시 테스트 필요
1. **아이디/비밀번호 찾기** - 마이그레이션 적용 후 테스트
2. **아이디 저장/자동 로그인** - 로그인 화면에서 체크박스 테스트
3. **아이폰 로딩 화면** - 앱 배경색으로 표시되는지 확인

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

| 항목 | 상태 | 비고 |
|------|------|------|
| Edge Functions | ✅ | neis-api, delete-account |
| Secrets | ✅ | NEIS_API_KEY |
| Storage Bucket | ✅ | verification-documents |
| Redirect URLs | ✅ | localhost + staging |
| RPC 함수 | ✅ | get_username_by_email (대소문자 무시) |
| Auth 트리거 | ⚠️ | handle_new_user, sync_user_email (마이그레이션 필요) |

---

## 배포 현황

| 환경 | URL | 상태 |
|------|-----|------|
| Staging | https://uncany-staging.web.app | ✅ 배포됨 |
| Production | - | 미설정 |

---

## 주요 파일 위치

```
lib/src/core/router/router.dart                    # 라우트 정의
lib/src/core/services/login_preferences_service.dart  # 로그인 설정 (SharedPreferences)
lib/src/features/auth/                             # 인증 관련
lib/src/features/reservation/                      # 예약 관련
lib/src/features/classroom/                        # 교실 관련
lib/src/features/school/                           # 학교 검색 (NEIS API)
lib/src/shared/widgets/                            # 토스 스타일 컴포넌트
web/index.html                                     # 로딩 화면
supabase/migrations/                               # DB 마이그레이션
supabase/functions/                                # Edge Functions
```

---

## 알려진 이슈

1. **audit_log_screen.dart**: 모의 데이터 사용 중
2. **Deploy Web Preview**: GitHub 권한 문제 (앱 동작에 영향 없음)
