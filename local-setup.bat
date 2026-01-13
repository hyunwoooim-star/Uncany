@echo off
chcp 65001 >nul
echo ===== Uncany 로컬 개발 환경 설정 =====
echo.

echo 📥 [1/5] 최신 코드 가져오는 중...
git fetch origin
git pull origin claude/load-progress-checkpoint-EzHEV
echo ✅ Git Pull 완료
echo.

echo 📦 [2/5] Flutter 패키지 설치 중...
flutter pub get
echo ✅ 패키지 설치 완료
echo.

echo 🔧 [3/5] 코드 자동 생성 중...
flutter pub run build_runner build --delete-conflicting-outputs
echo ✅ 코드 생성 완료
echo.

echo 🔍 [4/5] 환경변수 확인 중...
if not exist .env (
    echo ⚠️  .env 파일이 없습니다!
    echo    다음 내용으로 .env 파일을 생성하세요:
    echo.
    echo    SUPABASE_URL=your_supabase_url
    echo    SUPABASE_ANON_KEY=your_supabase_anon_key
    echo.
) else (
    echo ✅ .env 파일 존재
)
echo.

echo 🔎 [5/5] 코드 분석 중...
flutter analyze lib --no-fatal-infos
echo.

echo ===== 설정 완료! =====
echo.
echo 🚀 실행 명령어:
echo    run-local.bat
echo.
pause
