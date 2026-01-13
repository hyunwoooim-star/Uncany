@echo off
chcp 65001 >nul
echo ================================
echo   환경 변수 설정 (.env 생성)
echo ================================
echo.

REM .env 파일이 이미 있는지 확인
if exist .env (
    echo [경고] .env 파일이 이미 존재합니다.
    echo.
    set /p overwrite="덮어쓰시겠습니까? (y/n): "
    if /i not "%overwrite%"=="y" (
        echo.
        echo 설정을 취소했습니다.
        pause
        exit /b 0
    )
)

echo.
echo Supabase 프로젝트 정보를 입력하세요.
echo.

REM Supabase URL 입력
set /p supabase_url="Supabase URL: "
if "%supabase_url%"=="" (
    echo [에러] Supabase URL은 필수입니다.
    pause
    exit /b 1
)

REM Supabase Anon Key 입력
set /p supabase_key="Supabase Anon Key: "
if "%supabase_key%"=="" (
    echo [에러] Supabase Anon Key는 필수입니다.
    pause
    exit /b 1
)

REM .env 파일 생성
(
    echo # Supabase 설정
    echo SUPABASE_URL=%supabase_url%
    echo SUPABASE_ANON_KEY=%supabase_key%
    echo.
    echo # 환경 설정
    echo ENVIRONMENT=development
) > .env

echo.
echo ================================
echo   .env 파일이 생성되었습니다!
echo ================================
echo.
echo 파일 위치: %cd%\.env
echo.
echo [중요] .env 파일은 절대 GitHub에 커밋하지 마세요!
echo        (.gitignore에 이미 추가되어 있습니다)
echo.

pause
