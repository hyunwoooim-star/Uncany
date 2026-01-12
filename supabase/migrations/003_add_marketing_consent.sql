-- ====================================
-- 마케팅 수신동의 필드 추가
-- ====================================

-- users 테이블에 이메일/SMS 마케팅 수신동의 컬럼 추가
ALTER TABLE users
ADD COLUMN agree_to_email_marketing BOOLEAN DEFAULT FALSE,
ADD COLUMN agree_to_sms_marketing BOOLEAN DEFAULT FALSE;

-- 컬럼 주석 추가
COMMENT ON COLUMN users.agree_to_email_marketing IS '이메일 마케팅 수신동의 여부';
COMMENT ON COLUMN users.agree_to_sms_marketing IS 'SMS 마케팅 수신동의 여부';
