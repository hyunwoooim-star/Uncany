# Uncany 세션 요약

## 마지막 업데이트: 2026-01-12

---

## 프로젝트 현재 상태: ✅ v0.2 완료

### 완료된 핵심 기능
- 인증 시스템 (로그인/회원가입/로그아웃)
- 예약 시스템 (교시 기반)
- 교실 관리 (CRUD)
- 프로필 관리 (학년/반 정보)
- 관리자 기능 (사용자 승인/반려/삭제)

### 최근 추가된 기능 (이번 세션)
1. **아이디 찾기** - `find_username_screen.dart`
2. **법적 문서 페이지**
   - 이용약관 (`terms_screen.dart`)
   - 개인정보처리방침 (`privacy_policy_screen.dart`)
   - 사업자 정보 (`business_info_screen.dart`)
3. **관리자 계정 완전 삭제** - `hardDeleteUser()` in `user_repository.dart`
4. **로그인 화면 개선** - 아이디 찾기 | 비밀번호 찾기 버튼 분리
5. **프로필 화면** - 약관 및 정책 섹션 추가

---

## Supabase 설정 완료 (수동 작업 완료됨)

- [x] DB 마이그레이션 실행 완료
- [x] referral_codes 테이블 생성 완료
- [x] referral_usage 테이블 생성 완료
- [x] 비밀번호 재설정 Redirect URL 설정 완료

---

## 배포 현황

| 환경 | URL | 상태 |
|------|-----|------|
| Staging | https://uncany-staging.web.app | ✅ 배포됨 |
| Production | - | 미설정 |

---

## 다음 세션에서 할 일

### 우선순위 높음
1. Staging 사이트에서 전체 기능 테스트
2. 프로필 수정 후 메인화면 반영 확인 (버그 가능성)
3. 사업자 정보 페이지에 실제 정보 입력

### 우선순위 중간
- 알림 시스템 (FCM)
- 승인/반려 알림

### 우선순위 낮음
- 모바일 앱 빌드
- 테스트 코드 추가
- Production 배포

---

## 개발 환경 참고

### 빌드 방법
- **권장**: GitHub Actions 사용 (push하면 자동 빌드)
- **Windows 로컬**: shader compiler 이슈 발생 가능
- **WSL**: Windows Flutter SDK 직접 사용 불가

### 주요 파일 위치
```
lib/src/core/router/router.dart       # 라우트 정의 (22개)
lib/src/features/auth/               # 인증 관련
lib/src/features/reservation/        # 예약 관련
lib/src/features/classroom/          # 교실 관련
lib/src/features/settings/           # 설정/법적 문서
docs/MANUAL_TASKS.md                 # 수동 작업 체크리스트
```

---

## 최근 커밋

```
62aa7a8 docs: 수동 작업 체크리스트 및 세션 요약 업데이트
fa6d27f feat: Phase 3 완료 - 홈 화면 개선, 반응형 디자인, 애니메이션
9116f8f feat: Phase 1.3 - 학교 기반 멀티테넌시 기반 구축
```

---

## 알려진 이슈

1. **프로필 수정 반영**: 메인화면에 학년/반 정보 반영 확인 필요
2. **audit_log_screen.dart**: 모의 데이터 사용 중 (실제 데이터 연동 필요)
3. **school_api_service.dart**: API 키 미설정 (로컬 데이터로 대체됨)
