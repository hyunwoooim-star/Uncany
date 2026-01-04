# 로컬 개발 환경 설정 가이드

이 문서는 Uncany 프로젝트를 로컬에서 실행하기 위한 단계별 가이드입니다.

## 사전 요구사항

- **Flutter SDK**: 3.38.5 이상
  - 설치 경로: `C:\Users\임현우\Downloads\flutter_windows_3.38.5-stable\flutter\bin`
  - PATH에 추가되어 있어야 함
- **Git**: 버전 관리
- **VSCode**: 권장 에디터 (Flutter, Dart 확장 필요)
- **WSL Ubuntu** (선택사항): Linux 환경 테스트용

## 1단계: 프로젝트 클론

```bash
# GitHub에서 프로젝트 클론
git clone https://github.com/hyunwoooim-star/Uncany.git
cd Uncany

# 개발 브랜치로 체크아웃
git checkout claude/school-booking-platform-M3ffi
```

## 2단계: 환경 변수 설정

프로젝트 루트에 `.env` 파일이 이미 생성되어 있습니다.
만약 없다면 `.env.example`을 복사하여 생성하세요:

```bash
# Windows (PowerShell)
Copy-Item .env.example .env

# Linux/Mac/WSL
cp .env.example .env
```

`.env` 파일 내용 (이미 설정됨):
```env
SUPABASE_URL=https://wlhuthqyaeyavfupaw.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpaHVpdHZneWVxYXlzeGZ1cHV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1MzI1MjcsImV4cCI6MjA4MzEwODUyN30.2BMHqJ70YwH5I3bQvGC_fpw1uai0RTDBxFZjAr_gcEU
ENVIRONMENT=development
```

## 3단계: Flutter 의존성 설치

```bash
# Flutter 패키지 설치
flutter pub get
```

## 4단계: 코드 생성 (Freezed, JSON Serializable)

```bash
# build_runner를 사용하여 코드 생성
# --delete-conflicting-outputs: 충돌하는 파일 자동 삭제
flutter pub run build_runner build --delete-conflicting-outputs

# 또는 watch 모드로 실행 (파일 변경 시 자동 재생성)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**주의**: 이 단계에서 다음 파일들이 생성됩니다:
- `*.freezed.dart`: Freezed 모델 클래스
- `*.g.dart`: JSON 직렬화 코드

## 5단계: Supabase 데이터베이스 마이그레이션

Supabase 대시보드에서 SQL 실행:

1. [Supabase Dashboard](https://supabase.com/dashboard/project/wlhuthqyaeyavfupaw) 접속
2. 좌측 메뉴에서 **SQL Editor** 클릭
3. `supabase/migrations/001_initial_schema.sql` 파일 내용 복사
4. SQL Editor에 붙여넣고 **Run** 클릭

또는 Supabase CLI 사용 (선택사항):
```bash
# Supabase CLI 설치 (npm 필요)
npm install -g supabase

# 프로젝트 초기화
supabase init

# 마이그레이션 실행
supabase db push
```

## 6단계: 앱 실행

### 웹에서 실행 (Chrome)

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://wlhuthqyaeyavfupaw.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpaHVpdHZneWVxYXlzeGZ1cHV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1MzI1MjcsImV4cCI6MjA4MzEwODUyN30.2BMHqJ70YwH5I3bQvGC_fpw1uai0RTDBxFZjAr_gcEU
```

### Android 에뮬레이터에서 실행

```bash
# 에뮬레이터 실행 (Android Studio에서)
# 또는
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run --dart-define=SUPABASE_URL=https://wlhuthqyaeyavfupaw.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpaHVpdHZneWVxYXlzeGZ1cHV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1MzI1MjcsImV4cCI6MjA4MzEwODUyN30.2BMHqJ70YwH5I3bQvGC_fpw1uai0RTDBxFZjAr_gcEU
```

### iOS 시뮬레이터에서 실행 (Mac만 가능)

```bash
# iOS 시뮬레이터 열기
open -a Simulator

# 앱 실행
flutter run --dart-define=SUPABASE_URL=https://wlhuthqyaeyavfupaw.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpaHVpdHZneWVxYXlzeGZ1cHV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1MzI1MjcsImV4cCI6MjA4MzEwODUyN30.2BMHqJ70YwH5I3bQvGC_fpw1uai0RTDBxFZjAr_gcEU
```

### WSL Ubuntu에서 웹 실행 (Linux 환경)

```bash
# WSL Ubuntu에서
cd /mnt/c/Users/임현우/path/to/Uncany

# Chrome 설치 (필요한 경우)
sudo apt update
sudo apt install google-chrome-stable

# 웹 실행
flutter run -d web-server --web-port=8080
```

## 7단계: VSCode에서 디버깅

1. VSCode 열기
2. `F5` 누르기 또는 **Run and Debug** 패널에서 **Launch (Web)** 선택
3. 자동으로 `.vscode/launch.json` 설정이 적용됨

## 개발 팁

### Hot Reload 사용

앱 실행 중 코드를 수정하면:
- **r**: Hot Reload (빠른 재로드)
- **R**: Hot Restart (앱 완전 재시작)
- **q**: 종료

### 코드 생성 자동화

개발 중 모델을 자주 수정한다면 watch 모드 사용:
```bash
# 별도 터미널에서 실행
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Flutter Doctor 검사

개발 환경 문제 해결:
```bash
flutter doctor -v
```

### 패키지 업데이트

```bash
# 모든 패키지를 최신 버전으로 업데이트
flutter pub upgrade

# 특정 패키지만 업데이트
flutter pub upgrade supabase_flutter
```

## 문제 해결

### 1. "Command not found: flutter"

Flutter SDK PATH가 설정되지 않았습니다.

**Windows (PowerShell 관리자 권한)**:
```powershell
$env:Path += ";C:\Users\임현우\Downloads\flutter_windows_3.38.5-stable\flutter\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::User)
```

**환경 변수 GUI로 설정**:
1. 시스템 속성 → 환경 변수
2. 사용자 변수 → Path 편집
3. `C:\Users\임현우\Downloads\flutter_windows_3.38.5-stable\flutter\bin` 추가

### 2. "SUPABASE_URL not set" 오류

환경 변수가 전달되지 않았습니다.
`--dart-define` 플래그를 사용하거나 `.env` 파일을 확인하세요.

### 3. Build Runner 충돌 오류

```bash
# 기존 생성 파일 모두 삭제 후 재생성
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Supabase 연결 오류

- `.env` 파일의 URL과 키가 올바른지 확인
- Supabase 프로젝트가 활성화되어 있는지 확인
- 네트워크 연결 확인

## 다음 단계

개발 환경 설정이 완료되었습니다! 이제:

1. **Phase 1 개발 시작**: `PROJECT_PLAN.md` 참조
2. **API 구현**: Supabase와 통신하는 Repository 레이어 구현
3. **UI 개선**: Toss 스타일 컴포넌트 확장

궁금한 점이 있으면 `CONTRIBUTING.md`를 참조하세요.
