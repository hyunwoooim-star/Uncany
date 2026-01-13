# 환경 변수 설정 가이드

## 개요

이 프로젝트는 **환경 변수**를 사용하여 Supabase 연결 정보를 관리합니다.
보안을 위해 API 키와 같은 민감한 정보는 코드에 직접 작성하지 않고 `.env` 파일에 저장합니다.

## 중요 보안 사항 ⚠️

- `.env` 파일은 **절대 GitHub에 커밋하지 마세요!**
- `.env` 파일은 이미 `.gitignore`에 추가되어 있습니다
- `.env.example` 파일만 커밋되어야 합니다

## 빠른 시작

### 1. 환경 변수 설정

#### Windows
```bash
setup-env.bat
```

#### Linux/Mac/WSL
```bash
./setup-env.sh
```

스크립트 실행 시 다음 정보를 입력하세요:
- **Supabase URL**: Supabase 프로젝트 URL
- **Supabase Anon Key**: Supabase 프로젝트의 Anon Key

### 2. Supabase 정보 확인 방법

1. [Supabase Dashboard](https://app.supabase.com) 접속
2. 프로젝트 선택
3. **Settings** > **API** 메뉴 클릭
4. **Project URL**과 **anon public** 키 복사

### 3. 로컬 실행

환경 변수 설정 후 다음 스크립트로 실행:

#### Windows
```bash
run-local.bat
```

#### Linux/Mac/WSL
```bash
./run-local.sh
```

앱은 `http://localhost:3000`에서 실행됩니다.

---

## 수동 설정 방법

자동 스크립트 대신 수동으로 설정하려면:

### 1. .env 파일 생성

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용 작성:

```env
# Supabase 설정
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# 환경 설정
ENVIRONMENT=development
```

### 2. Flutter 실행

```bash
flutter run -d web-server --web-port=3000 \
  --dart-define=SUPABASE_URL="your-url" \
  --dart-define=SUPABASE_ANON_KEY="your-key" \
  --dart-define=ENVIRONMENT="development"
```

---

## .env 파일 구조

```env
# Supabase 연결 정보
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# 실행 환경 (development, staging, production)
ENVIRONMENT=development
```

---

## 환경별 설정

### Development (개발)
```env
ENVIRONMENT=development
```

### Staging (테스트)
```env
ENVIRONMENT=staging
```

### Production (프로덕션)
```env
ENVIRONMENT=production
```

---

## 문제 해결

### "SUPABASE_URL이 설정되지 않았습니다" 에러

1. `.env` 파일이 프로젝트 루트에 있는지 확인
2. `.env` 파일에 `SUPABASE_URL=...` 줄이 있는지 확인
3. 줄 앞에 `#` (주석)이 없는지 확인

### ".env 파일이 없습니다" 에러

`setup-env.bat` (Windows) 또는 `./setup-env.sh` (WSL/Linux)를 실행하여 `.env` 파일을 생성하세요.

### WSL 경로 문제

`run-local.bat` 파일에서 다음 경로를 본인의 환경에 맞게 수정:

```batch
cd /mnt/c/Users/임현우/Desktop/현우\ 작업폴더/Uncany
```

실제 프로젝트 경로로 변경하세요.

---

## 보안 체크리스트

- [ ] `.env` 파일이 `.gitignore`에 포함되어 있음
- [ ] GitHub에 `.env` 파일이 커밋되지 않았음
- [ ] Supabase Anon Key만 사용 (Service Role Key는 서버에서만)
- [ ] 프로덕션 환경과 개발 환경의 Supabase 프로젝트 분리

---

## 참고

- 환경 변수는 **빌드 타임**에 주입됩니다
- 코드 변경 없이 환경만 바꾸려면 `.env` 파일 수정 후 재실행
- CI/CD 환경에서는 GitHub Secrets 등을 사용하여 환경 변수 주입
