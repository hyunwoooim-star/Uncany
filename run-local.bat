@echo off
chcp 65001 >nul
echo 🚀 Uncany 로컬 실행 중...
echo.

REM .env 파일 로드 (있으면)
if exist .env (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" (
            if not "%%a:~0,1%"=="#" (
                set "%%a=%%b"
            )
        )
    )
    echo ✅ .env 파일 로드 완료
) else (
    echo ❌ .env 파일이 없습니다!
    echo.
    echo 프로젝트 루트에 .env 파일을 생성하고 다음 내용을 추가하세요:
    echo.
    echo SUPABASE_URL=https://your-project.supabase.co
    echo SUPABASE_ANON_KEY=your_anon_key_here
    echo.
    pause
    exit /b 1
)

REM 환경변수 확인
if "%SUPABASE_URL%"=="" (
    echo ❌ SUPABASE_URL 환경변수가 설정되지 않았습니다!
    pause
    exit /b 1
)

if "%SUPABASE_ANON_KEY%"=="" (
    echo ❌ SUPABASE_ANON_KEY 환경변수가 설정되지 않았습니다!
    pause
    exit /b 1
)

echo 📍 Supabase URL: %SUPABASE_URL%
echo 📍 Web Base URL: http://localhost:53104
echo.

REM Flutter 실행
flutter run -d chrome ^
    --dart-define=ENVIRONMENT=development ^
    --dart-define=SUPABASE_URL=%SUPABASE_URL% ^
    --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY% ^
    --dart-define=WEB_BASE_URL=http://localhost:53104
