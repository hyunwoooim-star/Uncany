-- ====================================
-- Username으로 Email 조회 RPC 함수
-- ====================================
-- 작성일: 2026-01-18
-- 목적: 로그인 시 아이디로 이메일 조회 (RLS 우회)
--   - users 테이블에 RLS 정책으로 인해 비인증 사용자가 조회 불가
--   - SECURITY DEFINER 함수로 RLS 우회하여 로그인 가능하게 함

-- ====================================
-- PART 1: RPC 함수 생성
-- ====================================

CREATE OR REPLACE FUNCTION get_email_by_username(username_input text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  found_email text;
BEGIN
  SELECT email INTO found_email
  FROM users
  WHERE username = username_input
    AND deleted_at IS NULL;

  RETURN found_email;
END;
$$;

-- ====================================
-- PART 2: 권한 부여
-- ====================================

-- anon/authenticated 모두 실행 가능
GRANT EXECUTE ON FUNCTION get_email_by_username(text) TO anon;
GRANT EXECUTE ON FUNCTION get_email_by_username(text) TO authenticated;

COMMENT ON FUNCTION get_email_by_username IS '아이디로 이메일 조회 - 로그인에 사용 (RLS 우회)';

-- ====================================
-- PART 3: 완료 메시지
-- ====================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ get_email_by_username RPC 함수 생성 완료';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '적용된 변경 사항:';
  RAISE NOTICE '1. ✅ get_email_by_username() 함수 생성';
  RAISE NOTICE '2. ✅ anon, authenticated 역할에 EXECUTE 권한 부여';
  RAISE NOTICE '';
  RAISE NOTICE '로그인 시 아이디로 이메일 조회 가능';
  RAISE NOTICE '';
END $$;
