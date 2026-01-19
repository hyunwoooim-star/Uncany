# Changelog

모든 주요 변경사항은 이 파일에 자동으로 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/)를 따르며,
이 프로젝트는 [Semantic Versioning](https://semver.org/lang/ko/)을 준수합니다.

## [Unreleased]

### Planned
- v0.4.0 기능 계획 예정

---

## [0.3.9] - 2026-01-19

### Added
- **Widget 테스트 17개 추가**
  - `home_header_test.dart` (6개): 인사말, 학년/반 표시 테스트
  - `quick_action_grid_test.dart` (11개): 액션 버튼 및 배지 테스트
- **AsyncNotifier 패턴 도입** (4개)
  - `TodayReservationsNotifier`: 오늘 내 예약
  - `TodayAllReservationsNotifier`: 오늘 전체 예약
  - `TodayTeacherCountNotifier`: 교사 수 카운트
  - `TeacherReservationsNotifier`: 교사별 예약
- **공통 위젯 추출**
  - `StatusBadge`: 예약 상태 배지 (진행중/예정/완료)
  - `RoomTypeUtils.getIconFromEnum()`, `getColorFromEnum()`: RoomType enum 지원

### Changed
- **home_screen.dart 대규모 리팩토링** (1602줄 → 293줄, 82% 감소)
  - `home/widgets/` 폴더로 6개 위젯 분리
  - `home/providers/` 폴더로 4개 AsyncNotifier 분리
- **RoomTypeUtils 전역 적용** (3개 화면)
  - `classroom_list_screen.dart`
  - `reservation_screen.dart`
  - `classroom_form_screen.dart`
- **StatusBadge 전역 적용** (2개 화면)
  - `classroom_list_screen.dart`
  - `classroom_detail_screen.dart`

### Fixed
- **ErrorMessages 버그 수정**: `'Error code 23505'`가 잘못된 메시지로 변환되던 문제
  - 원인: `message.contains('code')` 조건이 너무 광범위
  - 해결: `(duplicate && code) || (code && already)` 패턴으로 변경

### Tests
- CI 테스트: 80개 전부 통과 ✅
- 테스트 파일: 5개 (이전: 2개)
- 테스트 케이스: 80개 (이전: 37개)

### Meta
- **Phase**: v0.3.9 완료
- **담당**: Claude (Opus 4.5), Gemini 검토
- **문서**: `docs/PHASE3-A_COMPLETION_REPORT.md`, `docs/ANALYSIS_REPORT_v0.3.9.md`

---

## [0.3.8] - 2026-01-18

### Added
- 교실 댓글/게시판 기능 (012_classroom_comments.sql)
- 교실 소유권 관리 (011_classroom_ownership_and_unique.sql)

---

## [0.3.7] - 2026-01-17

### Fixed
- 추천인 코드 RLS 정책 수정 (010_fix_referral_codes_rls.sql)

---

## [0.3.6] - 2026-01-16

### Changed
- 시간표 대시보드 UI 개선

---

## [0.1.0] - 2026-01-04 ~ 0.3.5

### Added
- Supabase 설정 가이드 문서 (`docs/SUPABASE_SETUP.md`)
- 추천인 코드 시스템 설계 문서 (`docs/REFERRAL_CODE_DESIGN.md`)
- 추천인 코드 기능 재추가 (같은 학교 제약 조건)
- `referral_codes`, `referral_usage` 테이블 스키마

### Changed
- 추천인 코드 정책 수정: 신뢰 점수 제거, 같은 학교 제약만 유지
- PROJECT_PLAN.md 업데이트 (ERD 및 스키마 반영)

---

## [0.1.0] - 2026-01-04

### Added
- 프로젝트 계획서 (`PROJECT_PLAN.md`) 생성
- 변경 이력 추적 파일 (`CHANGELOG.md`) 생성
- Git 저장소 초기화

### Meta
- **Phase**: 0 - 프로젝트 설정
- **담당**: Claude (AI Assistant)
- **다음 단계**: Flutter 프로젝트 생성 및 Supabase 연동
