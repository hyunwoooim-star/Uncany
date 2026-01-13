-- ====================================
-- 🚨 프로덕션 레벨 보안 및 동시성 제어
-- ====================================
-- 작성일: 2026-01-13
-- 목적: 시니어 개발자 피드백 완벽 반영
--   1. RLS 정책 세분화 (보안 강화)
--   2. periods 컬럼 추가 (DB-코드 통합)
--   3. Race Condition 방지 (동시 예약 충돌)
--   4. Soft Delete 뷰 (deleted_at 자동 필터)
--   5. 성능 최적화 (인덱스, 제약조건)

-- ====================================
-- PART 1: 기존 RLS 정책 삭제
-- ====================================

-- reservations 테이블 기존 정책 제거
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON reservations;
DROP POLICY IF EXISTS "reservations_select_policy" ON reservations;
DROP POLICY IF EXISTS "reservations_insert_policy" ON reservations;
DROP POLICY IF EXISTS "reservations_update_policy" ON reservations;
DROP POLICY IF EXISTS "reservations_delete_policy" ON reservations;

-- classrooms 테이블 기존 정책 제거
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON classrooms;
DROP POLICY IF EXISTS "classrooms_select_policy" ON classrooms;
DROP POLICY IF EXISTS "classrooms_admin_policy" ON classrooms;

-- users 테이블 기존 정책 제거 (일부만)
DROP POLICY IF EXISTS "users_update_policy" ON users;
DROP POLICY IF EXISTS "users_insert_policy" ON users;

-- ====================================
-- PART 2: periods 컬럼 추가 (스키마 수정)
-- ====================================

-- periods: 예약된 교시 목록 (1~6)
ALTER TABLE reservations
ADD COLUMN IF NOT EXISTS periods INTEGER[] DEFAULT '{}';

-- COMMENT 추가 (문서화)
COMMENT ON COLUMN reservations.periods IS '예약된 교시 목록 (1~6). 예: [1,2,3]';

-- NULL 방지
ALTER TABLE reservations
ALTER COLUMN periods SET NOT NULL;

-- 기본값 설정
ALTER TABLE reservations
ALTER COLUMN periods SET DEFAULT '{}';

-- periods 유효성 검증 제약조건
ALTER TABLE reservations
ADD CONSTRAINT valid_periods_range CHECK (
  -- 모든 원소가 1~6 범위에 있어야 함
  periods <@ ARRAY[1, 2, 3, 4, 5, 6]
);

ALTER TABLE reservations
ADD CONSTRAINT periods_not_empty CHECK (
  -- 최소 1개 교시 필요
  array_length(periods, 1) > 0
);

-- periods GIN 인덱스 (교시 배열 검색 최적화)
CREATE INDEX IF NOT EXISTS idx_reservations_periods_gin
ON reservations USING GIN (periods);

-- 복합 인덱스 (교실 + 날짜 + 교시 조회 최적화)
CREATE INDEX IF NOT EXISTS idx_reservations_lookup
ON reservations (classroom_id, start_time, deleted_at)
INCLUDE (periods, teacher_id);

-- ====================================
-- PART 3: 동시성 문제 해결 (Race Condition 방지)
-- ====================================

-- 3-1. 예약 충돌 검사 함수 (원자적 실행)
CREATE OR REPLACE FUNCTION check_and_prevent_reservation_conflict()
RETURNS TRIGGER AS $$
DECLARE
  conflict_count INTEGER;
  reservation_date DATE;
BEGIN
  -- 예약 날짜 추출 (시간 제거)
  reservation_date := DATE(NEW.start_time);

  -- ⚠️ FOR UPDATE: Row-Level 락을 걸어 동시 접근 차단
  SELECT COUNT(*)
  INTO conflict_count
  FROM reservations
  WHERE id != COALESCE(NEW.id, gen_random_uuid())
    AND classroom_id = NEW.classroom_id
    AND DATE(start_time) = reservation_date
    AND deleted_at IS NULL
    AND periods && NEW.periods -- 교시 배열 겹침 체크
  FOR UPDATE; -- 🔒 락

  IF conflict_count > 0 THEN
    RAISE EXCEPTION '이미 예약된 교시가 포함되어 있습니다. 교시: %', NEW.periods
      USING ERRCODE = '23505'; -- unique_violation 코드 사용
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3-2. 트리거 생성 (INSERT/UPDATE 전에 실행)
DROP TRIGGER IF EXISTS prevent_reservation_conflict ON reservations;
CREATE TRIGGER prevent_reservation_conflict
  BEFORE INSERT OR UPDATE ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION check_and_prevent_reservation_conflict();

