-- ====================================
-- 사용자 이메일 동기화 수정
-- ====================================
-- 작성일: 2026-01-16
-- 목적: auth.users의 이메일을 public.users로 동기화
-- 문제: 아이디 찾기 기능에서 이메일로 조회 시 사용자를 찾지 못함
--       (public.users 테이블에 email이 저장되지 않았음)

-- ====================================
-- 1. 기존 사용자의 이메일 동기화
-- ====================================
-- auth.users에서 public.users로 이메일 복사
-- 이미 email이 있는 경우는 업데이트하지 않음

UPDATE public.users u
SET email = au.email
FROM auth.users au
WHERE u.id = au.id
  AND (u.email IS NULL OR u.email = '');

-- ====================================
-- 2. 새 사용자 생성 시 이메일 자동 동기화 트리거
-- ====================================

-- 2-1. 트리거 함수 생성/수정
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- 새 사용자 생성 시 public.users에 레코드 삽입
  -- raw_user_meta_data에서 필요한 정보 추출
  INSERT INTO public.users (
    id,
    email,
    name,
    school_name,
    grade,
    class_num,
    username,
    verification_status,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'school_name', ''),
    (NEW.raw_user_meta_data->>'grade')::int,
    (NEW.raw_user_meta_data->>'class_num')::int,
    NEW.raw_user_meta_data->>'username',
    COALESCE(NEW.raw_user_meta_data->>'verification_status', 'pending'),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();

  RETURN NEW;
END;
$$;

-- 2-2. 기존 트리거 삭제 후 재생성
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ====================================
-- 3. 이메일 업데이트 시 동기화 트리거
-- ====================================
-- auth.users의 이메일이 변경되면 public.users에도 반영

CREATE OR REPLACE FUNCTION sync_user_email()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- 이메일 변경 시 public.users 업데이트
  IF OLD.email IS DISTINCT FROM NEW.email THEN
    UPDATE public.users
    SET email = NEW.email, updated_at = NOW()
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;

CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION sync_user_email();

-- ====================================
-- 4. get_username_by_email 함수 개선 (대소문자 무시)
-- ====================================
CREATE OR REPLACE FUNCTION get_username_by_email(email_input text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  found_username text;
BEGIN
  -- 대소문자 무시하여 검색 (ILIKE 대신 LOWER 사용)
  SELECT username INTO found_username
  FROM users
  WHERE LOWER(email) = LOWER(email_input)
    AND deleted_at IS NULL;

  RETURN found_username;
END;
$$;

-- 권한 재설정
GRANT EXECUTE ON FUNCTION get_username_by_email(text) TO anon;
GRANT EXECUTE ON FUNCTION get_username_by_email(text) TO authenticated;

-- ====================================
-- 완료!
-- ====================================
