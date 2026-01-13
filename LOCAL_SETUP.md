# 🚀 로컬 개발 환경 설정

## 최신 코드로 업데이트 후 실행하기

### 방법 1: 자동 스크립트 사용 (권장)

```bash
# 1. 프로젝트 디렉토리로 이동
cd /home/user/Uncany

# 2. 최신화 및 설정
./local-setup.sh

# 3. 실행
./run-local.sh
```

### 방법 2: 수동 명령어

```bash
# 1. 최신 코드 가져오기
git fetch origin
git pull origin claude/load-progress-checkpoint-EzHEV

# 2. 패키지 설치
flutter pub get

# 3. 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 코드 분석 (선택)
flutter analyze lib --no-fatal-infos

# 5. 실행
flutter run -d chrome \
  --dart-define=ENVIRONMENT=development \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=WEB_BASE_URL=http://localhost:53104
```

---

## 환경변수 설정

### .env 파일 생성 (권장)

프로젝트 루트에 `.env` 파일 생성:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### 또는 직접 export

```bash
export SUPABASE_URL=https://your-project.supabase.co
export SUPABASE_ANON_KEY=your_anon_key_here
```

---

## 최근 업데이트 내역 (2026-01-13)

### ✨ 새로운 기능
1. **폰트 로딩 최적화**
   - Google Fonts 사전 로딩으로 FOIT(네모 박스) 방지
   - 로딩 스플래시 화면 추가

2. **온보딩 화면**
   - 회원가입 완료 환영 화면
   - 승인 대기/완료 화면 (Confetti 효과)

3. **비밀번호 재설정**
   - 이메일 발송 기능
   - 이메일 링크 클릭 후 새 비밀번호 입력 화면

### 🐛 버그 수정
- 비밀번호 재설정 이메일 발송 오류 (Web/Mobile Deep Link 구분)
- 프로필 비밀번호 변경 화면 경로 오류

---

## 트러블슈팅

### Flutter 버전 오류
```bash
# Flutter 버전 확인
flutter --version

# 권장 버전: 3.32.0
# 다른 버전이면 업데이트:
flutter upgrade
```

### 환경변수 오류
```
SUPABASE_URL이 설정되지 않았습니다.
```
→ `.env` 파일 또는 export 명령어로 환경변수 설정

### 빌드 오류
```bash
# 패키지 캐시 정리
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 포트 설정

- **개발 서버**: http://localhost:53104
- **Supabase Redirect URL**: 위 주소를 Supabase Dashboard에 추가 필요
  - Authentication → URL Configuration → Redirect URLs
  - `http://localhost:53104/reset-password` 추가

---

## WSL 사용자

Windows에서 WSL로 실행 시:

```bash
# WSL 터미널에서
cd /mnt/c/Users/임현우/Uncany
./local-setup.sh
./run-local.sh
```
