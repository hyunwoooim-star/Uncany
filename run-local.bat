@echo off
chcp 65001 >nul
echo ================================
echo   Uncany 로컬 실행
echo ================================
echo.

REM .env 파일 확인
if not exist .env (
    echo [에러] .env 파일이 없습니다.
    echo.
    echo setup-env.bat을 먼저 실행하여 환경 변수를 설정하세요.
    echo.
    pause
    exit /b 1
)

REM .env 파일에서 환경 변수 읽기
for /f "tokens=1,2 delims==" %%a in (.env) do (
    set "line=%%a"
    REM 주석과 빈 줄 제외
    if not "!line:~0,1!"=="#" if not "%%a"=="" (
        set "%%a=%%b"
    )
)

REM 환경 변수 검증
if "%SUPABASE_URL%"=="" (
    echo [에러] SUPABASE_URL이 설정되지 않았습니다.
    echo.
    echo .env 파일을 확인하세요.
    pause
    exit /b 1
)

if "%SUPABASE_ANON_KEY%"=="" (
    echo [에러] SUPABASE_ANON_KEY가 설정되지 않았습니다.
    echo.
    echo .env 파일을 확인하세요.
    pause
    exit /b 1
)

echo 환경 변수를 불러왔습니다.
echo - SUPABASE_URL: %SUPABASE_URL%
echo - ENVIRONMENT: %ENVIRONMENT%
echo.

REM WSL에서 Flutter 실행
echo WSL에서 Flutter Web을 실행합니다...
echo.

wsl bash -c "cd /mnt/c/Users/임현우/Desktop/현우\ 작업폴더/Uncany && flutter run -d web-server --web-port=3000 --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY% --dart-define=ENVIRONMENT=%ENVIRONMENT%"
