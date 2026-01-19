# Uncany 세션 요약

## 마지막 업데이트: 2026-01-19 (Session 2)

---

### 인수인계 (Claude → 다음 작업자)

#### 완료된 작업 (v0.3.8-rc)

**[NEW] 시간표 대시보드 UI 개선**
- 세로 구분선 추가로 열 가독성 향상
- 폰트 크기 증가 (11px→13px, 10px→12px)
- 헤더 배경색 및 스타일 개선
- 범례 위젯에 아이콘 추가

**[NEW] 교실 소유권 관리 기능** (`011_classroom_ownership_and_unique.sql`)
- 동명 교실 생성 방지 (UNIQUE 제약: school_id + name)
- 교실 수정/삭제 권한 제한 (생성자 또는 관리자만)
- 생성자 정보 표시 (학년-반 이름)
- `check_classroom_name_exists()` RPC 함수 추가

**[NEW] 교실 게시판/댓글 기능** (`012_classroom_comments.sql`)
- 댓글 유형: 일반(general), 문제신고(issue), 공지(notice)
- 문제 해결 워크플로우 (is_resolved, resolved_by)
- `resolve_classroom_issue()` RPC 함수
- `get_classroom_unresolved_count()` RPC 함수
- DraggableScrollableSheet UI 구현

**이전 작업 (v0.3.7-rc)**
- 완료: **추천인 코드 RLS 정책 + RPC 함수** (`010_fix_referral_codes_rls.sql`)
- 완료: **SignupScreen 추천인 코드 로직 개선** - RPC 함수 호출로 변경
- 완료: **Provider Invalidation 개선** - `classroomReservationsStreamProvider` 추가
- 완료: 홈화면 UI 개선 (접기/펼치기 버튼, 용어 변경)
- 완료: TossSnackBar 전역 적용
- 완료: 동시 예약 충돌 방지 분석 (Advisory Lock + Exclusion Constraint 이미 구현됨)

#### 다음 작업자에게
- **필수**: Supabase에서 011, 012 마이그레이션 적용 완료됨 ✅
- Freezed 코드 생성 필요 (`dart run build_runner build`)
- 주의사항: 배포 후 브라우저 캐시 클리어 필요 (Ctrl+Shift+R)

#### 향후 작업 (권장)
- Home Screen 리팩토링 (1595줄 → AsyncNotifier 패턴)
- Realtime 구독에 school_id 필터 추가
- Invalidation 상수화 또는 Event Bus 도입

---

## 프로젝트 현재 상태: ✅ v0.3.7-rc (Gemini 최종 검토 대기)

### 완료된 핵심 기능
- 인증 시스템 (로그인/회원가입/로그아웃/비밀번호 재설정)
- 예약 시스템 (교시 기반, Advisory Lock으로 동시성 제어)
- 교실 관리 (CRUD + 수정 UI)
- 프로필 관리 (학년/반 정보)
- 관리자 기능 (사용자 승인/반려/삭제)
- 법적 문서 (이용약관, 개인정보처리방침, 사업자 정보)
- 아이디 찾기/비밀번호 찾기
- 학교 검색 (NEIS API 연동)
- 승인 대기 온보딩 화면 (토스 스타일)
- 토스 스타일 UI 컴포넌트 (bouncing button, skeleton, animations 등)
- **아이디 저장 / 자동 로그인 기능** (NEW)

---

## 최근 완료된 작업 (2026-01-15 ~ 01-16)

