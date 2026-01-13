# Uncany 수동 설정 가이드

## 현재 완료된 것들

| 항목 | 상태 | 비고 |
|------|------|------|
| GitHub Secrets 설정 | ✅ | SUPABASE_URL, ANON_KEY, NEIS_API_KEY, FIREBASE_SERVICE_ACCOUNT |
| 마이그레이션 SQL 작성 | ✅ | 001~005.sql 파일 존재 |
| Edge Functions 코드 작성 | ✅ | neis-api, delete-account |
| 모바일 설정 파일 | ✅ | AndroidManifest.xml, Info.plist 적용됨 |
| Firebase Web 배포 | ✅ | https://uncany-staging.web.app |

---

## 당신이 해야 할 수동 작업

### 1. Supabase CLI 설치 (필수)

Edge Functions 배포를 위해 필요합니다.

**Windows (PowerShell 관리자 권한):**
```powershell
# Scoop 설치 (없으면)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Supabase CLI 설치
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

**또는 npm으로 설치:**
```bash
npm install -g supabase
```

**설치 확인:**
```bash
supabase --version
```

---

### 2. Supabase 프로젝트 연결

```bash
# 프로젝트 폴더에서 실행
cd C:\Users\임현우\.claude-worktrees\Uncany\exciting-margulis

# Supabase 로그인
supabase login

# 프로젝트 연결 (Staging 프로젝트 ID 입력)
supabase link --project-ref YOUR_PROJECT_REF
```

**프로젝트 ID 확인 방법:**
1. https://supabase.com/dashboard 접속
2. 프로젝트 선택
3. Settings → General → Reference ID 복사

---

### 3. DB 마이그레이션 적용 (중요!)

```bash
# 마이그레이션 상태 확인
supabase db remote commit

# 마이그레이션 적용
supabase db push
```

**또는 Supabase Dashboard에서 직접 실행:**
1. https://supabase.com/dashboard → SQL Editor
2. `supabase/migrations/` 폴더의 SQL 파일들을 순서대로 실행:
   - 001_initial_schema.sql
   - 002_schools_and_multitenancy.sql
   - 003_fix_rls_and_add_periods.sql
   - 004_production_ready_security.sql
   - 005_fix_critical_vulnerabilities.sql

---

### 4. Edge Functions 배포 (중요!)

```bash
# Supabase Secrets 설정 (Edge Functions용)
supabase secrets set NEIS_API_KEY="발급받은_나이스_API_키"

# Edge Functions 배포
supabase functions deploy neis-api
supabase functions deploy delete-account
```

**배포 확인:**
```bash
supabase functions list
```

---

### 5. Storage 버킷 생성

**Supabase Dashboard에서:**
1. Storage → New bucket
2. 버킷 이름: `verification-documents`
3. Public: OFF (비공개)
4. RLS: ON

**RLS 정책 추가 (SQL Editor에서):**
```sql
-- 본인 파일만 업로드 가능
CREATE POLICY "Users can upload their own documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'verification-documents' AND (storage.foldername(name))[1] = auth.uid()::text);

-- 본인 파일만 조회 가능
CREATE POLICY "Users can view their own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'verification-documents' AND (storage.foldername(name))[1] = auth.uid()::text);

-- 관리자는 모든 파일 조회 가능
CREATE POLICY "Admins can view all documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'verification-documents'
  AND EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
```

---

### 6. SHA-1 키 등록 (Android Google 로그인용) - 나중에

**Android 앱 빌드 후:**
```bash
cd android
./gradlew signingReport
```

**출력된 SHA-1 키를:**
1. Supabase Dashboard → Authentication → Providers → Google
2. SHA-1 입력란에 붙여넣기

---

## 확인 체크리스트

Staging 테스트 전 확인:

- [ ] Supabase CLI 설치됨
- [ ] `supabase link` 완료
- [ ] DB 마이그레이션 적용됨 (5개 파일)
- [ ] Edge Functions 배포됨 (neis-api, delete-account)
- [ ] Storage 버킷 생성됨 (verification-documents)

---

## 문제 발생 시

### "마이그레이션 충돌" 오류
```bash
supabase db reset  # 주의: 모든 데이터 삭제됨
supabase db push
```

### Edge Function 배포 실패
```bash
# 로그 확인
supabase functions logs neis-api

# 재배포
supabase functions deploy neis-api --no-verify-jwt
```

### Storage 권한 오류
Dashboard → Storage → Policies에서 RLS 정책 확인

---

## 현재 앱 상태

**작동하는 기능:**
- 로그인/회원가입 (이메일)
- 학교 검색 (클라이언트 샘플 데이터)
- 승인 대기 온보딩

**Edge Functions 배포 후 작동:**
- 학교 검색 (NEIS API 실시간)
- 회원 탈퇴

**미구현:**
- 푸시 알림 (FCM)
- Google 로그인 (SHA-1 등록 필요)
