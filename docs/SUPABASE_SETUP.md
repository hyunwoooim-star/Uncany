# Supabase 설정 가이드

> **목표**: Uncany 프로젝트용 Supabase 프로젝트 생성 및 초기 설정

---

## 1️⃣ Supabase 계정 생성

### 단계별 가이드

1. **Supabase 웹사이트 접속**
   - URL: https://supabase.com
   - 우측 상단 "Start your project" 클릭

2. **계정 생성**
   - GitHub 계정으로 로그인 (권장)
   - 또는 이메일로 회원가입

3. **이메일 인증**
   - 가입 후 받은 인증 메일 클릭

---

## 2️⃣ 새 프로젝트 생성

### 프로젝트 설정

1. **"New Project" 클릭**

2. **프로젝트 정보 입력**
   ```
   Name: uncany-prod
   Database Password: [강력한 비밀번호 생성]
   Region: Northeast Asia (Seoul) - ap-northeast-2
   Pricing Plan: Free (무료)
   ```

3. **"Create new project" 클릭**
   - 약 2분 정도 소요됩니다

---

## 3️⃣ 프로젝트 Credentials 확인

### API Keys 복사

프로젝트 생성 완료 후:

1. **좌측 사이드바 → Settings → API** 클릭

2. **다음 정보 복사**
   ```
   Project URL: https://xxxxxxxxxxxxx.supabase.co
   anon/public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **프로젝트 루트에 `.env` 파일 생성**
   ```bash
   # .env 파일 생성
   cp .env.example .env
   ```

4. **`.env` 파일 수정**
   ```env
   SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

   APP_NAME=Uncany
   APP_VERSION=0.1.0
   ENVIRONMENT=development
   ```

---

## 4️⃣ 데이터베이스 초기 설정

### SQL 에디터에서 실행

1. **좌측 사이드바 → SQL Editor** 클릭

2. **새 쿼리 생성** (New Query)

3. **아래 스크립트 복사 후 실행**

```sql
-- ====================================
-- Uncany 데이터베이스 초기 스키마
-- ====================================

-- 1. 교육청 정보 테이블
CREATE TABLE education_offices (
  code TEXT PRIMARY KEY,
  name_ko TEXT NOT NULL,
  email_domain TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 사용자 (교사) 테이블
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE,
  name TEXT NOT NULL,
  school_name TEXT NOT NULL,
  education_office TEXT REFERENCES education_offices(code),
  role TEXT CHECK (role IN ('teacher', 'admin')) DEFAULT 'teacher',

  -- 인증 상태
  verification_status TEXT CHECK (verification_status IN (
    'pending', 'approved', 'rejected'
  )) DEFAULT 'pending',
  verification_document_url TEXT,
  rejected_reason TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL
);

-- 3. 추천인 코드 테이블 (같은 학교 제약)
CREATE TABLE referral_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE, -- 6자리 코드 (예: "ABC123")

  created_by UUID NOT NULL REFERENCES users(id),
  school_name TEXT NOT NULL, -- 생성자의 학교명 (검증용)

  max_uses INT DEFAULT 5, -- 최대 사용 횟수
  current_uses INT DEFAULT 0,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),

  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 추천 사용 이력
CREATE TABLE referral_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referral_code_id UUID NOT NULL REFERENCES referral_codes(id),
  used_by UUID NOT NULL REFERENCES users(id),
  used_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. 교실 테이블
CREATE TABLE classrooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,

  -- 비밀번호 보호 (선택)
  access_code_hash TEXT NULL,

  -- 공지사항
  notice_message TEXT,
  notice_updated_at TIMESTAMPTZ,

  capacity INT,
  location TEXT,
  is_active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL
);

-- 6. 예약 테이블
CREATE TABLE reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  classroom_id UUID NOT NULL REFERENCES classrooms(id),
  teacher_id UUID NOT NULL REFERENCES users(id),

  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  title TEXT,
  description TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL,

  CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- 7. 감사 로그 테이블
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,

  operation TEXT CHECK (operation IN (
    'INSERT', 'UPDATE', 'DELETE', 'RESTORE'
  )) NOT NULL,

  user_id UUID REFERENCES users(id),

  old_snapshot JSONB,
  new_snapshot JSONB,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================
-- 인덱스 생성
-- ====================================

-- 활성 예약 조회용
CREATE INDEX idx_active_reservations
ON reservations(classroom_id, start_time, end_time)
WHERE deleted_at IS NULL;

-- 감사 로그 조회용
CREATE INDEX idx_audit_record
ON audit_logs(table_name, record_id);

-- 추천 코드 조회용
CREATE INDEX idx_active_referral_codes
ON referral_codes(code, is_active)
WHERE is_active = TRUE;

