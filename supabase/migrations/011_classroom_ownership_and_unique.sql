-- ============================================================================
-- Migration: 011_classroom_ownership_and_unique.sql
-- 작성일: 2026-01-19
-- 목적: 교실 소유권 관리 및 중복 방지
--
-- 변경사항:
-- 1. 동명 교실 방지: (school_id, name) UNIQUE 제약
-- 2. 교실 수정/삭제: 생성자만 가능하도록 RLS 정책 변경
-- ============================================================================

-- ============================================================================
-- PART 1: 동명 교실 방지 (UNIQUE 제약)
-- ============================================================================
-- 같은 학교 내에서 동일한 이름의 교실 생성 불가

-- 기존 중복 데이터가 있을 수 있으므로, 먼저 확인 후 제약 추가
-- (중복이 있으면 수동으로 해결 필요)

-- UNIQUE 제약조건 추가
ALTER TABLE classrooms
  ADD CONSTRAINT classrooms_school_name_unique
  UNIQUE (school_id, name);

-- ============================================================================
-- PART 2: 교실 수정/삭제 권한 제한 (생성자만)
-- ============================================================================

-- 기존 UPDATE/DELETE 정책 제거
DROP POLICY IF EXISTS "Users can update classrooms from same school" ON classrooms;
DROP POLICY IF EXISTS "Users can delete classrooms from same school" ON classrooms;

-- 새 정책: 생성자만 수정 가능
CREATE POLICY "Only creator can update classrooms"
  ON classrooms FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    created_by = auth.uid() AND
    school_id = (SELECT school_id FROM users WHERE id = auth.uid())
  );

-- 새 정책: 생성자만 삭제 가능
CREATE POLICY "Only creator can delete classrooms"
  ON classrooms FOR DELETE
  USING (
    auth.role() = 'authenticated' AND
    created_by = auth.uid() AND
    school_id = (SELECT school_id FROM users WHERE id = auth.uid())
  );

-- ============================================================================
-- PART 3: created_by가 NULL인 기존 교실 처리 함수
-- ============================================================================
-- 기존 교실 중 created_by가 NULL인 경우, 관리자 권한으로 수정 가능하도록

-- 관리자가 모든 교실 수정 가능 (created_by가 NULL이거나 관리자인 경우)
CREATE POLICY "Admin can update any classroom"
  ON classrooms FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    school_id = (SELECT school_id FROM users WHERE id = auth.uid()) AND
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );

-- 관리자가 모든 교실 삭제 가능
CREATE POLICY "Admin can delete any classroom"
  ON classrooms FOR DELETE
  USING (
    auth.role() = 'authenticated' AND
    school_id = (SELECT school_id FROM users WHERE id = auth.uid()) AND
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );

-- ============================================================================
-- PART 4: 중복 검사 함수 (클라이언트 UX용)
-- ============================================================================
-- 교실 생성/수정 전에 중복 여부를 미리 확인

CREATE OR REPLACE FUNCTION check_classroom_name_exists(
  p_school_id UUID,
  p_name TEXT,
  p_exclude_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM classrooms
    WHERE school_id = p_school_id
      AND name = p_name
      AND deleted_at IS NULL
      AND (p_exclude_id IS NULL OR id != p_exclude_id)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION check_classroom_name_exists(UUID, TEXT, UUID) TO authenticated;

-- ============================================================================
-- PART 5: 검증 및 로그
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE '011_classroom_ownership_and_unique.sql 적용 완료';
  RAISE NOTICE '============================================';
  RAISE NOTICE '[1] classrooms_school_name_unique 제약 추가';
  RAISE NOTICE '    - 같은 학교 내 동명 교실 생성 불가';
  RAISE NOTICE '[2] RLS 정책 변경';
  RAISE NOTICE '    - 교실 수정/삭제: 생성자 또는 관리자만';
  RAISE NOTICE '[3] check_classroom_name_exists 함수 추가';
  RAISE NOTICE '    - 중복 검사용 RPC';
  RAISE NOTICE '============================================';
END $$;
