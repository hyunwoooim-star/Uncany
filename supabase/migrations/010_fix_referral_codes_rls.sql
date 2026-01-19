-- ============================================================================
-- Migration: 010_fix_referral_codes_rls.sql
-- 작성일: 2026-01-19
-- 목적: 추천인 코드 RLS 정책 및 RPC 함수 구현
--
-- Gemini 피드백 반영:
-- - 생성자만 SELECT → 누구나 유효한 코드 조회 가능 (가입 시 검증용)
-- - Race Condition 방지를 위한 RPC 함수
-- - 같은 학교 제약을 트리거로 강제
-- ============================================================================

-- ============================================================================
-- PART 1: increment_referral_uses RPC 함수
-- ============================================================================
-- Race Condition 방지: 원자적 UPDATE
-- 클라이언트의 SELECT → UPDATE 패턴 대신 단일 RPC 호출

CREATE OR REPLACE FUNCTION increment_referral_uses(p_code_id UUID)
RETURNS JSON AS $$
DECLARE
  v_result JSON;
  v_code RECORD;
BEGIN
  -- 락 획득 후 조회 (동시성 제어)
  SELECT * INTO v_code
  FROM referral_codes
  WHERE id = p_code_id
  FOR UPDATE;

  -- 코드 존재 여부 확인
  IF v_code IS NULL THEN
    RETURN json_build_object('success', false, 'error', '추천인 코드를 찾을 수 없습니다');
  END IF;

  -- 활성 상태 확인
  IF NOT v_code.is_active THEN
    RETURN json_build_object('success', false, 'error', '비활성화된 추천인 코드입니다');
  END IF;

  -- 사용 횟수 확인
  IF v_code.current_uses >= v_code.max_uses THEN
    RETURN json_build_object('success', false, 'error', '사용 횟수를 초과한 추천인 코드입니다');
  END IF;

  -- 만료 확인
  IF v_code.expires_at IS NOT NULL AND v_code.expires_at < NOW() THEN
    RETURN json_build_object('success', false, 'error', '만료된 추천인 코드입니다');
  END IF;

  -- 원자적 UPDATE
  UPDATE referral_codes
  SET current_uses = current_uses + 1
  WHERE id = p_code_id;

  -- 최대 사용 횟수 도달 시 자동 비활성화
  IF v_code.current_uses + 1 >= v_code.max_uses THEN
    UPDATE referral_codes
    SET is_active = FALSE
    WHERE id = p_code_id;
  END IF;

  RETURN json_build_object('success', true, 'message', '추천인 코드가 사용되었습니다');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 권한 부여
GRANT EXECUTE ON FUNCTION increment_referral_uses(UUID) TO authenticated;

-- ============================================================================
-- PART 2: 같은 학교 제약 트리거 (Gemini 권장)
-- ============================================================================
-- 클라이언트 검증만으로는 악의적 우회 가능
-- DB 레벨에서 강제

CREATE OR REPLACE FUNCTION check_referral_same_school()
RETURNS TRIGGER AS $$
DECLARE
  v_referral_school TEXT;
  v_user_school TEXT;
BEGIN
  -- 추천인 코드의 학교명 조회
  SELECT school_name INTO v_referral_school
  FROM referral_codes
  WHERE id = NEW.referral_code_id;

  -- 사용자의 학교명 조회
  SELECT school_name INTO v_user_school
  FROM users
  WHERE id = NEW.used_by;

  -- 같은 학교 확인
  IF v_referral_school IS DISTINCT FROM v_user_school THEN
    RAISE EXCEPTION '같은 학교의 추천인 코드만 사용할 수 있습니다 (코드: %, 사용자: %)',
      v_referral_school, v_user_school;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 기존 트리거 제거 후 재생성
DROP TRIGGER IF EXISTS check_referral_same_school_trigger ON referral_usage;

CREATE TRIGGER check_referral_same_school_trigger
  BEFORE INSERT ON referral_usage
  FOR EACH ROW
  EXECUTE FUNCTION check_referral_same_school();

-- ============================================================================
-- PART 3: referral_codes RLS 정책
-- ============================================================================
-- Gemini 피드백: 검증용 공개 SELECT 필요

-- 기존 정책 제거
DROP POLICY IF EXISTS "referral_codes_select_own" ON referral_codes;
DROP POLICY IF EXISTS "referral_codes_insert_own" ON referral_codes;
DROP POLICY IF EXISTS "referral_codes_update_own" ON referral_codes;
DROP POLICY IF EXISTS "referral_codes_validate_public" ON referral_codes;
DROP POLICY IF EXISTS "Users can manage own referral codes" ON referral_codes;
DROP POLICY IF EXISTS "Anyone can read valid referral codes" ON referral_codes;

-- 1. 생성자 관리 정책 (INSERT, UPDATE, DELETE)
-- 본인이 생성한 코드만 관리 가능
CREATE POLICY "referral_codes_owner_manage" ON referral_codes
  FOR ALL
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

-- 2. (중요) 유효한 코드 공개 조회 정책
-- 회원가입 시 코드 유효성 검증을 위해 누구나 조회 가능
-- 단, 유효한(active + 미만료 + 사용가능) 코드만
CREATE POLICY "referral_codes_public_validate" ON referral_codes
  FOR SELECT
  USING (
    is_active = TRUE
    AND (expires_at IS NULL OR expires_at > NOW())
    AND current_uses < max_uses
  );

-- ============================================================================
-- PART 4: referral_usage RLS 정책
-- ============================================================================

-- RLS 활성화 확인
ALTER TABLE referral_usage ENABLE ROW LEVEL SECURITY;

-- 기존 정책 제거
DROP POLICY IF EXISTS "referral_usage_select_own" ON referral_usage;
DROP POLICY IF EXISTS "referral_usage_insert_own" ON referral_usage;
DROP POLICY IF EXISTS "Users can read own usage" ON referral_usage;
DROP POLICY IF EXISTS "Users can create usage record" ON referral_usage;

-- 1. 자신의 사용 기록만 조회
CREATE POLICY "referral_usage_select_own" ON referral_usage
  FOR SELECT
  USING (used_by = auth.uid());

-- 2. 자신만 사용 기록 생성 가능
CREATE POLICY "referral_usage_insert_own" ON referral_usage
  FOR INSERT
  WITH CHECK (used_by = auth.uid());

-- ============================================================================
-- PART 5: 검증 및 로그
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE '010_fix_referral_codes_rls.sql 적용 완료';
  RAISE NOTICE '============================================';
  RAISE NOTICE '[1] increment_referral_uses RPC 함수 생성';
  RAISE NOTICE '    - Race Condition 방지 (FOR UPDATE 락)';
  RAISE NOTICE '    - 원자적 카운트 증가';
  RAISE NOTICE '    - 최대 사용 시 자동 비활성화';
  RAISE NOTICE '[2] check_referral_same_school 트리거 생성';
  RAISE NOTICE '    - DB 레벨 같은 학교 제약 강제';
  RAISE NOTICE '[3] referral_codes RLS 정책 2개';
  RAISE NOTICE '    - referral_codes_owner_manage (본인 코드 관리)';
  RAISE NOTICE '    - referral_codes_public_validate (유효 코드 공개 조회)';
  RAISE NOTICE '[4] referral_usage RLS 정책 2개';
  RAISE NOTICE '    - referral_usage_select_own';
  RAISE NOTICE '    - referral_usage_insert_own';
  RAISE NOTICE '============================================';
END $$;
