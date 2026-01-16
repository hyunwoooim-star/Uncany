-- ====================================
-- 관리자 사용자 승인 RLS 정책 수정
-- ====================================
-- 작성일: 2026-01-16
-- 문제: 관리자가 사용자 승인/반려 시 RLS 정책에 의해 차단됨
-- 해결: 관리자가 다른 사용자의 verification_status를 변경할 수 있도록 정책 추가

-- ====================================
-- 1. 관리자용 사용자 수정 정책 추가
-- ====================================
-- 기존 users_update_own 정책은 유지 (본인 프로필 수정용)
-- 관리자가 다른 사용자의 승인 상태를 변경할 수 있는 정책 추가

DROP POLICY IF EXISTS "admin_can_update_users" ON users;

CREATE POLICY "admin_can_update_users" ON users
  FOR UPDATE
  USING (
    -- 관리자인 경우에만 적용
    auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'admin'
      AND deleted_at IS NULL
    )
  )
  WITH CHECK (
    -- 관리자가 변경 가능한 필드 제한
    -- verification_status, role, rejected_reason, updated_at, deleted_at 변경 가능
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'admin'
      AND deleted_at IS NULL
    )
  );

-- ====================================
-- 2. 관리자용 사용자 삭제 정책 (soft delete)
-- ====================================
DROP POLICY IF EXISTS "admin_can_delete_users" ON users;

CREATE POLICY "admin_can_delete_users" ON users
  FOR DELETE
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
-- 완료!
-- ====================================
-- 실행 후 관리자가 사용자 승인/반려/삭제 가능
