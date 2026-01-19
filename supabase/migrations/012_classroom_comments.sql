-- ============================================================================
-- Migration: 012_classroom_comments.sql
-- 작성일: 2026-01-19
-- 목적: 교실 댓글/게시판 기능 (공개 소통 채널)
--
-- Gemini 제안 반영:
-- - is_resolved 필드로 "문제 해결됨" 상태 관리
-- - 공개 정보 공유 (에어컨 고장, 프로젝터 문제 등)
-- ============================================================================

-- ============================================================================
-- PART 1: classroom_comments 테이블 생성
-- ============================================================================

CREATE TABLE classroom_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,

  -- 문제 해결 여부 (고장 신고 → 수리 완료)
  is_resolved BOOLEAN DEFAULT FALSE,
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES users(id),

  -- 댓글 유형 (일반/문제신고/공지)
  comment_type TEXT DEFAULT 'general' CHECK (
    comment_type IN ('general', 'issue', 'notice')
  ),

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ -- Soft delete
);

-- 코멘트:
-- comment_type:
--   'general': 일반 댓글 (질문, 의견)
--   'issue': 문제 신고 (고장, 청소 불량 등) - is_resolved 사용
--   'notice': 공지사항 (교실 등록자/관리자만 작성 가능)

-- ============================================================================
-- PART 2: 인덱스
-- ============================================================================

-- 교실별 댓글 조회 (최신순)
CREATE INDEX idx_classroom_comments_classroom_id
  ON classroom_comments(classroom_id, created_at DESC);

-- 미해결 문제 빠른 조회
CREATE INDEX idx_classroom_comments_unresolved
  ON classroom_comments(classroom_id)
  WHERE comment_type = 'issue' AND is_resolved = FALSE AND deleted_at IS NULL;

-- 사용자별 댓글 조회
CREATE INDEX idx_classroom_comments_user_id
  ON classroom_comments(user_id);

-- ============================================================================
-- PART 3: RLS 정책
-- ============================================================================

ALTER TABLE classroom_comments ENABLE ROW LEVEL SECURITY;

-- 읽기: 같은 학교 사용자만
CREATE POLICY "Users can read comments from same school classrooms"
  ON classroom_comments FOR SELECT
  USING (
    auth.role() = 'authenticated' AND
    classroom_id IN (
      SELECT id FROM classrooms
      WHERE school_id = (SELECT school_id FROM users WHERE id = auth.uid())
    )
  );

-- 생성: 같은 학교 사용자 (본인 ID로만)
CREATE POLICY "Users can create comments"
  ON classroom_comments FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    user_id = auth.uid() AND
    classroom_id IN (
      SELECT id FROM classrooms
      WHERE school_id = (SELECT school_id FROM users WHERE id = auth.uid())
    )
  );

-- 수정: 본인 댓글만 (삭제되지 않은 것)
CREATE POLICY "Users can update own comments"
  ON classroom_comments FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
    user_id = auth.uid() AND
    deleted_at IS NULL
  );

-- 삭제: 본인 또는 교실 등록자 또는 관리자
CREATE POLICY "Users can delete own comments or admin"
  ON classroom_comments FOR DELETE
  USING (
    auth.role() = 'authenticated' AND (
      user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM classrooms c
        WHERE c.id = classroom_comments.classroom_id
        AND c.created_by = auth.uid()
      ) OR
      EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() AND role = 'admin'
      )
    )
  );

-- ============================================================================
-- PART 4: 문제 해결 처리 함수
-- ============================================================================

-- 문제 해결 표시 (교실 등록자 또는 관리자만)
CREATE OR REPLACE FUNCTION resolve_classroom_issue(
  p_comment_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  v_classroom_id UUID;
  v_comment_type TEXT;
  v_can_resolve BOOLEAN := FALSE;
BEGIN
  -- 댓글 정보 조회
  SELECT classroom_id, comment_type INTO v_classroom_id, v_comment_type
  FROM classroom_comments
  WHERE id = p_comment_id AND deleted_at IS NULL;

  IF v_comment_type != 'issue' THEN
    RAISE EXCEPTION '문제 신고 댓글만 해결 표시할 수 있습니다';
  END IF;

  -- 권한 확인 (교실 등록자 또는 관리자)
  SELECT EXISTS (
    SELECT 1 FROM classrooms c
    WHERE c.id = v_classroom_id AND c.created_by = auth.uid()
    UNION
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ) INTO v_can_resolve;

  IF NOT v_can_resolve THEN
    RAISE EXCEPTION '교실 등록자 또는 관리자만 문제를 해결 처리할 수 있습니다';
  END IF;

  -- 해결 처리
  UPDATE classroom_comments
  SET
    is_resolved = TRUE,
    resolved_at = NOW(),
    resolved_by = auth.uid(),
    updated_at = NOW()
  WHERE id = p_comment_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION resolve_classroom_issue(UUID) TO authenticated;

-- ============================================================================
-- PART 5: updated_at 자동 갱신 트리거
-- ============================================================================

CREATE OR REPLACE FUNCTION update_classroom_comment_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_classroom_comment_timestamp
  BEFORE UPDATE ON classroom_comments
  FOR EACH ROW
  EXECUTE FUNCTION update_classroom_comment_timestamp();

-- ============================================================================
-- PART 6: 미해결 문제 개수 조회 함수
-- ============================================================================

CREATE OR REPLACE FUNCTION get_classroom_unresolved_count(p_classroom_id UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)::INTEGER
    FROM classroom_comments
    WHERE classroom_id = p_classroom_id
      AND comment_type = 'issue'
      AND is_resolved = FALSE
      AND deleted_at IS NULL
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_classroom_unresolved_count(UUID) TO authenticated;

-- ============================================================================
-- 완료 로그
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE '012_classroom_comments.sql 적용 완료';
  RAISE NOTICE '============================================';
  RAISE NOTICE '[1] classroom_comments 테이블 생성';
  RAISE NOTICE '    - comment_type: general, issue, notice';
  RAISE NOTICE '    - is_resolved: 문제 해결 여부';
  RAISE NOTICE '[2] RLS 정책 설정';
  RAISE NOTICE '    - 읽기/쓰기: 같은 학교만';
  RAISE NOTICE '    - 삭제: 본인 or 교실등록자 or 관리자';
  RAISE NOTICE '[3] resolve_classroom_issue() 함수';
  RAISE NOTICE '[4] get_classroom_unresolved_count() 함수';
  RAISE NOTICE '============================================';
END $$;
