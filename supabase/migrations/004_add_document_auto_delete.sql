-- ====================================
-- 재직증명서 자동 파기 정책 추가
-- ====================================

-- 개인정보 보호법 제21조 준수: 승인/반려 후 30일 이내 재직증명서 삭제

-- 1. 증명서 삭제 예정일 컬럼 추가
ALTER TABLE users
ADD COLUMN document_delete_scheduled_at TIMESTAMPTZ;

-- 컬럼 주석
COMMENT ON COLUMN users.document_delete_scheduled_at IS '재직증명서 자동 삭제 예정 일시 (승인/반려 후 30일)';

-- 2. 삭제 예정일 자동 계산 함수
CREATE OR REPLACE FUNCTION schedule_document_deletion()
RETURNS TRIGGER AS $$
BEGIN
  -- 상태가 pending에서 approved 또는 rejected로 변경되었을 때
  IF OLD.verification_status = 'pending'
     AND (NEW.verification_status = 'approved' OR NEW.verification_status = 'rejected')
     AND NEW.verification_document_url IS NOT NULL THEN
    -- 30일 후 삭제 예정으로 설정
    NEW.document_delete_scheduled_at := NOW() + INTERVAL '30 days';
  END IF;

  -- 삭제 예정일이 지났고 문서가 아직 있으면 NULL로 변경 (Storage 삭제는 Edge Function에서)
  IF NEW.document_delete_scheduled_at IS NOT NULL
     AND NEW.document_delete_scheduled_at <= NOW()
     AND NEW.verification_document_url IS NOT NULL THEN
    NEW.verification_document_url := NULL;
    NEW.document_delete_scheduled_at := NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. 트리거 생성
DROP TRIGGER IF EXISTS trigger_schedule_document_deletion ON users;
CREATE TRIGGER trigger_schedule_document_deletion
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION schedule_document_deletion();

-- 4. 기존 승인/반려된 사용자의 삭제 예정일 설정 (이미 30일 지났으면 즉시 삭제 예정)
UPDATE users
SET document_delete_scheduled_at = CASE
  WHEN updated_at + INTERVAL '30 days' <= NOW() THEN NOW() -- 이미 30일 지남 -> 즉시 삭제
  ELSE updated_at + INTERVAL '30 days' -- 아직 30일 안지남 -> 예정일 설정
END
WHERE verification_status IN ('approved', 'rejected')
  AND verification_document_url IS NOT NULL
  AND document_delete_scheduled_at IS NULL;

-- 5. 삭제 대상 조회용 뷰 (관리자/배치 작업용)
CREATE OR REPLACE VIEW documents_to_delete AS
SELECT
  id,
  email,
  name,
  verification_status,
  verification_document_url,
  document_delete_scheduled_at,
  updated_at
FROM users
WHERE document_delete_scheduled_at IS NOT NULL
  AND document_delete_scheduled_at <= NOW()
  AND verification_document_url IS NOT NULL
ORDER BY document_delete_scheduled_at ASC;

-- 6. 권한 설정
GRANT SELECT ON documents_to_delete TO authenticated;

-- ====================================
-- 수동 삭제 프로세스 (Edge Function 배포 전 임시)
-- ====================================

-- 아래 쿼리를 주기적(매주)으로 실행하여 수동 삭제:
--
-- SELECT * FROM documents_to_delete;
--
-- Storage에서 파일 수동 삭제 후:
-- UPDATE users
-- SET verification_document_url = NULL, document_delete_scheduled_at = NULL
-- WHERE id IN (SELECT id FROM documents_to_delete);
