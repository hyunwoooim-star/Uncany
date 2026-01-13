# Uncany 로컬 개발 환경 설정 스크립트 (PowerShell)

Write-Host "===== Uncany 로컬 개발 환경 설정 =====" -ForegroundColor Cyan
Write-Host ""

# 1. Git Pull
Write-Host "📥 [1/5] 최신 코드 가져오는 중..." -ForegroundColor Yellow
git fetch origin
git pull origin claude/load-progress-checkpoint-EzHEV
Write-Host "✅ Git Pull 완료" -ForegroundColor Green
Write-Host ""

# 2. Flutter 의존성 설치
Write-Host "📦 [2/5] Flutter 패키지 설치 중..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ 패키지 설치 완료" -ForegroundColor Green
Write-Host ""

# 3. 코드 생성
Write-Host "🔧 [3/5] 코드 자동 생성 중..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs
Write-Host "✅ 코드 생성 완료" -ForegroundColor Green
Write-Host ""

# 4. 환경변수 확인
Write-Host "🔍 [4/5] 환경변수 확인 중..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env 파일이 없습니다!" -ForegroundColor Red
    Write-Host "   다음 내용으로 .env 파일을 생성하세요:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   SUPABASE_URL=your_supabase_url"
    Write-Host "   SUPABASE_ANON_KEY=your_supabase_anon_key"
    Write-Host ""
} else {
    Write-Host "✅ .env 파일 존재" -ForegroundColor Green
}
Write-Host ""

# 5. 분석
Write-Host "🔎 [5/5] 코드 분석 중..." -ForegroundColor Yellow
flutter analyze lib --no-fatal-infos
Write-Host ""

Write-Host "===== 설정 완료! =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 실행 명령어:" -ForegroundColor Green
Write-Host "   .\run-local.ps1"
Write-Host ""
