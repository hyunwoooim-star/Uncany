# 🏗️ Uncany 프로젝트 초기 설정 체크리스트

> **목적**: 프로젝트 시작 전 필수 설정 항목 점검
> **최종 업데이트**: 2026-01-04

---

## ✅ 현재 완료 상태

### 1. Git & GitHub 설정
- [x] Git 저장소 초기화
- [x] GitHub 원격 저장소 연결
- [x] 브랜치 생성 (`claude/school-booking-platform-M3ffi`)
- [x] `.gitignore` 설정
- [ ] **main/develop 브랜치 생성 필요** ⚠️
- [ ] **Branch protection rules** (main 브랜치 보호)

### 2. 프로젝트 문서
- [x] `PROJECT_PLAN.md` (마스터 계획서)
- [x] `README.md` (프로젝트 소개)
- [x] `CHANGELOG.md` (변경 이력)
- [x] `LICENSE` (MIT)
- [x] `docs/PROJECT_RULES.md` (개발 규칙)
- [x] `docs/SUPABASE_SETUP.md` (백엔드 가이드)
- [x] `docs/REFERRAL_CODE_DESIGN.md` (기능 설계)
- [x] `docs/PHASE_0_REPORT.md` (진행 보고서)
- [ ] **CONTRIBUTING.md** (기여 가이드)
- [ ] **docs/API.md** (API 문서 템플릿)

### 3. GitHub 자동화
- [x] `.github/workflows/test.yml` (자동 테스트)
- [x] `.github/workflows/auto-docs.yml` (자동 문서화)
- [x] `.github/PULL_REQUEST_TEMPLATE.md`
- [ ] **Issue 템플릿** (버그, 기능 요청)
- [ ] **GitHub Actions Secrets** (Supabase 키 등)
- [ ] **Dependabot** (의존성 자동 업데이트)

### 4. 환경 설정
- [x] `.env.example` (환경 변수 템플릿)
- [ ] **사용자가 `.env` 파일 생성 필요** 📝
- [ ] **Supabase URL/Key 입력 필요** (계정 생성 후)

---

## ⚠️ 현재 누락된 항목

### 1. 백엔드 (Supabase)
```
[ ] Supabase 계정 생성 (사용자 작업 예정)
[ ] 프로젝트 생성
[ ] 데이터베이스 마이그레이션 실행
[ ] Storage 버킷 생성
[ ] RLS 정책 설정
[ ] .env 파일에 Credentials 추가
```

**상태**: 📋 가이드 문서 준비 완료, 실행 대기 중

---

### 2. 프론트엔드 (Flutter)
```
[ ] Flutter SDK 설치 확인
[ ] Flutter 프로젝트 생성
[ ] pubspec.yaml 의존성 설정
[ ] 폴더 구조 생성 (Feature-First)
[ ] analysis_options.yaml (린터 규칙)
[ ] 기본 파일 생성 (main.dart, app.dart)
```

**상태**: ❌ Flutter SDK 미설치 감지

---

### 3. 개발 환경
```
[ ] VSCode/Android Studio 설정 파일
    - .vscode/launch.json (디버그 설정)
    - .vscode/settings.json (에디터 설정)
[ ] 코드 포맷터 설정
[ ] 린터 규칙 통일
```

**상태**: ⚠️ IDE 설정 필요

---

### 4. CI/CD 파이프라인
```
[x] 테스트 자동화 (test.yml)
[ ] Web 배포 자동화 (Firebase Hosting)
[ ] iOS 빌드 자동화 (Fastlane)
[ ] Android 빌드 자동화 (Fastlane)
[ ] GitHub Secrets 설정
    - SUPABASE_URL
    - SUPABASE_ANON_KEY
    - FIREBASE_TOKEN (배포용)
```

**상태**: ⚠️ 배포 워크플로우 미설정

---

### 5. 프로젝트 관리
```
[ ] GitHub Projects 보드 생성
[ ] Milestones 설정 (Phase별)
[ ] Issue 라벨 생성 (bug, enhancement, docs 등)
[ ] Wiki 활성화 (선택)
```

**상태**: ⚠️ 프로젝트 관리 도구 미설정

---

## 🔥 즉시 필요한 작업 (우선순위)

