-- ====================================
-- 관리자 비밀번호 초기화 기능
-- ====================================
-- 작성일: 2026-01-16
-- 목적: 관리자가 사용자 비밀번호를 초기화할 수 있는 기능

-- ====================================
-- 1. 관리자 비밀번호 초기화 함수
-- ====================================
-- 관리자만 실행 가능 (role = 'admin' 체크)
-- 임시 비밀번호로 변경 후 해당 비밀번호 반환

CREATE OR REPLACE FUNCTION admin_reset_user_password(
  target_user_id uuid,
  new_password text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  caller_role text;
BEGIN
  -- 호출자가 관리자인지 확인
  SELECT role INTO caller_role
  FROM users
  WHERE id = auth.uid()
    AND deleted_at IS NULL;

  IF caller_role != 'admin' THEN
    RAISE EXCEPTION '관리자 권한이 필요합니다';
  END IF;

  -- 대상 사용자가 존재하는지 확인
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = target_user_id AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION '사용자를 찾을 수 없습니다';
  END IF;

  -- 비밀번호 변경 (auth.users 테이블 직접 업데이트)
  UPDATE auth.users
  SET encrypted_password = crypt(new_password, gen_salt('bf')),
      updated_at = NOW()
  WHERE id = target_user_id;

  RETURN true;
END;
$$;

-- 인증된 사용자만 실행 가능 (내부에서 admin 체크)
GRANT EXECUTE ON FUNCTION admin_reset_user_password(uuid, text) TO authenticated;

COMMENT ON FUNCTION admin_reset_user_password IS '관리자가 사용자 비밀번호를 초기화 (관리자 권한 필요)';

-- ====================================
-- 완료!
-- ====================================
