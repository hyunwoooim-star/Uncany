#!/bin/bash

echo "================================"
echo "  Uncany 로컬 실행 (WSL)"
echo "================================"
echo

# .env 파일 확인
if [ ! -f .env ]; then
    echo "[에러] .env 파일이 없습니다."
    echo
    echo "./setup-env.sh를 먼저 실행하여 환경 변수를 설정하세요."
    echo
    exit 1
fi

# .env 파일에서 환경 변수 읽기
export $(grep -v '^#' .env | xargs)

# 환경 변수 검증
if [ -z "$SUPABASE_URL" ]; then
    echo "[에러] SUPABASE_URL이 설정되지 않았습니다."
    echo
    echo ".env 파일을 확인하세요."
    exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "[에러] SUPABASE_ANON_KEY가 설정되지 않았습니다."
    echo
    echo ".env 파일을 확인하세요."
    exit 1
fi

echo "환경 변수를 불러왔습니다."
echo "- SUPABASE_URL: $SUPABASE_URL"
echo "- ENVIRONMENT: ${ENVIRONMENT:-development}"
echo

# Flutter 실행
echo "Flutter Web을 실행합니다..."
echo

flutter run -d web-server --web-port=3000 \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
    --dart-define=ENVIRONMENT="${ENVIRONMENT:-development}"
