# 🏫 Uncany - 학교 커뮤니티 플랫폼 프로젝트 계획서

> **프로젝트 목표**: 교사들이 학교 리소스(교실, 기자재)를 예약하고 관리하는 신뢰 기반 커뮤니티 플랫폼
> **플랫폼**: Web + Mobile (iOS, Android)
> **마지막 업데이트**: 2026-01-05

---

## 📋 목차
1. [프로젝트 개요](#프로젝트-개요)
2. [기술 스택](#기술-스택)
3. [프로젝트 규칙](#프로젝트-규칙)
4. [폴더 구조](#폴더-구조)
5. [데이터베이스 스키마](#데이터베이스-스키마)
6. [개발 단계](#개발-단계)
7. [Git 브랜치 전략](#git-브랜치-전략)

---

## 🎯 프로젝트 개요

### 핵심 기능 (MVP)
1. **인증 시스템**
   - 재직증명서 업로드 + 관리자 승인
   - 교육청 이메일 인증 (17개 시도교육청 도메인)
   - **추천인 코드** (같은 학교 제약) ✅
   - ~~신뢰 점수 시스템~~ (제거)

2. **예약 시스템**
   - 교실/리소스 등록 및 조회
   - 시간표 기반 예약 생성/취소
   - 비밀번호 보호 교실 (선택적)
   - 공지사항 기능
   - ~~담당자 지정~~ (제거)

3. **데이터 무결성**
   - Soft Delete (논리적 삭제)
   - Audit Log (변경 이력 추적)
   - 되돌리기 기능

4. **UI/UX**
   - 토스(Toss) 스타일 디자인
   - 반응형 웹 + 네이티브 앱
   - 직관적인 시간표 그리드

---

## 🛠️ 기술 스택

### Frontend
| 기술 | 용도 | 버전 |
|------|------|------|
| **Flutter** | Web + Mobile 통합 프레임워크 | 3.24+ |
| **Riverpod** | 상태 관리 | 2.5+ |
| **GoRouter** | 라우팅 (Web URL + Deep Link) | 14.0+ |
| **Freezed** | 불변 모델 생성 | 2.5+ |

### Backend
| 기술 | 용도 |
|------|------|
| **Supabase** | BaaS (PostgreSQL + Auth + Storage + Realtime) |
| **PostgreSQL** | 관계형 데이터베이스 |
| **Row Level Security** | 세밀한 권한 제어 |

### DevOps
| 기술 | 용도 |
|------|------|
| **GitHub Actions** | CI/CD 자동화 |
| **Firebase Hosting** | Web 배포 (또는 Vercel) |
| **App Store / Play Store** | 앱 배포 |

---

## 📜 프로젝트 규칙

### 1. 개발 워크플로우
```mermaid
graph LR
    A[코드 작성] --> B[자동 테스트]
    B --> C[문서 자동 업데이트]
    C --> D[Git 커밋]
    D --> E[GitHub 푸시]
    E --> F[Phase 완료 보고서 생성]
```

### 2. Bypass Permission 모드
- **원칙**: 모든 기능은 사용자 승인 없이 자동 진행
- **예외**: 스키마 변경, 배포 등 critical한 작업만 확인 요청

### 3. 자동 문서화 규칙
매 Phase/Step 완료 시 자동으로 다음 파일 업데이트:

| 파일 | 내용 | 업데이트 주기 |
|------|------|--------------|
| `PROJECT_PLAN.md` | 전체 프로젝트 계획 | Phase 시작/종료 시 |
| `CHANGELOG.md` | 변경 이력 | 기능 완료 시마다 |
| `docs/PHASE_{N}_REPORT.md` | 단계별 상세 보고서 | Phase 종료 시 |
| `docs/API.md` | API 문서 | 엔드포인트 추가 시 |
| `docs/DATABASE.md` | DB 스키마 문서 | 마이그레이션 시 |

### 4. Git 커밋 규칙
```bash
# 커밋 메시지 형식
<type>(<scope>): <subject>

# 타입
feat: 새 기능
fix: 버그 수정
docs: 문서만 변경
refactor: 리팩토링
test: 테스트 추가
chore: 빌드/설정 변경

# 예시
feat(auth): 재직증명서 업로드 기능 추가
docs(phase1): Phase 1 완료 보고서 생성
```

### 5. 자동 푸시 규칙
- **빈도**: 각 Feature 완료 시 즉시 커밋 + 푸시
- **브랜치**: `feature/*` → `develop` → `main`
- **자동화**: GitHub Actions로 테스트 통과 시 자동 머지

---

## 📁 폴더 구조

```
uncany/
├── .github/
│   ├── workflows/
│   │   ├── test.yml              # 자동 테스트
│   │   ├── deploy-web.yml        # Web 배포
│   │   └── deploy-mobile.yml     # 앱 배포
│   └── PULL_REQUEST_TEMPLATE.md
│
├── docs/                         # 📚 자동 생성 문서
│   ├── PHASE_1_REPORT.md
│   ├── PHASE_2_REPORT.md
│   ├── API.md
│   └── DATABASE.md
│
├── supabase/                     # 🗄️ 백엔드
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_audit_logs.sql
│   │   └── 003_education_offices.sql
│   ├── functions/                # Edge Functions
│   └── seed.sql
│
├── lib/                          # 📱 Flutter App
│   ├── src/
│   │   ├── features/
│   │   │   ├── auth/             # 인증
│   │   │   │   ├── data/
│   │   │   │   ├── domain/
│   │   │   │   └── presentation/
│   │   │   ├── reservation/      # 예약
│   │   │   ├── classroom/        # 교실 관리
│   │   │   └── audit/            # 감사 로그
│   │   ├── shared/
│   │   │   ├── widgets/          # 토스 스타일 위젯
│   │   │   ├── theme/
│   │   │   └── utils/
│   │   └── core/
│   │       ├── router/
│   │       └── providers/
│   └── app.dart
│
├── test/                         # 🧪 테스트
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── web/                          # 🌐 Web 설정
├── ios/                          # 📱 iOS 설정
├── android/                      # 🤖 Android 설정
│
├── PROJECT_PLAN.md               # 📋 이 파일
├── CHANGELOG.md
├── README.md
└── pubspec.yaml
```

---

## 🗄️ 데이터베이스 스키마

### ERD 개요
```
users (교사)
  ├─ 1:N → reservations (예약)
  ├─ 1:N → referral_codes (추천 코드 생성)
  └─ 1:N → audit_logs (감사 로그)

classrooms (교실)
  └─ 1:N → reservations

referral_codes (추천 코드)
  └─ 1:N → referral_usage (사용 이력)

reservations
  └─ 1:N → audit_logs
```

### 테이블 상세

#### 1. `users` (교사)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE,
  name TEXT NOT NULL,
  school_name TEXT NOT NULL,
  education_office TEXT CHECK (education_office IN (
    'seoul', 'busan', 'daegu', 'incheon', 'gwangju',
    'daejeon', 'ulsan', 'sejong', 'gyeonggi',
    'gangwon', 'chungbuk', 'chungnam', 'jeonbuk',
    'jeonnam', 'gyeongbuk', 'gyeongnam', 'jeju'
  )),
  role TEXT CHECK (role IN ('teacher', 'admin')) DEFAULT 'teacher',

  -- 인증 상태
  verification_status TEXT CHECK (verification_status IN (
    'pending', 'approved', 'rejected'
  )) DEFAULT 'pending',
  verification_document_url TEXT,
  rejected_reason TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL
);
```

#### 2. `classrooms` (교실)
```sql
CREATE TABLE classrooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,

  -- 비밀번호 보호 (선택)
  access_code_hash TEXT NULL,

  -- 공지사항
  notice_message TEXT,
  notice_updated_at TIMESTAMPTZ,

  capacity INT,
  location TEXT,
  is_active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL
);
```

#### 3. `referral_codes` (추천인 코드)
```sql
CREATE TABLE referral_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- 6자리 랜덤 코드 (예: "SEOUL-ABC123")
  code TEXT NOT NULL UNIQUE,

  -- 생성자 정보
  created_by UUID NOT NULL REFERENCES users(id),
  school_name TEXT NOT NULL, -- 같은 학교 검증용

  -- 사용 제한
  max_uses INT DEFAULT 5,
  current_uses INT DEFAULT 0,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),

  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 활성 코드 조회용 인덱스
CREATE INDEX idx_active_referral_codes
ON referral_codes(code, is_active)
WHERE is_active = TRUE;
```

#### 4. `referral_usage` (추천 코드 사용 이력)
```sql
CREATE TABLE referral_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referral_code_id UUID NOT NULL REFERENCES referral_codes(id),
  used_by UUID NOT NULL REFERENCES users(id),
  used_at TIMESTAMPTZ DEFAULT NOW(),

  -- 한 사용자당 하나의 추천 코드만 사용 가능
  UNIQUE(used_by)
);
```

#### 5. `reservations` (예약)
```sql
CREATE TABLE reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  classroom_id UUID NOT NULL REFERENCES classrooms(id),
  teacher_id UUID NOT NULL REFERENCES users(id),

  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  title TEXT,
  description TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ NULL,

  -- 중복 예약 방지 (활성 예약만)
  CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- 중복 예약 검증용 인덱스
CREATE INDEX idx_active_reservations
ON reservations(classroom_id, start_time, end_time)
WHERE deleted_at IS NULL;
```

#### 6. `audit_logs` (감사 로그)
```sql
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,

  operation TEXT CHECK (operation IN (
    'INSERT', 'UPDATE', 'DELETE', 'RESTORE'
  )) NOT NULL,

  user_id UUID REFERENCES users(id),

  -- 변경 전후 스냅샷
  old_snapshot JSONB,
  new_snapshot JSONB,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 특정 레코드의 히스토리 조회용
CREATE INDEX idx_audit_record ON audit_logs(table_name, record_id);
```

#### 7. `education_offices` (교육청 정보)
```sql
CREATE TABLE education_offices (
  code TEXT PRIMARY KEY,
  name_ko TEXT NOT NULL,
  email_domain TEXT NOT NULL UNIQUE,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 초기 데이터
INSERT INTO education_offices (code, name_ko, email_domain) VALUES
  ('seoul', '서울특별시교육청', 'sen.go.kr'),
  ('busan', '부산광역시교육청', 'pen.go.kr'),
  ('gyeonggi', '경기도교육청', 'goe.go.kr'),
  -- ... (17개 모두)
```

---

## 🚀 개발 단계

### Phase 0: 프로젝트 설정 (1-2일)
**목표**: 개발 환경 구축 및 자동화 설정

#### Step 0.1: Git 설정
- [x] GitHub 저장소 생성
- [ ] 브랜치 전략 설정 (`main`, `develop`, `feature/*`)
- [ ] GitHub Actions 워크플로우 작성
- [ ] PR 템플릿 생성

#### Step 0.2: Flutter 프로젝트 생성
```bash
flutter create --org com.uncany --platforms web,ios,android uncany
cd uncany
flutter pub add flutter_riverpod go_router supabase_flutter freezed_annotation
flutter pub add --dev build_runner freezed json_serializable
```

#### Step 0.3: Supabase 프로젝트 생성
- [ ] Supabase 프로젝트 생성
- [ ] 환경 변수 설정 (`.env`)
- [ ] 초기 마이그레이션 실행

#### Step 0.4: 문서 자동화 설정
- [ ] `docs/` 폴더 생성
- [ ] CHANGELOG 템플릿 생성
- [ ] Phase 보고서 자동 생성 스크립트

**자동 커밋**: `chore(setup): Phase 0 완료 - 프로젝트 초기 설정`

---

### Phase 1: 인증 시스템 (3-4일)

#### Step 1.1: 데이터베이스 설정
- [ ] `users` 테이블 마이그레이션
- [ ] `education_offices` 테이블 + seed 데이터
- [ ] Row Level Security (RLS) 정책 설정

#### Step 1.2: 재직증명서 업로드
- [ ] Supabase Storage 버킷 생성 (`verification-documents`)
- [ ] 파일 업로드 UI (이미지 크롭 + 미리보기)
- [ ] 개인정보 마스킹 안내 화면

#### Step 1.3: 관리자 승인 대시보드
- [ ] 관리자 전용 라우트 (`/admin/approvals`)
- [ ] 대기 중인 인증 요청 목록
- [ ] 승인/반려 로직 + 알림

#### Step 1.4: 교육청 이메일 인증
- [ ] 이메일 도메인 검증 로직
- [ ] Deep Link 인증 플로우
- [ ] 인증 완료 후 자동 로그인

**자동 문서화**: `docs/PHASE_1_REPORT.md` 생성
**자동 커밋**: `feat(auth): Phase 1 완료 - 인증 시스템 구현`

---

### Phase 2: 예약 시스템 (4-5일)

#### Step 2.1: 교실 관리
- [ ] `classrooms` 테이블 마이그레이션
- [ ] 교실 CRUD API
- [ ] 관리자 교실 등록 UI

#### Step 2.2: 시간표 그리드 UI
- [ ] 토스 스타일 그리드 위젯
- [ ] 상태별 색상 구분 (가능/예약됨/내 예약)
- [ ] 터치 애니메이션

#### Step 2.3: 예약 생성/취소
- [ ] 시간 중복 검증 로직
- [ ] 예약 생성 바텀시트
- [ ] Soft Delete 구현

#### Step 2.4: 비밀번호 보호 교실
- [ ] Argon2 해싱 로직
- [ ] 숫자 키패드 바텀시트
- [ ] 비밀번호 검증

**자동 문서화**: `docs/API.md` 업데이트
**자동 커밋**: `feat(reservation): Phase 2 완료 - 예약 시스템 구현`

---

### Phase 3: 데이터 무결성 (2-3일)

#### Step 3.1: Audit Log 시스템
- [ ] `audit_logs` 테이블 마이그레이션
- [ ] 자동 로깅 미들웨어 (Riverpod Interceptor)
- [ ] JSONB 스냅샷 저장

#### Step 3.2: 히스토리 UI
- [ ] 변경 이력 타임라인
- [ ] Diff 계산 및 시각화
- [ ] 되돌리기 버튼

**자동 커밋**: `feat(audit): Phase 3 완료 - 감사 로그 시스템 구현`

---

### Phase 4: UI/UX 고도화 (3-4일)

#### Step 4.1: 토스 스타일 디자인 시스템
- [ ] 컬러 토큰 정의
- [ ] 타이포그래피 설정 (Pretendard 또는 Noto Sans KR)
- [ ] 공통 위젯 라이브러리 (TossButton, TossCard)

#### Step 4.2: 애니메이션
- [ ] Staggered List 애니메이션
- [ ] 페이지 전환 애니메이션
- [ ] 마이크로 인터랙션 (버튼 클릭 효과)

#### Step 4.3: 반응형 레이아웃
- [ ] Web 데스크톱 레이아웃
- [ ] 태블릿 레이아웃
- [ ] 모바일 최적화

**자동 커밋**: `feat(ui): Phase 4 완료 - 토스 스타일 UI 구현`

---

### Phase 5: 배포 준비 (2-3일)

#### Step 5.1: 테스트 작성
- [ ] Unit 테스트 (비즈니스 로직)
- [ ] Widget 테스트 (UI)
- [ ] Integration 테스트 (E2E)

#### Step 5.2: CI/CD 파이프라인
- [ ] GitHub Actions 테스트 자동화
- [ ] Web 자동 배포 (Firebase Hosting)
- [ ] 앱 빌드 자동화 (Fastlane)

#### Step 5.3: 문서 정리
- [ ] README 최종 업데이트
- [ ] API 문서 완성
- [ ] 사용자 가이드 작성

**자동 커밋**: `chore(deploy): Phase 5 완료 - 배포 준비 완료`

---

## 🌿 Git 브랜치 전략

### 브랜치 구조
```
main (프로덕션)
  └─ develop (개발)
       ├─ feature/auth-system
       ├─ feature/reservation-system
       ├─ feature/audit-log
       └─ feature/ui-enhancement
```

### 규칙
1. **main**: 배포 가능한 안정 버전만
2. **develop**: 개발 통합 브랜치
3. **feature/***: 각 기능 개발
4. **hotfix/***: 긴급 수정

### 자동 머지 규칙
```yaml
# .github/workflows/auto-merge.yml
- feature/* → develop: 테스트 통과 시 자동 머지
- develop → main: Phase 완료 시 수동 승인 후 머지
```

---

## 📊 진행 상황 추적

### 현재 진행 단계
- [x] 프로젝트 계획 수립
- [ ] Phase 0: 프로젝트 설정
- [ ] Phase 1: 인증 시스템
- [ ] Phase 2: 예약 시스템
- [ ] Phase 3: 데이터 무결성
- [ ] Phase 4: UI/UX 고도화
- [ ] Phase 5: 배포 준비

### 예상 일정
- **Phase 0**: 2026-01-04 ~ 2026-01-06
- **Phase 1**: 2026-01-07 ~ 2026-01-10
- **Phase 2**: 2026-01-11 ~ 2026-01-16
- **Phase 3**: 2026-01-17 ~ 2026-01-20
- **Phase 4**: 2026-01-21 ~ 2026-01-25
- **Phase 5**: 2026-01-26 ~ 2026-01-29

**최종 배포 목표**: 2026-01-31

---

## 🔗 관련 링크
- [Supabase 대시보드](#) (TBD)
- [배포 URL - Web](#) (TBD)
- [App Store](#) (TBD)
- [Play Store](#) (TBD)

---

**마지막 업데이트**: 2026-01-05
**다음 마일스톤**: Phase 0 - 프로젝트 설정
