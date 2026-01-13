# Uncany 로컬 실행 스크립트 (PowerShell)

Write-Host "🚀 Uncany 로컬 실행 중..." -ForegroundColor Cyan
Write-Host ""

# .env 파일 로드 (있으면)
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -notmatch "^#" -and $_ -match "=") {
            $name, $value = $_.Split("=", 2)
            Set-Item -Path "env:$name" -Value $value
        }
    }
    Write-Host "✅ .env 파일 로드 완료" -ForegroundColor Green
} else {
    Write-Host "⚠️  .env 파일이 없습니다." -ForegroundColor Red
    Write-Host ""
    Write-Host "프로젝트 루트에 .env 파일을 생성하고 다음 내용을 추가하세요:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "SUPABASE_URL=https://your-project.supabase.co"
    Write-Host "SUPABASE_ANON_KEY=your_anon_key_here"
    Write-Host ""
    exit 1
}

# 환경변수 확인
if (-not $env:SUPABASE_URL) {
    Write-Host "❌ SUPABASE_URL 환경변수가 설정되지 않았습니다!" -ForegroundColor Red
    exit 1
}

if (-not $env:SUPABASE_ANON_KEY) {
    Write-Host "❌ SUPABASE_ANON_KEY 환경변수가 설정되지 않았습니다!" -ForegroundColor Red
    exit 1
}

Write-Host "📍 Supabase URL: $env:SUPABASE_URL" -ForegroundColor Cyan
Write-Host "📍 Web Base URL: http://localhost:53104" -ForegroundColor Cyan
Write-Host ""

# Flutter 실행
flutter run -d chrome `
    --dart-define=ENVIRONMENT=development `
    --dart-define=SUPABASE_URL=$env:SUPABASE_URL `
    --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY `
    --dart-define=WEB_BASE_URL=http://localhost:53104
