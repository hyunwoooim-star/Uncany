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

-- 3. 추천인 코드 테이블
CREATE TABLE referral_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,

  created_by UUID NOT NULL REFERENCES users(id),
  school_name TEXT NOT NULL,

  max_uses INT DEFAULT 5,
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
  used_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(used_by)
);

-- 5. 교실 테이블
CREATE TABLE classrooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  access_code_hash TEXT NULL,
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
  operation TEXT CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE', 'RESTORE')) NOT NULL,
  user_id UUID REFERENCES users(id),
  old_snapshot JSONB,
  new_snapshot JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================
-- 인덱스 생성
-- ====================================

CREATE INDEX idx_active_reservations
ON reservations(classroom_id, start_time, end_time)
WHERE deleted_at IS NULL;

CREATE INDEX idx_audit_record
ON audit_logs(table_name, record_id);

CREATE INDEX idx_active_referral_codes
ON referral_codes(code, is_active)
WHERE is_active = TRUE;

-- ====================================
-- Row Level Security (RLS)
-- ====================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_codes ENABLE ROW LEVEL SECURITY;

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

SELECT * FROM education_offices;