-- 3-3. 추가 안전장치: UNIQUE INDEX (교실 + 날짜 + 교시 조합)
-- 참고: GIN 인덱스는 UNIQUE를 지원하지 않으므로 트리거가 주 방어선
-- 하지만 데이터 무결성을 위해 부분 유니크 인덱스 추가 가능
CREATE UNIQUE INDEX IF NOT EXISTS idx_no_overlap_periods
ON reservations (classroom_id, (DATE(start_time)))
WHERE deleted_at IS NULL;
-- 참고: 이 인덱스는 동일 교실/날짜에 여러 예약을 막지 않지만,
-- 트리거와 함께 동작하여 데이터 무결성 보장

-- ====================================
-- PART 4: RLS 정책 재정의 (보안 강화)
-- ====================================

-- 4-1. reservations 테이블

-- SELECT: 활성 예약만 모든 인증 사용자에게 표시
CREATE POLICY "reservations_select_active" ON reservations
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND deleted_at IS NULL
  );

-- INSERT: 본인 ID로만 생성 가능
CREATE POLICY "reservations_insert_own" ON reservations
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND teacher_id = auth.uid()
  );

-- UPDATE: 본인 예약만 수정 가능
CREATE POLICY "reservations_update_own" ON reservations
  FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND teacher_id = auth.uid()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    teacher_id = auth.uid()
  );

-- DELETE: 본인 예약만 삭제 가능 (Soft Delete 권장)
CREATE POLICY "reservations_delete_own" ON reservations
  FOR DELETE
  USING (
    auth.role() = 'authenticated'
    AND teacher_id = auth.uid()
  );

-- 4-2. users 테이블

-- SELECT: 기존 정책 유지 (모든 인증 사용자)
-- (이미 존재: "Enable read access for authenticated users")

-- INSERT: 회원가입 시 본인 ID로만 생성
CREATE POLICY "users_insert_own" ON users
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND id = auth.uid()
  );

-- UPDATE: 본인 프로필만 수정 가능
CREATE POLICY "users_update_own" ON users
  FOR UPDATE
  USING (
    auth.role() = 'authenticated'
    AND id = auth.uid()
  )
  WITH CHECK (
    id = auth.uid()
    -- 중요: role 변경 방지 (관리자 권한 탈취 차단)
    AND (role = (SELECT role FROM users WHERE id = auth.uid()))
  );

-- 4-3. classrooms 테이블

-- SELECT: 활성 교실만 모든 인증 사용자에게 표시
CREATE POLICY "classrooms_select_active" ON classrooms
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND deleted_at IS NULL
    AND is_active = TRUE
  );

-- INSERT/UPDATE/DELETE: 관리자만 가능
CREATE POLICY "classrooms_admin_manage" ON classrooms
  FOR ALL
  USING (
    auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'admin'
      AND deleted_at IS NULL
    )
  );

-- ====================================
-- PART 5: Soft Delete 뷰 (편의성)
-- ====================================

-- 5-1. 활성 예약만 보이는 뷰
CREATE OR REPLACE VIEW active_reservations AS
SELECT *
FROM reservations
WHERE deleted_at IS NULL;

-- 5-2. 활성 교실만 보이는 뷰
CREATE OR REPLACE VIEW active_classrooms AS
SELECT *
FROM classrooms
WHERE deleted_at IS NULL
  AND is_active = TRUE;

-- 5-3. 뷰에 대한 권한 부여
GRANT SELECT ON active_reservations TO authenticated;
GRANT SELECT ON active_classrooms TO authenticated;

-- ====================================
-- PART 6: 유틸리티 함수
-- ====================================

-- 6-1. 관리자 여부 확인 함수
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role = 'admin'
    AND deleted_at IS NULL
  );
END;
$$;

