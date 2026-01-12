-- ====================================
-- 동의 날짜 및 버전 추적 컬럼 추가
-- ====================================

-- 개인정보 보호법 제15조: 동의 받은 사항 및 시점 기록

-- 1. 약관 동의 날짜 및 버전 추적
ALTER TABLE users
ADD COLUMN terms_agreed_at TIMESTAMPTZ,
ADD COLUMN privacy_agreed_at TIMESTAMPTZ,
ADD COLUMN terms_version TEXT DEFAULT 'v1.0',
ADD COLUMN privacy_version TEXT DEFAULT 'v1.0',
ADD COLUMN sensitive_data_agreed_at TIMESTAMPTZ;

-- 컬럼 주석
COMMENT ON COLUMN users.terms_agreed_at IS '이용약관 동의 일시';
COMMENT ON COLUMN users.privacy_agreed_at IS '개인정보처리방침 동의 일시';
COMMENT ON COLUMN users.terms_version IS '동의한 이용약관 버전';
COMMENT ON COLUMN users.privacy_version IS '동의한 개인정보처리방침 버전';
COMMENT ON COLUMN users.sensitive_data_agreed_at IS '민감정보(재직증명서) 수집·이용 동의 일시';

-- 2. 기존 사용자 동의 날짜 소급 적용 (created_at 기준)
UPDATE users
SET
  terms_agreed_at = created_at,
  privacy_agreed_at = created_at,
  terms_version = 'v1.0',
  privacy_version = 'v1.0',
  sensitive_data_agreed_at = CASE
    WHEN verification_document_url IS NOT NULL THEN created_at
    ELSE NULL
  END
WHERE terms_agreed_at IS NULL;

-- 3. 마케팅 동의 철회 기능을 위한 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_users_email_marketing ON users(agree_to_email_marketing) WHERE agree_to_email_marketing = true;
CREATE INDEX IF NOT EXISTS idx_users_sms_marketing ON users(agree_to_sms_marketing) WHERE agree_to_sms_marketing = true;

-- 4. 동의 내역 조회용 뷰 (관리자용)
CREATE OR REPLACE VIEW user_consents AS
SELECT
  id,
  email,
  name,
  terms_agreed_at,
  privacy_agreed_at,
  sensitive_data_agreed_at,
  terms_version,
  privacy_version,
  agree_to_email_marketing,
  agree_to_sms_marketing,
  created_at,
  updated_at
FROM users
ORDER BY created_at DESC;

-- 권한 설정
GRANT SELECT ON user_consents TO authenticated;
