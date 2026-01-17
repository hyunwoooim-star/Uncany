-- ====================================
-- 예약 취소 정책 서버 단 검증
-- ====================================
-- 작성일: 2026-01-17
-- 목적: Gemini 피드백 반영 - 취소 정책 서버 단 검증
--   1. 예약 시작 10분 전까지만 취소 가능 (Soft Delete)
--   2. RLS UPDATE 정책에 시간 제한 추가

-- ====================================
-- PART 1: 취소 가능 여부 검증 함수
-- ====================================

-- 예약 취소 가능 여부 확인 함수
CREATE OR REPLACE FUNCTION is_reservation_cancellable(reservation_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  reservation_start_time TIMESTAMPTZ;
  cancellation_deadline TIMESTAMPTZ;
  reservation_deleted_at TIMESTAMPTZ;
BEGIN
  -- 예약 정보 조회
  SELECT start_time, deleted_at
  INTO reservation_start_time, reservation_deleted_at
  FROM reservations
  WHERE id = reservation_id;

  -- 예약이 없으면 false
  IF reservation_start_time IS NULL THEN
    RETURN FALSE;
  END IF;

  -- 이미 삭제된 예약이면 false
  IF reservation_deleted_at IS NOT NULL THEN
    RETURN FALSE;
  END IF;

  -- 취소 마감 시간: 시작 10분 전
  cancellation_deadline := reservation_start_time - INTERVAL '10 minutes';

  -- 현재 시간이 마감 전이면 true
  RETURN NOW() < cancellation_deadline;
END;
$$;

COMMENT ON FUNCTION is_reservation_cancellable(UUID) IS
'예약 취소 가능 여부 확인 (시작 10분 전까지만 가능)';

-- ====================================
-- PART 2: Soft Delete 시 시간 검증 트리거
-- ====================================

-- 취소(Soft Delete) 시 시간 검증 함수
CREATE OR REPLACE FUNCTION validate_reservation_cancellation()
RETURNS TRIGGER AS $$
BEGIN
  -- deleted_at이 NULL에서 값으로 변경되는 경우 (취소 시도)
  IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    -- 취소 가능 시간 검증
    IF NOW() >= OLD.start_time - INTERVAL '10 minutes' THEN
      RAISE EXCEPTION '예약 시작 10분 전부터는 취소할 수 없습니다'
        USING ERRCODE = 'P0001',
              HINT = '예약 시작 시간: ' || OLD.start_time::text;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
DROP TRIGGER IF EXISTS enforce_cancellation_policy ON reservations;
CREATE TRIGGER enforce_cancellation_policy
  BEFORE UPDATE ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION validate_reservation_cancellation();

COMMENT ON TRIGGER enforce_cancellation_policy ON reservations IS
'예약 취소 시 10분 전 정책 강제 (서버 단 검증)';

-- ====================================
-- PART 3: 완료 메시지
-- ====================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ 예약 취소 정책 서버 단 검증 추가 완료';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '적용된 변경 사항:';
  RAISE NOTICE '1. ✅ is_reservation_cancellable() 함수 생성';
  RAISE NOTICE '2. ✅ validate_reservation_cancellation() 트리거 생성';
  RAISE NOTICE '3. ✅ 취소 시 시작 10분 전 검증 강제';
  RAISE NOTICE '';
  RAISE NOTICE '클라이언트 + 서버 양쪽에서 검증됨';
  RAISE NOTICE '';
END $$;
