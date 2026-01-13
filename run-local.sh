#!/bin/bash
# Uncany 로컬 실행 스크립트

echo "🚀 Uncany 로컬 실행 중..."
echo ""

# .env 파일 로드 (있으면)
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ .env 파일 로드 완료"
else
    echo "⚠️  .env 파일이 없습니다. 환경변수를 직접 설정해야 합니다."
fi

# Supabase URL 확인
if [ -z "$SUPABASE_URL" ]; then
    echo "❌ SUPABASE_URL 환경변수가 설정되지 않았습니다!"
    exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ SUPABASE_ANON_KEY 환경변수가 설정되지 않았습니다!"
    exit 1
fi

echo "📍 Supabase URL: ${SUPABASE_URL}"
echo "📍 Web Base URL: http://localhost:53104"
echo ""

# Flutter 실행
flutter run -d chrome \
    --dart-define=ENVIRONMENT=development \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
    --dart-define=WEB_BASE_URL=http://localhost:53104
