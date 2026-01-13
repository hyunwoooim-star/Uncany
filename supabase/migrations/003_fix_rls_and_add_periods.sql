-- ====================================
-- 🚨 [긴급] RLS 보안 정책 수정 + periods 컬럼 추가
-- ====================================
-- 작성일: 2026-01-13
-- 목적: 시니어 개발자 코드 리뷰 피드백 반영
--   1. reservations 테이블 RLS 정책 세분화 (보안 강화)
--   2. users 테이블 UPDATE 정책 추가
--   3. periods 컬럼 추가 (DB-코드 불일치 해결)

-- ====================================
-- 1. reservations 테이블 RLS 정책 수정
-- ====================================

-- 기존 정책 삭제 (ALL 권한 - 보안 취약)
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON reservations;

-- 새로운 세분화된 정책 생성

-- 1-1. SELECT: 인증된 모든 사용자 조회 가능
CREATE POLICY "reservations_select_policy" ON reservations
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND deleted_at IS NULL
  );

-- 1-2. INSERT: 인증된 사용자만 생성 가능
CREATE POLICY "reservations_insert_policy" ON reservations
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND teacher_id = auth.uid()
  );

-- 1-3. UPDATE: 본인의 예약만 수정 가능
CREATE POLICY "reservations_update_policy" ON reservations
  FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND teacher_id = auth.uid()
  )
  WITH CHECK (
    teacher_id = auth.uid()
  );

-- 1-4. DELETE: 본인의 예약만 삭제 가능 (Soft Delete)
CREATE POLICY "reservations_delete_policy" ON reservations
  FOR DELETE
  USING (
    auth.role() = 'authenticated'
    AND teacher_id = auth.uid()
  );

-- ====================================
-- 2. users 테이블 UPDATE 정책 추가
-- ====================================

-- 2-1. 본인 프로필만 수정 가능
CREATE POLICY "users_update_policy" ON users
  FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND id = auth.uid()
  )
  WITH CHECK (
    id = auth.uid()
  );

-- 2-2. INSERT 정책 (회원가입 시 필요)
CREATE POLICY "users_insert_policy" ON users
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND id = auth.uid()
  );

-- ====================================
-- 3. classrooms 테이블 RLS 정책 세분화
-- ====================================

-- 기존 정책 삭제
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON classrooms;

-- 3-1. SELECT: 인증된 모든 사용자 조회 가능
CREATE POLICY "classrooms_select_policy" ON classrooms
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND deleted_at IS NULL
  );

-- 3-2. INSERT/UPDATE/DELETE: 관리자만 가능
-- 참고: admin 권한은 users 테이블의 role 컬럼으로 확인
CREATE POLICY "classrooms_admin_policy" ON classrooms
  FOR ALL
  USING (
    auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );

-- ====================================
-- 4. reservations 테이블에 periods 컬럼 추가
-- ====================================

-- periods: 예약된 교시 목록 (예: [1, 2, 3])
ALTER TABLE reservations
ADD COLUMN IF NOT EXISTS periods INTEGER[] DEFAULT '{}';

-- periods 컬럼 인덱스 추가 (검색 최적화)
CREATE INDEX IF NOT EXISTS idx_reservations_periods
ON reservations USING GIN (periods);

-- periods 컬럼 제약 조건 추가 (1~6교시만 허용)
ALTER TABLE reservations
ADD CONSTRAINT valid_periods CHECK (
  periods <@ ARRAY[1, 2, 3, 4, 5, 6]
  AND array_length(periods, 1) > 0
);

-- ====================================
-- 5. 예약 충돌 방지 함수 (선택적)
-- ====================================

-- 동일 교실, 동일 날짜, 동일 교시 예약 방지
CREATE OR REPLACE FUNCTION check_reservation_conflict()
RETURNS TRIGGER AS $$
DECLARE
  conflict_count INTEGER;
  reservation_date DATE;
BEGIN
  -- 예약 날짜 추출
  reservation_date := DATE(NEW.start_time);

  -- 충돌 검사
  SELECT COUNT(*)
  INTO conflict_count
  FROM reservations
  WHERE id != COALESCE(NEW.id, gen_random_uuid())
    AND classroom_id = NEW.classroom_id
    AND DATE(start_time) = reservation_date
    AND deleted_at IS NULL
    AND periods && NEW.periods; -- 교시 배열 겹침 체크

  IF conflict_count > 0 THEN
    RAISE EXCEPTION '이미 예약된 교시가 포함되어 있습니다.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
DROP TRIGGER IF EXISTS check_reservation_conflict_trigger ON reservations;
CREATE TRIGGER check_reservation_conflict_trigger
  BEFORE INSERT OR UPDATE ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION check_reservation_conflict();

-- ====================================
-- 6. 관리자 계정 확인용 함수
-- ====================================

-- 현재 사용자가 관리자인지 확인
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ====================================
-- 완료 메시지
-- ====================================

DO $$
BEGIN
  RAISE NOTICE '✅ RLS 정책 수정 완료';
  RAISE NOTICE '✅ periods 컬럼 추가 완료';
  RAISE NOTICE '✅ 예약 충돌 방지 트리거 생성 완료';
  RAISE NOTICE '';
  RAISE NOTICE '변경 사항:';
  RAISE NOTICE '1. reservations: SELECT/INSERT/UPDATE/DELETE 정책 분리';
  RAISE NOTICE '2. users: UPDATE/INSERT 정책 추가 (본인만)';
  RAISE NOTICE '3. classrooms: SELECT(모두) / 관리(admin만) 분리';
  RAISE NOTICE '4. reservations.periods 컬럼 추가 (INTEGER[])';
  RAISE NOTICE '5. 예약 충돌 방지 트리거 추가';
END $$;
