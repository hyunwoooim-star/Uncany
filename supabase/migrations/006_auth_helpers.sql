-- ====================================
-- 인증 헬퍼 함수들
-- ====================================
-- 작성일: 2026-01-14
-- 목적: 아이디 찾기 등 인증 관련 보안 함수

-- ====================================
-- 1. 이메일로 Username 찾기 (보안 함수)
-- ====================================
-- SECURITY DEFINER: 관리자 권한으로 실행 (RLS 우회)
-- 일반 사용자가 직접 users 테이블 조회 불가하므로
-- 이 함수를 통해서만 username 조회 가능

CREATE OR REPLACE FUNCTION get_username_by_email(email_input text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  found_username text;
BEGIN
  -- 삭제된 계정은 제외
  SELECT username INTO found_username
  FROM users
  WHERE email = email_input
    AND deleted_at IS NULL;

  RETURN found_username;
END;
$$;

-- anon/authenticated 모두 실행 가능
GRANT EXECUTE ON FUNCTION get_username_by_email(text) TO anon;
GRANT EXECUTE ON FUNCTION get_username_by_email(text) TO authenticated;

COMMENT ON FUNCTION get_username_by_email IS '이메일로 아이디 찾기 - 로그인 없이 사용 가능';