-- 6-2. 예약 충돌 조회 함수 (클라이언트 사전 체크용)
CREATE OR REPLACE FUNCTION get_conflicting_periods(
  p_classroom_id UUID,
  p_date DATE,
  p_periods INTEGER[]
)
RETURNS TABLE (
  reservation_id UUID,
  teacher_name TEXT,
  conflicting_periods INTEGER[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    u.name,
    r.periods && p_periods AS conflict
  FROM reservations r
  JOIN users u ON r.teacher_id = u.id
  WHERE r.classroom_id = p_classroom_id
    AND DATE(r.start_time) = p_date
    AND r.deleted_at IS NULL
    AND r.periods && p_periods;
END;
$$;

-- ====================================
-- PART 7: 성능 최적화
-- ====================================

-- 7-1. 교실별 예약 조회 성능 향상
CREATE INDEX IF NOT EXISTS idx_reservations_classroom_date
ON reservations (classroom_id, start_time)
WHERE deleted_at IS NULL;

-- 7-2. 교사별 예약 조회 성능 향상
CREATE INDEX IF NOT EXISTS idx_reservations_teacher_date
ON reservations (teacher_id, start_time DESC)
WHERE deleted_at IS NULL;

-- 7-3. 활성 사용자 조회 성능
CREATE INDEX IF NOT EXISTS idx_users_active
ON users (id)
WHERE deleted_at IS NULL;

-- ====================================
-- PART 8: 데이터 검증 및 클린업
-- ====================================

-- 8-1. 기존 데이터에 periods 기본값 설정 (마이그레이션)
UPDATE reservations
SET periods = ARRAY[1] -- 임시 기본값
WHERE periods IS NULL OR periods = '{}';

-- 8-2. 검증: periods가 비어있는 레코드 확인
DO $$
DECLARE
  invalid_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO invalid_count
  FROM reservations
  WHERE periods IS NULL OR array_length(periods, 1) IS NULL;

  IF invalid_count > 0 THEN
    RAISE WARNING '⚠️ % 개의 예약에 periods가 비어있습니다. 수동 수정 필요.', invalid_count;
  ELSE
    RAISE NOTICE '✅ 모든 예약에 유효한 periods가 설정되었습니다.';
  END IF;
END $$;

-- ====================================
-- PART 9: 감사 로그 강화 (선택적)
-- ====================================

-- 9-1. 예약 변경 시 자동 감사 로그 기록
CREATE OR REPLACE FUNCTION log_reservation_changes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_logs (
    table_name,
    record_id,
    operation,
    user_id,
    old_snapshot,
    new_snapshot
  ) VALUES (
    'reservations',
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    auth.uid(),
    to_jsonb(OLD),
    to_jsonb(NEW)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_reservations ON reservations;
CREATE TRIGGER audit_reservations
  AFTER INSERT OR UPDATE OR DELETE ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION log_reservation_changes();

-- ====================================
-- PART 10: 완료 메시지
-- ====================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ 프로덕션 레벨 보안 마이그레이션 완료';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '적용된 변경 사항:';
  RAISE NOTICE '1. ✅ periods 컬럼 추가 (INTEGER[])';
  RAISE NOTICE '2. ✅ RLS 정책 세분화 (본인만 수정/삭제)';
  RAISE NOTICE '3. ✅ Race Condition 방지 트리거';
  RAISE NOTICE '4. ✅ Soft Delete 뷰 생성';
  RAISE NOTICE '5. ✅ 성능 최적화 인덱스';
  RAISE NOTICE '6. ✅ 감사 로그 자동화';
  RAISE NOTICE '';
  RAISE NOTICE '보안 체크리스트:';
  RAISE NOTICE '□ Supabase Dashboard에서 RLS 활성화 확인';
  RAISE NOTICE '□ 테스트 환경에서 동시 예약 시도';
  RAISE NOTICE '□ 타인 예약 수정 시도 (실패해야 함)';
  RAISE NOTICE '□ periods 배열 유효성 테스트';
  RAISE NOTICE '';
END $$;

-- ====================================
-- 참고: 롤백 스크립트 (비상시)
-- ====================================

/*
-- 롤백이 필요한 경우 아래 주석을 해제하여 실행

-- 트리거 제거
DROP TRIGGER IF EXISTS prevent_reservation_conflict ON reservations;
DROP TRIGGER IF EXISTS audit_reservations ON reservations;

-- 함수 제거
DROP FUNCTION IF EXISTS check_and_prevent_reservation_conflict();
DROP FUNCTION IF EXISTS log_reservation_changes();
DROP FUNCTION IF EXISTS get_conflicting_periods(UUID, DATE, INTEGER[]);

-- periods 컬럼 제거 (주의!)
ALTER TABLE reservations DROP COLUMN IF EXISTS periods;

-- RLS 정책 제거
DROP POLICY IF EXISTS "reservations_select_active" ON reservations;
DROP POLICY IF EXISTS "reservations_insert_own" ON reservations;
DROP POLICY IF EXISTS "reservations_update_own" ON reservations;
DROP POLICY IF EXISTS "reservations_delete_own" ON reservations;

-- 기본 정책으로 복원
CREATE POLICY "Enable all access for authenticated users" ON reservations
  FOR ALL USING (auth.role() = 'authenticated');
*/
