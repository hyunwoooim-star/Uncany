# Uncany 프로젝트 현황 보고서 (Gemini용)

> 작성: Claude | 날짜: 2026-01-17

## 📋 프로젝트 개요

**Uncany**는 한국 학교 교사들을 위한 교실 예약 관리 시스템입니다.

- **플랫폼**: Flutter Web (모바일 준비 중)
- **버전**: v0.3.5
- **상태**: Staging 테스트 진행 중
- **배포**: https://uncany-staging.web.app

---

## 🏗️ 아키텍처 요약

### Frontend
- **Framework**: Flutter 3.32+
- **상태관리**: Riverpod (FutureProvider, StreamProvider)
- **라우팅**: Go Router
- **UI**: 토스 스타일 디자인 시스템

### Backend
- **Database**: Supabase (PostgreSQL)
- **Auth**: Supabase Auth (JWT)
- **서버리스**: Edge Functions (Deno/TypeScript)
- **스토리지**: Supabase Storage

### 배포
- **호스팅**: Firebase Hosting
- **CI/CD**: GitHub Actions
- **브랜치 전략**: main → production, develop/feature branches → staging

---

## ✅ 완료된 기능

### 1. 인증 시스템
- [x] 로그인/회원가입/로그아웃
- [x] 비밀번호 재설정 (이메일)
- [x] 아이디/비밀번호 찾기
- [x] 아이디 저장/자동 로그인
- [x] 관리자 승인 시스템 (재직증명서 검증)
- [x] 초대 코드 시스템

### 2. 예약 시스템
- [x] 교시 기반 예약 (1~8교시)
- [x] 예약 충돌 방지 (Advisory Lock + Exclusion Constraint)
- [x] 예약 취소 정책 (시작 10분 전까지)
- [x] 종합 시간표 대시보드 (모든 교실 × 교시 그리드)
- [x] N+1 쿼리 최적화 (11개 → 2개 쿼리, 80% 개선)

### 3. 교실 관리
- [x] CRUD (생성/조회/수정/삭제)
- [x] 교실 유형 (일반, 컴퓨터실, 음악실 등)
- [x] 수용인원/위치 정보

### 4. 기타
- [x] 학교 검색 (NEIS 공공 API)
- [x] 법적 문서 (이용약관, 개인정보처리방침)
- [x] 다크 모드 지원
- [x] 반응형 레이아웃

---

## 🔒 보안 구현 현황

### Database Level
```sql
-- 1. Row Level Security (RLS)
- users: 본인 데이터만 수정, 관리자만 승인/삭제
- reservations: 본인 예약만 수정/삭제, 같은 학교 조회 가능
- classrooms: 같은 학교 조회 가능

-- 2. Advisory Lock (동시성 제어)
SELECT pg_advisory_xact_lock(hashtext(classroom_id || DATE));

-- 3. Exclusion Constraint (물리적 중복 방지)
EXCLUDE USING GIST (
  classroom_id WITH =,
  tstzrange(start_time, end_time) WITH &&
) WHERE (deleted_at IS NULL);
```

### Application Level
- JWT 토큰 검증 (모든 API 호출)
- Edge Function에서 API 키 숨김 (클라이언트 노출 방지)
- Soft Delete로 데이터 복구 가능
- 감사 로그 (audit_logs 테이블)

---

## 📁 주요 파일 구조

```
lib/src/
├── core/
│   ├── router/router.dart              # Go Router 설정
│   ├── providers/auth_provider.dart    # 인증 상태
│   ├── services/                       # 비즈니스 서비스
│   └── utils/error_messages.dart       # 에러 한글화
├── features/
│   ├── auth/                           # 인증 (15+ 화면)
│   ├── reservation/                    # 예약 (4 화면)
│   ├── classroom/                      # 교실 (5 화면)
│   └── school/                         # 학교 검색
└── shared/widgets/                     # 토스 스타일 컴포넌트

supabase/
├── migrations/                         # 9개 마이그레이션
└── functions/                          # Edge Functions
    ├── neis-api/                       # 학교 검색 API
    └── delete-account/                 # 계정 삭제

.github/workflows/
├── test.yml                            # 테스트 자동화
├── deploy-web-staging.yml              # Staging 배포
└── deploy-web-preview.yml              # PR Preview
```

---

## ⚠️ 남은 작업

### 우선순위 높음
1. **E2E 테스트 완료** - 모든 기능 Staging에서 검증
2. **SQL 마이그레이션 적용** - `007_fix_user_email_sync.sql` (이메일 동기화)
3. **관리자 승인 테스트** - 재직증명서 업로드 → 승인 플로우

### 우선순위 중간
4. **알림 시스템 (FCM)** - 예약 알림, 승인 알림
5. **Production 환경 설정** - Firebase 프로젝트, Supabase 프로젝트 분리
6. **SHA-1 키 등록** - Android Google 로그인

### 우선순위 낮음
7. **앱스토어 등록** - App Store, Play Store
8. **감사 로그 UI** - 현재 모의 데이터 사용 중

---

## ❓ Gemini에게 질문

### 1. 아키텍처 검토
- 현재 Riverpod + Go Router 구조가 적절한가?
- 상태관리 패턴에 개선점이 있는가?

### 2. 보안 검토
- RLS 정책에 빈틈이 있는가?
- Advisory Lock 외에 추가 동시성 제어가 필요한가?

### 3. 성능 검토
- N+1 최적화 외에 추가 쿼리 최적화 필요한 곳?
- 이미지 압축 방식 (WebP) 적절한가?

### 4. 배포 준비
- Production 배포 전 체크리스트?
- 앱스토어 등록 시 주의사항?

### 5. 기능 우선순위
- 알림 시스템 구현 방향 (FCM vs Supabase Realtime)?
- 오프라인 지원 필요한가?

---

## 📊 코드 통계

- **Dart 파일**: ~80개
- **코드 라인**: ~15,000줄
- **테스트 파일**: 3개 (확장 필요)
- **마이그레이션**: 9개
- **Edge Functions**: 2개

---

## 🔗 참고 링크

- **Staging**: https://uncany-staging.web.app
- **Repository**: (GitHub URL)
- **Supabase Dashboard**: (Supabase URL)

---

## 📝 협업 규칙

### 작업 시작
```bash
git pull
# docs/SESSION_SUMMARY.md 확인
```

### 작업 완료
```bash
git add . && git commit -m "작업 내용" && git push
# docs/SESSION_SUMMARY.md 업데이트
```

### 피드백 포맷
```
[문제] 간단한 설명
[위치] 파일명:라인번호
[현상] 무슨 일이 일어나는지
[예상] 무슨 일이 일어나야 하는지
```

---

> 이 보고서는 Claude가 작성했습니다. Gemini의 피드백을 기다립니다.