-- ====================================
-- Row Level Security (RLS) 기본 설정
-- ====================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_codes ENABLE ROW LEVEL SECURITY;

-- 기본 정책 (임시 - 나중에 세분화)
CREATE POLICY "Enable read access for authenticated users" ON users
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable all access for authenticated users" ON classrooms
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Enable all access for authenticated users" ON reservations
  FOR ALL USING (auth.role() = 'authenticated');

-- ====================================
-- 초기 데이터: 17개 교육청
-- ====================================

INSERT INTO education_offices (code, name_ko, email_domain) VALUES
  ('seoul', '서울특별시교육청', 'sen.go.kr'),
  ('busan', '부산광역시교육청', 'pen.go.kr'),
  ('daegu', '대구광역시교육청', 'dge.go.kr'),
  ('incheon', '인천광역시교육청', 'ice.go.kr'),
  ('gwangju', '광주광역시교육청', 'gen.go.kr'),
  ('daejeon', '대전광역시교육청', 'dje.go.kr'),
  ('ulsan', '울산광역시교육청', 'use.go.kr'),
  ('sejong', '세종특별자치시교육청', 'sje.go.kr'),
  ('gyeonggi', '경기도교육청', 'goe.go.kr'),
  ('gangwon', '강원도교육청', 'kwe.go.kr'),
  ('chungbuk', '충청북도교육청', 'cbe.go.kr'),
  ('chungnam', '충청남도교육청', 'cne.go.kr'),
  ('jeonbuk', '전라북도교육청', 'jbe.go.kr'),
  ('jeonnam', '전라남도교육청', 'jne.go.kr'),
  ('gyeongbuk', '경상북도교육청', 'gbe.go.kr'),
  ('gyeongnam', '경상남도교육청', 'gne.go.kr'),
  ('jeju', '제주특별자치도교육청', 'jje.go.kr');

-- ====================================
-- 완료!
-- ====================================

-- 테스트 쿼리
SELECT * FROM education_offices;
```

4. **"Run" 버튼 클릭** 또는 `Ctrl+Enter`

5. **결과 확인**
   - 성공 메시지 확인
   - 17개 교육청 데이터 조회 확인

---

## 5️⃣ Storage 설정 (파일 업로드용)

### 재직증명서 업로드용 버킷 생성

1. **좌측 사이드바 → Storage** 클릭

2. **"Create a new bucket"** 클릭

3. **버킷 설정**
   ```
   Name: verification-documents
   Public bucket: OFF (비공개)
   ```

4. **정책 설정 (RLS)**
   - **Policies → New Policy → Custom**
   - 아래 정책 추가:

   ```sql
   -- 관리자만 조회 가능
   CREATE POLICY "Admins can view verification documents"
   ON storage.objects FOR SELECT
   USING (
     bucket_id = 'verification-documents'
     AND auth.jwt() ->> 'role' = 'admin'
   );

   -- 인증된 사용자는 자신의 문서만 업로드
   CREATE POLICY "Users can upload their own documents"
   ON storage.objects FOR INSERT
   WITH CHECK (
     bucket_id = 'verification-documents'
     AND auth.role() = 'authenticated'
   );
   ```

---

## 6️⃣ Authentication 설정

### 이메일 인증 활성화

1. **좌측 사이드바 → Authentication → Providers** 클릭

2. **Email 토글 ON**

3. **"Confirm email" 옵션 활성화**

---

## 7️⃣ 환경 변수 최종 확인

### `.env` 파일 체크리스트

```env
✅ SUPABASE_URL=https://xxxxx.supabase.co
✅ SUPABASE_ANON_KEY=eyJhbG...
✅ SUPABASE_SERVICE_ROLE_KEY=eyJhbG...
✅ APP_NAME=Uncany
✅ ENVIRONMENT=development
```

---

## 8️⃣ 연결 테스트

### Supabase CLI로 로컬 확인 (선택)

```bash
# Supabase CLI 설치 (한 번만)
npm install -g supabase

# 로그인
supabase login

# 프로젝트 링크
supabase link --project-ref xxxxxxxxxxxxx
```

---

## ✅ 완료 체크리스트

- [ ] Supabase 계정 생성
- [ ] 프로젝트 생성 (`uncany-prod`)
- [ ] `.env` 파일 설정
- [ ] 데이터베이스 스키마 실행
- [ ] Storage 버킷 생성 (`verification-documents`)
- [ ] 17개 교육청 데이터 확인

---

## 🔜 다음 단계

완료되면:
1. Flutter 프로젝트 생성
2. `supabase_flutter` 패키지 연동
3. 연결 테스트

---

**예상 소요 시간**: 15-20분
**비용**: 무료 (Free Plan)
