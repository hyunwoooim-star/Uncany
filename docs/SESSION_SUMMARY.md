# Uncany 세션 요약

## 마지막 업데이트: 2026-01-19 (Session 6)

---

### 인수인계 (Claude → Gemini)

#### 완료된 작업 (v0.3.9 - Phase 3-A)

**[NEW] RoomTypeUtils 전역 적용**
- `classroom_list_screen.dart`: `_getRoomTypeIcon()` 제거 → `RoomTypeUtils.getIcon()` 사용
- `reservation_screen.dart`: `_getRoomTypeIcon()` 제거 → `RoomTypeUtils.getIcon()` 사용
- `classroom_form_screen.dart`: `_getRoomTypeIcon()` 제거 → `RoomTypeUtils.getIconFromEnum()` 사용
- `room_type_utils.dart`에 `getIconFromEnum()`, `getColorFromEnum()` 추가

**[NEW] StatusBadge 전역 적용**
- `classroom_list_screen.dart`: `_buildStatusBadge()` 제거 → `StatusBadge` 위젯 사용

**[NEW] Widget 테스트 추가**
- `test/features/reservation/presentation/home/widgets/home_header_test.dart`
  - 사용자 이름 표시, 학년/반 정보 표시, 아이콘 표시, 인사말 테스트
- `test/features/reservation/presentation/home/widgets/quick_action_grid_test.dart`
  - 3개 버튼 표시, 아이콘 표시, 네비게이션 테스트, badge 표시 테스트

**[NEW] ErrorMessages 테스트 버그 수정**
- `'Error code 23505'`가 `'이미 사용 중인 코드입니다'`로 잘못 변환되는 문제 수정
- 코드 중복 판별 조건 개선: `(duplicate && code) || (code && already)`

#### 이전 작업 (v0.3.9 - Phase 2-4 + Phase 2-B)

**[NEW] AsyncNotifier 패턴 도입 (Phase 2-B)**
- `TodayMyReservationController`: 내 예약 관리 (build, refresh, cancelReservation)
- `TodayAllReservationController`: 전체 예약 관리 (build, refresh)
- Optimistic UI 지원 (예약 취소 시 즉시 UI 반영)
- `home_screen.dart`에서 FutureProvider → AsyncNotifier 전환

**[NEW] StatusBadge 적용**
- `today_reservation_list.dart`에서 `_buildStatusBadge()` 중복 제거
- `ReservationGroup`에 `statusText`, `statusColor` getter 추가
- `today_reservation_list.dart` 772줄 → 708줄 (64줄 감소)

**God Object 리팩토링 (Phase 2-4)**
- `home_screen.dart` 1602줄 → 257줄 (84% 감소)
- 5개 컴포넌트로 분리:
  - `home/widgets/home_header.dart` (97줄) - 인사말 카드
  - `home/widgets/quick_action_grid.dart` (123줄) - 빠른 액션
  - `home/widgets/admin_menu_section.dart` (77줄) - 관리자 메뉴
  - `home/widgets/today_reservation_list.dart` (708줄) - 예약 목록

**에러 수정**
- Import 경로 업데이트 (router.dart, my_reservations_screen.dart, reservation_screen.dart)
- `AppLogger.warning` 호출 수정 (classroom_comment_repository.dart, classroom_repository.dart)
- Supabase query 타입 불일치 수정 (classroom_comment_repository.dart)

**테스트 코드 작성**
- `test/core/utils/error_messages_test.dart` (260줄)
- fromAuthError, fromError, isReservationConflictError 등 25개 테스트 케이스

**이전 작업 (v0.3.8-rc)**
- 시간표 대시보드 UI 개선
- 교실 소유권 관리 기능 (`011_classroom_ownership_and_unique.sql`)
- 교실 게시판/댓글 기능 (`012_classroom_comments.sql`)

#### 다음 작업자에게
- ✅ `flutter analyze` 에러 0개 확인됨
- ✅ `dart run build_runner build` 성공
- ✅ God Object 패턴 해소됨
- ✅ AsyncNotifier 패턴 도입됨
- ✅ RoomTypeUtils 전역 적용 완료
- ✅ Widget 테스트 추가됨 (home_header, quick_action_grid)
- ✅ CI 테스트 80개 전부 통과

#### 향후 작업 (권장)
1. **다른 대형 화면 리팩토링** - reservation_screen.dart 등
2. **테스트 커버리지 확대** - 더 많은 Widget 테스트 추가
3. **문서 최신화** - ANALYSIS_REPORT_v0.3.9.md 업데이트

---

## 프로젝트 현재 상태: ✅ v0.3.9 (Phase 2-B 완료, AsyncNotifier 도입)

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
