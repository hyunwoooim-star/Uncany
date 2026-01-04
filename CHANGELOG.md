# Changelog

모든 주요 변경사항은 이 파일에 자동으로 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/)를 따르며,
이 프로젝트는 [Semantic Versioning](https://semver.org/lang/ko/)을 준수합니다.

## [Unreleased]

### Added
- Supabase 설정 가이드 문서 (`docs/SUPABASE_SETUP.md`)
- 추천인 코드 시스템 설계 문서 (`docs/REFERRAL_CODE_DESIGN.md`)
- 추천인 코드 기능 재추가 (같은 학교 제약 조건)
- `referral_codes`, `referral_usage` 테이블 스키마

### Changed
- 추천인 코드 정책 수정: 신뢰 점수 제거, 같은 학교 제약만 유지
- PROJECT_PLAN.md 업데이트 (ERD 및 스키마 반영)

### Planned
- Supabase 계정 생성 및 프로젝트 설정
- Flutter 프로젝트 생성
- 인증 시스템 구현

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
