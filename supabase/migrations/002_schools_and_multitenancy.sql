-- ====================================
-- Uncany v0.2: 학교 기반 멀티테넌시
-- ====================================

-- 1. 학교 테이블 생성
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,                    -- 학교명 (예: 나진초등학교)
  address TEXT,                          -- 주소
  type TEXT DEFAULT 'elementary',        -- 학교 유형 (elementary/middle/high)
  education_office TEXT REFERENCES education_offices(code),
  neis_code TEXT UNIQUE,                 -- 나이스 학교 코드 (공공데이터 연동용)
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. users 테이블 수정
ALTER TABLE users
  ADD COLUMN school_id UUID REFERENCES schools(id),
  ADD COLUMN grade INT,                  -- 담당 학년 (1~6)
  ADD COLUMN class_num INT,              -- 담당 반 (1~10 등)
  ADD COLUMN username TEXT UNIQUE;       -- 로그인용 아이디

-- 3. classrooms 테이블 수정
ALTER TABLE classrooms
  ADD COLUMN school_id UUID REFERENCES schools(id),
  ADD COLUMN room_type TEXT DEFAULT 'other',  -- 교실 유형
  ADD COLUMN period_settings JSONB,           -- 커스텀 교시 시간
  ADD COLUMN created_by UUID REFERENCES users(id);

-- 교실 유형 제약조건
ALTER TABLE classrooms
  ADD CONSTRAINT valid_room_type CHECK (
    room_type IN (
      'computer',      -- 컴퓨터실
      'music',         -- 음악실
      'science',       -- 과학실
      'art',           -- 미술실
      'library',       -- 도서실
      'gym',           -- 체육관
      'auditorium',    -- 강당
      'special',       -- 특별실
      'other'          -- 기타
    )
  );

-- 4. reservations 테이블 수정
ALTER TABLE reservations
  ADD COLUMN periods INT[];              -- 예약된 교시 배열 [1,2,3]

-- 5. 기본 교시 시간 설정 테이블 (전역)
CREATE TABLE default_period_settings (
  id SERIAL PRIMARY KEY,
  period_number INT NOT NULL UNIQUE,     -- 교시 번호 (1~10)
  start_time TIME NOT NULL,              -- 시작 시간
  end_time TIME NOT NULL,                -- 종료 시간
  label TEXT                             -- 표시명 (예: "1교시")
);

-- 기본 교시 시간 데이터 (50분 수업 + 10분 쉬는시간)
INSERT INTO default_period_settings (period_number, start_time, end_time, label) VALUES
  (1, '09:00', '09:50', '1교시'),
  (2, '10:00', '10:50', '2교시'),
  (3, '11:00', '11:50', '3교시'),
  (4, '12:00', '12:50', '4교시'),
  (5, '14:00', '14:50', '5교시'),   -- 점심시간 후
  (6, '15:00', '15:50', '6교시'),
  (7, '16:00', '16:50', '7교시'),
  (8, '17:00', '17:50', '8교시'),
  (9, '18:00', '18:50', '9교시'),
  (10, '19:00', '19:50', '10교시');

-- ====================================
-- 인덱스 추가
-- ====================================

CREATE INDEX idx_users_school ON users(school_id);
CREATE INDEX idx_classrooms_school ON classrooms(school_id);
CREATE INDEX idx_schools_name ON schools(name);
CREATE INDEX idx_schools_neis ON schools(neis_code);

-- ====================================
-- RLS 정책 업데이트 (학교별 격리)
-- ====================================

-- 기존 정책 삭제
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON users;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON classrooms;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON reservations;

-- 학교 테이블 RLS
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Schools are readable by all authenticated users"
  ON schools FOR SELECT
  USING (auth.role() = 'authenticated');

-- 사용자 테이블 RLS (같은 학교만)
CREATE POLICY "Users can read users from same school"
  ON users FOR SELECT
  USING (
    auth.role() = 'authenticated' AND (
      school_id IS NULL OR
      school_id = (SELECT school_id FROM users WHERE id = auth.uid())
    )
  );

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (id = auth.uid());

-- 교실 테이블 RLS (같은 학교만)
CREATE POLICY "Users can read classrooms from same school"
  ON classrooms FOR SELECT
  USING (
    auth.role() = 'authenticated' AND (
      school_id IS NULL OR
      school_id = (SELECT school_id FROM users WHERE id = auth.uid())
    )
  );

CREATE POLICY "Users can create classrooms for their school"
  ON classrooms FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    school_id = (SELECT school_id FROM users WHERE id = auth.uid())
  );

CREATE POLICY "Users can update classrooms from same school"
  ON classrooms FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    school_id = (SELECT school_id FROM users WHERE id = auth.uid())
  );

CREATE POLICY "Users can delete classrooms from same school"
  ON classrooms FOR DELETE
  USING (
    auth.role() = 'authenticated' AND
    school_id = (SELECT school_id FROM users WHERE id = auth.uid())
  );

-- 예약 테이블 RLS (같은 학교만)
CREATE POLICY "Users can read reservations from same school classrooms"
  ON reservations FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    classroom_id IN (
      SELECT id FROM classrooms
      WHERE school_id = (SELECT school_id FROM users WHERE id = auth.uid())
    )
  );

CREATE POLICY "Users can create reservations"
  ON reservations FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    teacher_id = auth.uid() AND
    classroom_id IN (
      SELECT id FROM classrooms
      WHERE school_id = (SELECT school_id FROM users WHERE id = auth.uid())
    )
  );

CREATE POLICY "Users can update own reservations"
  ON reservations FOR UPDATE
  USING (teacher_id = auth.uid());

CREATE POLICY "Users can delete own reservations"
  ON reservations FOR DELETE
  USING (teacher_id = auth.uid());

-- 기본 교시 설정 RLS (읽기만)
ALTER TABLE default_period_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Period settings are readable by all"
  ON default_period_settings FOR SELECT
  USING (auth.role() = 'authenticated');

-- ====================================
-- 완료!
-- ====================================