### Priority 1: 필수 (지금 해야 함)
1. **Flutter SDK 설치 확인**
   ```bash
   # 설치 여부 확인
   flutter --version

   # 미설치 시 설치 필요
   # https://docs.flutter.dev/get-started/install
   ```

2. **main/develop 브랜치 생성**
   ```bash
   git checkout -b develop
   git push -u origin develop

   git checkout -b main
   git push -u origin main
   ```

3. **GitHub 기본 브랜치 설정**
   - GitHub 저장소 → Settings → Branches
   - Default branch를 `main` 또는 `develop`으로 설정

---

### Priority 2: 중요 (Phase 1 전)
1. **Issue/PR 템플릿 생성**
2. **VSCode 설정 파일**
3. **GitHub Secrets 설정** (Supabase 생성 후)

---

### Priority 3: 추후 (Phase 2-3)
1. **배포 자동화**
2. **GitHub Projects 보드**
3. **Dependabot 설정**

---

## 📋 체크리스트 요약

### Git & 저장소
- [x] Git 초기화
- [x] GitHub 연결
- [ ] 브랜치 전략 완료
- [ ] Branch protection

### 문서
- [x] 필수 문서 (8개)
- [ ] 선택 문서 (2개)

### 자동화
- [x] CI/CD 기본
- [ ] 배포 자동화
- [ ] 의존성 관리

### 개발 환경
- [ ] Flutter SDK
- [ ] IDE 설정
- [ ] 린터/포맷터

### 백엔드
- [ ] Supabase 계정
- [ ] DB 마이그레이션
- [ ] 환경 변수

---

## 🚨 치명적 누락 항목

### 1. Flutter SDK 미설치
**문제**: `flutter: command not found`
**해결**:
- Windows: https://docs.flutter.dev/get-started/install/windows
- macOS: `brew install flutter`
- Linux: https://docs.flutter.dev/get-started/install/linux

**우선순위**: 🔥 **즉시**

---

### 2. 브랜치 전략 미완료
**문제**: 현재 `claude/school-booking-platform-M3ffi` 브랜치만 존재
**해결**:
```bash
# develop 브랜치 생성 (개발 통합용)
git checkout -b develop
git push -u origin develop

# main 브랜치 생성 (프로덕션)
git checkout -b main
git push -u origin main

# GitHub에서 기본 브랜치 설정
```

**우선순위**: 🔥 **즉시**

---

### 3. 환경 변수 파일 누락
**문제**: `.env` 파일 없음 (`.env.example`만 존재)
**해결**: Supabase 계정 생성 후 생성
**우선순위**: ⚠️ **Supabase 생성 후**

---

## 🎯 권장 진행 순서

### 지금 즉시 (5분)
1. main/develop 브랜치 생성
2. GitHub 기본 브랜치 설정
3. Issue 템플릿 생성

### Supabase 생성 전 (30분)
1. Flutter SDK 설치
2. VSCode 설정 파일 생성
3. 린터 규칙 설정

### Supabase 생성 후 (1시간)
1. .env 파일 생성
2. Flutter 프로젝트 생성
3. Supabase 연동 테스트

---

## ✅ 자가 진단 체크리스트

실행해보세요:

```bash
# 1. Git 설정 확인
git remote -v
git branch -a

# 2. Flutter 설치 확인
flutter --version

# 3. 문서 존재 확인
ls -la docs/

# 4. 환경 변수 확인
cat .env.example

# 5. GitHub Actions 확인
ls -la .github/workflows/
```

---

## 🔜 다음 액션

### 제가 지금 할 수 있는 것:
1. ✅ main/develop 브랜치 생성
2. ✅ Issue 템플릿 생성
3. ✅ VSCode 설정 파일 생성
4. ✅ 린터 설정 파일 생성
5. ✅ CONTRIBUTING.md 작성

### 사용자가 해야 하는 것:
1. 📝 Flutter SDK 설치 (선택: 제가 가이드 제공 가능)
2. 📝 Supabase 계정 생성 (나중에)

---

**어떻게 할까요?**
1. 제가 지금 할 수 있는 5가지를 바로 진행할까요?
2. 아니면 특정 항목부터 시작할까요?

말씀해주세요!
