# Uncany 남은 작업 목록

**최종 업데이트**: 2026-01-12 (23:00)

---

## ✅ 방금 완료! (2026-01-12 23:00)

### Database 마이그레이션 적용 완료 🎉

**완료된 마이그레이션**:
1. ✅ `003_add_marketing_consent.sql` - 마케팅 수신동의 컬럼
2. ✅ `004_add_document_auto_delete.sql` - 재직증명서 자동 삭제
3. ✅ `005_add_consent_tracking.sql` - 동의 날짜 추적

**결과**:
- 모든 법률 준수 기능이 정상 작동합니다
- 재직증명서 30일 자동 삭제 활성화
- 약관 동의 날짜 및 버전 추적 활성화
- 마케팅 동의 관리 기능 활성화

---

## 🚨 즉시 필요 (사용자 직접 작업)

### ~~1. Database 마이그레이션 적용~~ ✅ **완료!**

**작업 방법**:

#### 방법 1: Supabase Dashboard (추천)
```
1. https://supabase.com/dashboard 접속
2. Uncany 프로젝트 선택
3. 왼쪽 메뉴: SQL Editor 클릭
4. New Query 클릭
5. 파일 내용 복사 & 붙여넣기
6. Run 클릭
7. 두 번째 파일도 동일하게 진행
```

#### 방법 2: Supabase CLI (로컬)
```bash
# 1. Supabase CLI 설치 (없으면)
npm install -g supabase

# 2. 로그인
supabase login

# 3. 프로젝트 링크
supabase link --project-ref [YOUR_PROJECT_REF]

# 4. 마이그레이션 적용
supabase db push

# 5. 확인
supabase db diff
```

**확인 방법**:
```sql
-- users 테이블에 컬럼이 추가되었는지 확인
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'users'
  AND column_name IN (
    'document_delete_scheduled_at',
    'terms_agreed_at',
    'privacy_agreed_at',
    'terms_version',
    'privacy_version',
    'sensitive_data_agreed_at'
  );
```

---

## 📋 보류 (나중에 처리)

### 2. 사업자등록 및 통신판매업 신고

**상태**: 가이드 문서 작성 완료 (`BUSINESS_REGISTRATION_GUIDE.md`)

**해야 할 일**:
1. 홈택스 → 업종 추가 (721902: 응용 소프트웨어 개발 및 공급업)
2. 김포시청 → 통신판매업 신고 여부 확인 (031-980-2114)
3. 미신고 시 → 김포시청 방문 신고

**타이밍**: 정식 출시 전까지 완료하면 됨 (베타는 현재 상태로 가능)

---

## 🔧 선택적 작업 (필요 시)

### 3. Repository 테스트 Mock 에러 수정

**상태**: 테스트 파일 작성 완료, 컴파일 에러 있음

**에러 내용**:
```
Error: The method 'select' isn't defined for the class 'MockPostgrestClient'
```

**파일**:
- `test/features/auth/data/repositories/auth_repository_test.dart`
- `test/features/auth/data/repositories/user_repository_test.dart`
- `test/features/reservation/data/repositories/reservation_repository_test.dart`

**우선순위**: 낮음 (기능 동작에는 영향 없음)

---

## 📱 향후 계획

### 4. 모바일 앱 준비
- Android/iOS 빌드 환경 구축
- 앱스토어/플레이스토어 등록 준비

### 5. Phase 2 알림 시스템 업그레이드
- Supabase Edge Function 배포
- SendGrid 또는 AWS SES 연동
- SMS 서비스 연동 (선택)
- 상세 계획: `docs/PHASE2_UPGRADE_PLAN.md` 참고

### 6. Production 배포
- 도메인 연결
- HTTPS 설정
- 환경변수 설정

---

## ✅ 최근 완료된 작업 (2026-01-12)

1. ✅ Phase 1 이메일/SMS 수신동의 체크박스
2. ✅ 법률 준수 (CPO 정보, 재직증명서 자동삭제, 동의 추적)
3. ✅ 개인정보 관리 화면 (열람/다운로드/탈퇴/마케팅 동의 철회)
4. ✅ 사업자등록증 분석 및 가이드 작성

---

## 🎯 다음 단계 요약

**지금 바로 할 것**:
1. Database 마이그레이션 적용 (Supabase Dashboard에서)

**나중에 할 것**:
1. 사업자등록 업종 추가 (홈택스, 5분)
2. 통신판매업 신고 확인 (김포시청 전화)

**선택적**:
1. 테스트 코드 에러 수정
2. 모바일 앱 준비
3. Production 배포

---

**가장 중요**: Database 마이그레이션 먼저 적용하세요! 📊
