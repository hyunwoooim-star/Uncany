# Uncany 세션 요약

## 마지막 업데이트: 2026-01-13

---

## 프로젝트 현재 상태: ✅ v0.3 (모바일 배포 준비 완료)

### 완료된 핵심 기능
- 인증 시스템 (로그인/회원가입/로그아웃/비밀번호 재설정)
- 예약 시스템 (교시 기반, Advisory Lock으로 동시성 제어)
- 교실 관리 (CRUD)
- 프로필 관리 (학년/반 정보)
- 관리자 기능 (사용자 승인/반려/삭제)
- 법적 문서 (이용약관, 개인정보처리방침, 사업자 정보)
- 아이디 찾기/비밀번호 찾기

### 최근 완료된 작업 (2026-01-13)

#### 보안 수정 (프로덕션 레벨)
- **RLS 정책 전면 재작성**: SELECT/INSERT/UPDATE/DELETE 세분화
- **Race Condition 해결**: Advisory Lock + Exclusion Constraint
- **Edge Function JWT 검증**: 가짜 토큰 차단
- **periods 배열 검증**: 중복 제거, 자동 정렬, 범위 검증

#### 모바일 배포 준비
- `flutter_localizations` 추가
- iOS Privacy Manifest 템플릿 생성
- AndroidManifest.xml 템플릿 생성
- Info.plist 템플릿 생성
- SafeArea 가이드 작성

---

## Supabase 설정 완료

- [x] DB 마이그레이션 실행 (001~005)
- [x] referral_codes/referral_usage 테이블
- [x] 비밀번호 재설정 Redirect URL
- [x] Edge Functions (delete-account, neis-api)

---

## 배포 현황

| 환경 | URL | 상태 |
|------|-----|------|
| Staging | https://uncany-staging.web.app | ✅ 배포됨 |
| Production | - | 미설정 |

---

## 다음 세션에서 할 일

### 🔴 우선순위 높음: 모바일 앱 빌드
1. `flutter create --platforms android,ios .` 실행
2. 템플릿 파일 복사 (docs/templates/)
3. 이미지 에셋 준비 (logo.png, splash_logo.png)
4. SHA-1 키 Supabase에 등록
5. 빌드 테스트

**참고**: `docs/NEXT_SESSION_COMMANDS.md` 참조

### 우선순위 중간
- Edge Functions 배포 (delete-account, neis-api)
- 알림 시스템 (FCM)

### 우선순위 낮음
- 테스트 코드 추가
- Production 배포

---

## 개발 환경 참고

### 빌드 방법
- **권장**: GitHub Actions 사용 (push하면 자동 빌드)
- **Windows 로컬**: shader compiler 이슈 발생 가능

### 주요 파일 위치
```
lib/src/core/router/router.dart       # 라우트 정의
lib/src/features/auth/               # 인증 관련
lib/src/features/reservation/        # 예약 관련
lib/src/features/settings/           # 설정/법적 문서
supabase/migrations/                 # DB 마이그레이션
supabase/functions/                  # Edge Functions
docs/templates/                      # Android/iOS 템플릿
```

---

## 최근 커밋

```
2c29c3b docs: Git 브랜치 정보 및 Claude 웹 컨텍스트 추가
b0045b6 feat: 모바일 배포 설정 파일 및 의존성 추가
26a6570 fix: CRITICAL - Advisory Lock + JWT validation
160b935 fix: 시니어 개발자 코드 리뷰 피드백 전면 반영
```

---

## 알려진 이슈

1. **audit_log_screen.dart**: 모의 데이터 사용 중
2. **school_api_service.dart**: API 키 미설정 (로컬 데이터로 대체)
