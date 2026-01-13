# Supabase Redirect URL 설정 가이드

## 비밀번호 재설정 기능을 위한 Redirect URL 설정

Flutter Web에서 비밀번호 재설정 기능이 작동하려면 Supabase Dashboard에서 Redirect URL을 설정해야 합니다.

### 1. Supabase Dashboard 접속

1. [Supabase Dashboard](https://app.supabase.com) 접속
2. 해당 프로젝트 선택

### 2. Authentication 설정

1. 왼쪽 사이드바에서 **Authentication** 클릭
2. **URL Configuration** 탭 클릭

### 3. Redirect URL 추가

**Site URL** 섹션:
- 개발 환경: `http://localhost:3000`
- 프로덕션 환경: 실제 배포 도메인 (예: `https://uncany.com`)

**Redirect URLs** 섹션에 다음 URL 추가:

#### 개발 환경
```
http://localhost:3000/auth/reset-password
http://localhost:3000/auth/login
```

#### 프로덕션 환경 (배포 시 추가)
```
https://your-domain.com/auth/reset-password
https://your-domain.com/auth/login
```

### 4. 저장

- **Save** 버튼 클릭하여 변경사항 저장

---

## 현재 설정 상태

### Flutter 코드
- `lib/src/core/constants/app_constants.dart`에 웹 URL 상수 정의됨
- `lib/src/features/auth/data/repositories/auth_repository.dart`에서 `http://localhost:3000/auth/reset-password` 사용

### 포트 번호 확인

로컬 실행 시 사용하는 포트 번호를 확인하세요:
```bash
# run-local.bat 또는 run-local.sh 실행 시 출력되는 포트 번호
# 기본값: 3000
```

만약 다른 포트를 사용한다면:
1. `app_constants.dart`의 `webBaseUrlDev` 수정
2. `auth_repository.dart`의 `redirectTo` 수정
3. Supabase Dashboard의 Redirect URL도 동일하게 수정

---

## 테스트 방법

1. 로컬에서 앱 실행:
   ```bash
   run-local.bat
   ```

2. 로그인 화면에서 "비밀번호를 잊으셨나요?" 클릭

3. 이메일 입력 후 "재설정 링크 보내기" 클릭

4. 이메일 수신 후 링크 클릭

5. 정상적으로 `/auth/reset-password` 페이지로 리다이렉트되는지 확인

---

## 문제 해결

### 에러: "redirect URL not allowed"
- Supabase Dashboard에서 Redirect URL이 정확히 추가되었는지 확인
- 프로토콜(http/https), 도메인, 포트 번호가 정확한지 확인
- 설정 저장 후 1-2분 대기

### 이메일이 안 오는 경우
- Supabase Dashboard > Authentication > Email Templates 확인
- SMTP 설정이 올바른지 확인
- 스팸 메일함 확인

### 리다이렉트가 안 되는 경우
- 브라우저 콘솔에서 에러 메시지 확인
- 라우터 설정 확인 (`lib/src/core/router/router.dart`)
- Supabase Auth 상태 확인

---

## 참고 자료

- [Supabase Auth - Reset Password](https://supabase.com/docs/guides/auth/auth-password-reset)
- [Supabase Auth - Redirect URLs](https://supabase.com/docs/guides/auth/redirect-urls)
