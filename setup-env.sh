#!/bin/bash

echo "================================"
echo "  환경 변수 설정 (.env 생성)"
echo "================================"
echo

# .env 파일이 이미 있는지 확인
if [ -f .env ]; then
    echo "[경고] .env 파일이 이미 존재합니다."
    echo
    read -p "덮어쓰시겠습니까? (y/n): " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo
        echo "설정을 취소했습니다."
        exit 0
    fi
fi

echo
echo "Supabase 프로젝트 정보를 입력하세요."
echo

# Supabase URL 입력
read -p "Supabase URL: " supabase_url
if [ -z "$supabase_url" ]; then
    echo "[에러] Supabase URL은 필수입니다."
    exit 1
fi

# Supabase Anon Key 입력
read -p "Supabase Anon Key: " supabase_key
if [ -z "$supabase_key" ]; then
    echo "[에러] Supabase Anon Key는 필수입니다."
    exit 1
fi

# .env 파일 생성
cat > .env << EOF
# Supabase 설정
SUPABASE_URL=$supabase_url
SUPABASE_ANON_KEY=$supabase_key

# 환경 설정
ENVIRONMENT=development
EOF

echo
echo "================================"
echo "  .env 파일이 생성되었습니다!"
echo "================================"
echo
echo "파일 위치: $(pwd)/.env"
echo
echo "[중요] .env 파일은 절대 GitHub에 커밋하지 마세요!"
echo "       (.gitignore에 이미 추가되어 있습니다)"
echo