### UI/UX 개선
- [x] **아이폰 로딩 화면 개선** (web/index.html)
  - 흰색 → 앱 배경색(#F2F4F6)으로 변경
  - 로딩 스피너 + 로고 애니메이션 추가
  - iOS PWA 메타 태그 보강

- [x] **수업 예약 화면 교실 정보 개선** (classroom_list_screen.dart)
  - 교실 유형별 아이콘 표시
  - 위치 + 수용인원 표시
  - **수정 버튼(설정 아이콘) 추가** → 교실 정보 수정 가능
  - 공지사항 강조 표시 (오렌지 배경)

- [x] **홈 화면 레이아웃 개선** (home_screen.dart)
  - 빠른 메뉴를 컴팩트한 2열 그리드로 변경
  - "빠른 메뉴" 섹션 제목 제거 → 상단에 바로 배치
  - 중복 느낌 해소
  - 관리자 메뉴도 컴팩트하게 개선

### 버그 수정
- [x] **프로필 화면 "위험 구역" 계정 삭제** → "계정 관리"로 변경
- [x] **교시 표시 버그 수정** (3,6교시 → "3, 6교시"로 올바르게 표시)
- [x] **날짜 변경 시 이전 데이터 초기화**

### v0.3.4 업데이트 (2026-01-16)

#### 아이디/비밀번호 찾기 버그 수정
- [x] **이메일 동기화 트리거 추가** (007_fix_user_email_sync.sql)
  - auth.users → public.users 이메일 자동 동기화
  - 기존 사용자 이메일 일괄 동기화 SQL 포함
  - get_username_by_email 함수 대소문자 무시 개선
- [x] **회원가입 시 이메일 명시적 저장** (signup_screen.dart)

#### 로그인 설정 기능 추가
- [x] **아이디 저장 체크박스** - 다음 로그인 시 자동 입력
- [x] **자동 로그인 체크박스** - 세션 유지
- [x] **LoginPreferencesService** 서비스 추가 (SharedPreferences 사용)
- [x] 로그아웃 시 자동 로그인 해제
- [x] 계정 삭제 시 모든 로그인 설정 초기화

### v0.3.8 업데이트 (2026-01-19) - 교실 기능 강화

#### 시간표 대시보드 UI 개선
- [x] **세로 구분선 추가** - 열 간 가독성 향상
- [x] **폰트 크기 증가** - 헤더 11→13px, 셀 10→12px
- [x] **헤더 스타일 개선** - 배경색, 그림자 추가
- [x] **범례 아이콘 추가** - 예약 상태별 시각적 구분

#### 교실 소유권 관리 (011_classroom_ownership_and_unique.sql)
- [x] **동명 교실 방지** - UNIQUE(school_id, name) 제약 추가
- [x] **수정/삭제 권한 제한** - RLS 정책: 생성자 또는 관리자만
- [x] **생성자 정보 표시** - classroom_detail_screen에 학년-반 이름 표시
- [x] **중복 체크 RPC** - `check_classroom_name_exists()` 함수

#### 교실 게시판/댓글 (012_classroom_comments.sql)
- [x] **댓글 테이블** - classroom_comments (content, comment_type, is_resolved)
- [x] **댓글 유형** - general(일반), issue(문제신고), notice(공지)
- [x] **문제 해결 플로우** - resolve_classroom_issue() RPC
- [x] **미해결 카운트** - get_classroom_unresolved_count() RPC
- [x] **UI 구현** - ClassroomCommentsSheet (DraggableScrollableSheet)
- [x] **Freezed 모델** - ClassroomComment, CommentType enum

#### 변경된 파일
```
supabase/migrations/011_classroom_ownership_and_unique.sql (NEW)
supabase/migrations/012_classroom_comments.sql (NEW)
lib/src/features/classroom/domain/models/classroom.dart (생성자 정보 추가)
lib/src/features/classroom/domain/models/classroom_comment.dart (NEW)
lib/src/features/classroom/data/repositories/classroom_repository.dart (JOIN, 중복체크)
lib/src/features/classroom/data/repositories/classroom_comment_repository.dart (NEW)
lib/src/features/classroom/data/providers/classroom_repository_provider.dart (댓글 프로바이더)
lib/src/features/classroom/presentation/classroom_form_screen.dart (중복 이름 체크)
lib/src/features/classroom/presentation/classroom_detail_screen.dart (생성자 표시, 댓글 FAB)
lib/src/features/classroom/presentation/widgets/classroom_comments_sheet.dart (NEW)
lib/src/features/reservation/presentation/timetable_dashboard_screen.dart (UI 개선)
```

### v0.3.6 업데이트 (2026-01-19)

#### UI/UX 개선
- [x] **홈화면 대폭 개선** (home_screen.dart)
  - "나의 예약" 섹션 분리 (내 예약만 표시)
  - "오늘의 전체 예약 현황" 접기/펼치기 기능
  - 예약 요약 색상: 초록색 → 파란색 (기존 컨셉 유지)
  - 명확한 "펼치기/접기" 버튼 추가
- [x] **교시 표시 로직 개선** - 연속 범위 그룹화 ("2, 3, 6교시" → "2~3, 6교시")
- [x] **내 예약 화면 용어 변경** - "완료" 탭 → "이전예약" 탭
- [x] **TossSnackBar 전역 적용** - 모든 SnackBar를 토스 스타일로 통일
  - 둥근 알약 모양 (borderRadius: 50)
  - 중앙 정렬, 아이콘 포함
  - success(녹색), error(빨간색), warning(주황색), info(파란색) 타입
- [x] **시간표 셀 정보 확장** - 학년-반 + 교사명 2줄 표시 (예: "3-2" / "임현우")
- [x] **홈화면 예약 그룹화** - 같은 교실+선생님 예약 합산 표시 (예: "1~6교시")
- [x] **교실 카드 공지사항 표시** - 공지 내용을 카드에 직접 표시 (주황색 박스)

#### 분석 완료
- [x] **데이터 동기화 문제 분석 및 해결**
  - Provider 무효화 불완전 문제 식별 (`todayAllReservationsProvider` 누락)
  - Race condition 취약점 분석 → Advisory Lock 이미 구현됨 확인
  - Realtime 미활용 문제 식별
- [x] **추천인코드 생성 실패 원인 분석**
  - `referral_codes` 테이블 RLS 활성화되어 있지만 정책(POLICY) 없음
  - `increment_referral_uses` RPC 함수 누락
  - 상세 내용: `docs/GEMINI_REPORT.md` 참조

#### 버그 수정
- [x] **데이터 동기화 수정** (reservation_screen.dart, my_reservations_screen.dart)
  - 예약 생성/취소 시 모든 Provider 무효화 추가

### v0.3.5 업데이트 (2026-01-17)

#### 코드 품질 개선
- [x] **Lint 경고 수정**
  - analysis_options.yaml: Dart 3.7.0에서 제거된 lint 규칙 주석 처리
  - datetime_extensions.dart: 불필요한 this. 제거
  - router.dart: import 알파벳순 정렬, deprecated RouterRef → Ref 변경
  - image_compressor_v2.dart: 불필요한 import 및 await 제거

#### 성능 최적화
- [x] **시간표 대시보드 N+1 쿼리 최적화**
  - ReservationRepository: getAllReservationsForDate() 메서드 추가
  - TimetableDashboardScreen: Future.wait로 병렬 쿼리 실행
  - 기존 N+1 쿼리 → 2개 쿼리로 개선 (교실 10개 기준 약 80% 쿼리 감소)

#### 에러 UX 개선
- [x] **DB 에러 메시지 한글화** - PostgrestException 친화적 메시지 변환
- [x] **스켈레톤 로딩** - 모든 화면에 Shimmer 로딩 적용

#### 기능 추가
- [x] **종합 시간표 대시보드** - 모든 교실 × 교시 그리드 뷰
- [x] **예약 취소 정책** - 시작 10분 전까지만 취소 가능

#### CI/CD 개선
- [x] **워크플로우 브랜치 패턴 추가** - fix/**, perf/** 브랜치 자동 빌드

#### Staging 배포 설정
- [x] **dazzling-swirles 브랜치 Staging 배포 추가** - deploy-web-staging.yml 업데이트

### 커밋 내역
```
230a5a8 ci: dazzling-swirles 브랜치 Staging 배포 추가
d31db7c docs: 세션 요약 업데이트 (v0.3.5 작업 내역)
da9e980 ci: perf/** 브랜치 패턴 추가
1bb9f9d perf: 시간표 대시보드 N+1 쿼리 최적화
46db640 ci: fix/** 브랜치 패턴 추가
397eae7 refactor: lint 경고 수정 및 코드 정리
449f7cd fix: 코드 품질 개선 및 에러 수정
06608de feat: 예약 취소 정책 구현 (시작 10분 전까지)
1311d6c feat: 종합 시간표 대시보드 추가
5f5e98b feat: 에러 UX 개선 및 스켈레톤 로딩 적용
```

### 이전 커밋 내역 (v0.3.4)
```
6efab51 feat: 아이디/비밀번호 찾기 버그 수정 및 로그인 설정 기능 추가
191e85c feat: UI/UX 대폭 개선
7a070c1 docs: 세션 요약 업데이트 (2026-01-15 작업 내역)
19db533 fix: 프로필 화면 UX 개선 및 교시 표시 버그 수정
```

---

## 다음에 할 작업

### 즉시 수동 작업 필요 (Supabase Dashboard)
1. **⚠️ SQL 마이그레이션 적용** - `007_fix_user_email_sync.sql` 실행
   - Supabase Dashboard → SQL Editor → 파일 내용 복사 후 실행
   - 기존 사용자 이메일 동기화 + 트리거 생성

### Staging 테스트 완료 (2026-01-17)
- [x] **종합 시간표 대시보드** - 모든 교실 × 교시 그리드 뷰 정상 작동
- [x] **N+1 쿼리 최적화** - 병렬 쿼리로 빠른 로딩 확인
- [x] **예약 취소 정책** - 코드 검증 완료 (시작 10분 전 제한)

### 즉시 테스트 필요
1. **아이디/비밀번호 찾기** - 마이그레이션 적용 후 테스트
2. **아이디 저장/자동 로그인** - 로그인 화면에서 체크박스 테스트
3. **아이폰 로딩 화면** - 앱 배경색으로 표시되는지 확인

### 우선순위 높음
- Staging 전체 기능 E2E 테스트
- 관리자 계정으로 사용자 승인 테스트

### 우선순위 중간
- SHA-1 키 Supabase 등록 (Android Google 로그인)
- 알림 시스템 (FCM)
- Production 환경 설정

### 우선순위 낮음
- 앱스토어 등록 준비

---

## Supabase 설정 현황

| 항목 | 상태 | 비고 |
|------|------|------|
| Edge Functions | ✅ | neis-api, delete-account |
| Secrets | ✅ | NEIS_API_KEY |
| Storage Bucket | ✅ | verification-documents |
| Redirect URLs | ✅ | localhost + staging |
| RPC 함수 | ✅ | get_username_by_email (대소문자 무시) |
| Auth 트리거 | ⚠️ | handle_new_user, sync_user_email (마이그레이션 필요) |

---

## 배포 현황

| 환경 | URL | 상태 |
|------|-----|------|
| Staging | https://uncany-staging.web.app | ✅ 배포됨 |
| Production | - | 미설정 |

---

## 주요 파일 위치

```
lib/src/core/router/router.dart                    # 라우트 정의
lib/src/core/services/login_preferences_service.dart  # 로그인 설정 (SharedPreferences)
lib/src/features/auth/                             # 인증 관련
lib/src/features/reservation/                      # 예약 관련
lib/src/features/classroom/                        # 교실 관련
lib/src/features/school/                           # 학교 검색 (NEIS API)
lib/src/shared/widgets/                            # 토스 스타일 컴포넌트
web/index.html                                     # 로딩 화면
supabase/migrations/                               # DB 마이그레이션
supabase/functions/                                # Edge Functions
```

---

## 알려진 이슈

1. **audit_log_screen.dart**: 모의 데이터 사용 중
2. **Deploy Web Preview**: GitHub 권한 문제 (앱 동작에 영향 없음)
