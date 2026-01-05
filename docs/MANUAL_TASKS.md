# 수동 작업 체크리스트

> **마지막 업데이트**: 2026-01-06
> **관련 커밋**: fa6d27f (feat: Phase 3 완료)

이 문서는 코드 변경 후 **수동으로 수행해야 할 작업**들을 정리합니다.

---

## 즉시 해야 할 작업 (필수)

### 1. Supabase DB 마이그레이션

#### 1.1 schools 테이블 생성
```sql
-- Supabase SQL Editor에서 실행
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(10) UNIQUE,  -- 학교 코드 (나이스 API)
  name TEXT NOT NULL,
  address TEXT,
  type VARCHAR(20) DEFAULT 'elementary',  -- elementary, middle, high
  office_code VARCHAR(10),  -- 교육청 코드
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_schools_name ON schools(name);
CREATE INDEX idx_schools_code ON schools(code);

-- RLS 활성화
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;

-- 모든 인증된 사용자가 조회 가능
CREATE POLICY "Schools are viewable by authenticated users"
  ON schools FOR SELECT
  TO authenticated
  USING (true);
```

#### 1.2 users 테이블 컬럼 추가
```sql
-- 새 컬럼 추가
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id),
  ADD COLUMN IF NOT EXISTS grade INTEGER,
  ADD COLUMN IF NOT EXISTS class_num INTEGER,
  ADD COLUMN IF NOT EXISTS username VARCHAR(50) UNIQUE;

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_users_school_id ON users(school_id);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
```

#### 1.3 classrooms 테이블 컬럼 추가
```sql
-- 새 컬럼 추가
ALTER TABLE classrooms
  ADD COLUMN IF NOT EXISTS school_id UUID REFERENCES schools(id),
  ADD COLUMN IF NOT EXISTS room_type VARCHAR(20) DEFAULT 'other',
  ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_classrooms_school_id ON classrooms(school_id);

-- RLS 정책 업데이트 (같은 학교만 조회 가능)
DROP POLICY IF EXISTS "Users can view classrooms" ON classrooms;
CREATE POLICY "Users can view classrooms from same school"
  ON classrooms FOR SELECT
  TO authenticated
  USING (
    school_id IN (
      SELECT school_id FROM users WHERE id = auth.uid()
    )
  );
```

#### 1.4 reservations 테이블 컬럼 추가
```sql
-- periods 컬럼 추가 (교시 배열)
ALTER TABLE reservations
  ADD COLUMN IF NOT EXISTS periods INTEGER[];

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_reservations_periods ON reservations USING GIN(periods);
```

#### 1.5 handle_new_user 트리거 업데이트
```sql
-- 기존 트리거 삭제
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 새 트리거 함수 (username, grade, class_num 포함)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id, email, name, school_name, school_id,
    grade, class_num, username,
    verification_status, created_at
  )
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'name',
    new.raw_user_meta_data ->> 'school_name',
    (new.raw_user_meta_data ->> 'school_id')::uuid,
    (new.raw_user_meta_data ->> 'grade')::integer,
    (new.raw_user_meta_data ->> 'class_num')::integer,
    new.raw_user_meta_data ->> 'username',
    COALESCE(new.raw_user_meta_data ->> 'verification_status', 'pending'),
    now()
  );
  RETURN new;
END;
$$;

-- 트리거 재생성
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

---

### 2. 공공데이터 API 설정

#### 2.1 API 키 발급
1. [나이스 교육정보 개방포털](https://open.neis.go.kr) 접속
2. 회원가입 후 API 활용 신청
3. "초등학교 정보" API 활용 신청
4. 발급받은 API 키 저장

#### 2.2 환경 변수 설정
```bash
# .env 파일에 추가
NEIS_API_KEY=발급받은_API_키
```

#### 2.3 Supabase Edge Function (선택)
API 호출 횟수 제한을 위해 Edge Function으로 캐싱 가능

---

### 3. 초등학교 데이터 초기 로드 (선택)

전국 초등학교 목록을 미리 캐싱하면 검색 성능 향상

```sql
-- 예시: 학교 데이터 bulk insert
INSERT INTO schools (code, name, address, office_code) VALUES
('7011234', '서울초등학교', '서울시 강남구', 'B10'),
('7012345', '부산초등학교', '부산시 해운대구', 'C10'),
-- ... 추가 데이터
;
```

---

## 확인 필요 사항

### 현재 Supabase 설정 상태

| 항목 | 현재 상태 | 필요 조치 |
|------|----------|----------|
| schools 테이블 | ❌ 없음 | 생성 필요 |
| users.school_id | ❌ 없음 | 추가 필요 |
| users.username | ❌ 없음 | 추가 필요 |
| classrooms.school_id | ❌ 없음 | 추가 필요 |
| classrooms.room_type | ❌ 없음 | 추가 필요 |
| reservations.periods | ❌ 없음 | 추가 필요 |
| handle_new_user 트리거 | ✅ 있음 | 업데이트 필요 |
| NEIS API 키 | ❌ 없음 | 발급 필요 |

---

## 나중에 해야 할 작업 (선택)

### 프로덕션 배포 전

1. **이메일 인증 활성화**
   - Authentication → Providers → Email → Confirm email → ON
   - 커스텀 SMTP 설정 (Resend.com 추천)

2. **Storage RLS 정책 추가**
   - verification-documents 버킷에 폴더 기반 정책

3. **초등학교 데이터 캐싱**
   - 전국 초등학교 목록 schools 테이블에 저장
   - API 호출 횟수 절약

---

## 체크리스트 사용법

작업 완료 후 이 문서에서 체크 표시:
- [ ] → [x]

```markdown
- [x] schools 테이블 생성 완료
- [x] users 컬럼 추가 완료
- [ ] API 키 발급 대기 중
```

---

## 관련 파일

- `lib/src/features/school/data/services/school_api_service.dart` - API 연동
- `lib/src/features/auth/presentation/signup_screen.dart` - 회원가입 (username, school 필드)
- `lib/src/features/auth/presentation/login_screen.dart` - 로그인 (username 기반)
- `lib/src/features/reservation/presentation/reservation_screen.dart` - 교시 기반 예약

---

## 문의

설정 중 문제 발생 시:
1. 에러 메시지 캡처
2. Supabase Dashboard 스크린샷
3. 이 문서와 함께 전달
