# 📱 모바일 워크플로우 가이드

> 핸드폰만으로 Uncany 프로젝트 개발, 테스트, 배포하기

**작성일**: 2026-01-04
**대상**: 로컬 환경 없이 모바일에서만 작업하는 개발자
**난이도**: 초급 ~ 중급

---

## 📋 목차

1. [시작하기 전에](#시작하기-전에)
2. [필수 앱 설치](#필수-앱-설치)
3. [기본 워크플로우](#기본-워크플로우)
4. [시나리오별 가이드](#시나리오별-가이드)
5. [트러블슈팅](#트러블슈팅)
6. [팁 & 트릭](#팁--트릭)

---

## 🎯 시작하기 전에

### 이 가이드가 해결하는 문제

**문제**:
- 💻 로컬 컴퓨터에 자주 접근할 수 없음
- 🏃 이동 중에도 코드 수정 및 배포가 필요함
- 🔨 Flutter 개발 환경 설정이 어려움
- 🧪 실제 디바이스에서 테스트하고 싶음

**해결책**:
- ✅ GitHub 웹/앱으로 코드 수정
- ✅ GitHub Actions가 자동으로 빌드/테스트/배포
- ✅ 배포된 Web/App을 모바일에서 직접 테스트
- ✅ 로컬 환경 불필요

### 작업 가능한 것

| 작업 | 모바일 가능 여부 | 방법 |
|------|----------------|------|
| 코드 수정 | ✅ 완전 가능 | GitHub 앱/웹 |
| 커밋/푸시 | ✅ 완전 가능 | GitHub 앱/Git 클라이언트 |
| PR 생성/리뷰 | ✅ 완전 가능 | GitHub 앱 |
| 테스트 확인 | ✅ 완전 가능 | GitHub Actions 로그 |
| Web 앱 테스트 | ✅ 완전 가능 | Preview URL 접속 |
| Android 앱 테스트 | ✅ 완전 가능 | Play Store Internal Testing |
| iOS 앱 테스트 | ✅ 완전 가능 | TestFlight |
| 코드 생성 (build_runner) | ✅ 자동 | GitHub Actions |
| 디버깅 | ⚠️ 제한적 | 로그 확인만 가능 |
| Hot Reload | ❌ 불가능 | 로컬 개발 환경 필요 |

---

## 📲 필수 앱 설치

### 1. GitHub (필수) ⭐⭐⭐⭐⭐

**용도**: 코드 수정, 커밋, PR, Actions 확인

**다운로드**:
- iOS: [App Store](https://apps.apple.com/app/github/id1477376905)
- Android: [Play Store](https://play.google.com/store/apps/details?id=com.github.android)

**주요 기능**:
- 파일 편집 및 커밋
- PR 생성 및 리뷰
- Actions 워크플로우 상태 확인
- 알림 수신

### 2. Working Copy (iOS) / MGit (Android) - 선택사항 ⭐⭐⭐⭐

**용도**: 더 강력한 Git 클라이언트 (복잡한 작업 시)

**다운로드**:
- iOS: [Working Copy](https://apps.apple.com/app/working-copy/id896694807)
- Android: [MGit](https://play.google.com/store/apps/details?id=com.manichord.mgit)

**언제 필요한가**:
- 여러 파일 동시 수정
- 브랜치 관리
- 로컬 커밋 후 푸시
- Merge conflict 해결

### 3. 모바일 브라우저 (필수) ⭐⭐⭐⭐⭐

**용도**: GitHub 웹 접속, Preview 테스트

**권장**:
- iOS: Safari 또는 Chrome
- Android: Chrome

### 4. Code Editor 앱 (선택사항) ⭐⭐⭐

**용도**: 더 나은 코드 편집 경험

**추천 앱**:
- **Textastic** (iOS, 유료): 문법 하이라이팅, 파일 관리
- **Acode** (Android, 무료): 오픈소스 코드 에디터
- **Koder** (iOS, 무료): 가벼운 코드 에디터

**연동 방법**:
- Working Copy와 연동 가능
- GitHub 파일 직접 수정 가능

---

## 🔄 기본 워크플로우

### 전체 플로우 다이어그램

```
[모바일에서 코드 수정]
        ↓
[GitHub 앱으로 커밋 & 푸시]
        ↓
[GitHub Actions 자동 실행]
  ├─ 코드 생성 (build_runner)
  ├─ 테스트 실행
  ├─ 빌드 (Web/Android/iOS)
  └─ 배포 (Firebase/Play Store/TestFlight)
        ↓
[배포 완료 알림 수신]
        ↓
[모바일에서 Preview/Staging 앱 테스트]
        ↓
[문제 발견 시 → 다시 코드 수정]
또는
[완료 시 → PR 머지 → Production 배포]
```

### Step-by-Step 가이드

#### Step 1: 작업 브랜치 생성

**GitHub 앱**:
```
1. Repository 열기
2. 상단 "main" 브랜치 탭
3. "New branch" 입력창에 브랜치명 입력
   예: feature/add-notification-badge
4. "Create branch from 'develop'" 클릭
```

**GitHub 웹**:
```
1. Repository 페이지
2. 브랜치 드롭다운 클릭
3. 브랜치명 입력 후 "Create branch"
```

#### Step 2: 파일 수정

**GitHub 앱** (간단한 수정):
```
1. Repository → Files 탭
2. 수정할 파일 찾아 클릭
3. 우상단 "⋮" → "Edit file"
4. 코드 수정
5. 하단 "Commit changes" 버튼
6. 커밋 메시지 입력 (예: "feat: 알림 뱃지 추가")
7. "Commit to [브랜치명]" 클릭
```

**Working Copy** (복잡한 수정):
```
1. Repository 클론 (처음 한 번만)
2. 브랜치 체크아웃
3. 파일 수정 (내장 에디터 or 외부 에디터)
4. Stage → Commit → Push
```

**GitHub 웹 (PC/태블릿에서 더 편함)**:
```
1. 파일 클릭 → 연필 아이콘 ("Edit this file")
2. 코드 수정
3. 하단 "Commit changes" 섹션에서:
   - 커밋 메시지 입력
   - 브랜치 선택 (현재 브랜치 또는 새 브랜치)
   - "Commit changes" 클릭
```

#### Step 3: GitHub Actions 자동 실행 확인

**푸시 후 자동으로**:
```
1. GitHub Actions가 워크플로우 실행:
   - 코드 분석 (flutter analyze)
   - 테스트 실행 (flutter test)
   - 코드 생성 (build_runner)
   - 빌드 (Web/Android)
   - 배포 (환경에 따라)
```

**확인 방법 (GitHub 앱)**:
```
1. Repository → Actions 탭
2. 최근 워크플로우 확인 (초록색 체크 or 빨간색 X)
3. 워크플로우 클릭 → 각 Job 상태 확인
4. 실패 시 로그 확인 가능
```

**알림 받기**:
```
Settings → Notifications → Actions
- "Workflow runs on push or pull request" 활성화
- 모바일로 실시간 알림 수신
```

#### Step 4: PR 생성 및 Preview 배포

**PR 생성 (GitHub 앱)**:
```
1. Repository → Pull requests 탭
2. 상단 "New" 버튼
3. base: develop ← compare: [작업 브랜치]
4. 제목 및 설명 작성
5. "Create pull request" 클릭
```

**PR 생성 시 자동으로**:
```
- Preview 배포 워크플로우 실행
- Web: Firebase Preview 채널 배포
- Android: Internal Testing 업로드 (선택 가능)
- PR 코멘트에 Preview URL 자동 추가
```

**Preview URL 확인**:
```
1. PR 페이지 하단 코멘트 확인
2. Bot이 자동으로 댓글 작성:
   "🚀 Preview deployed!
    Web: https://uncany-pr-123.web.app
    Android: [Play Store Internal Testing 링크]"
3. URL 클릭하여 모바일 브라우저에서 테스트
```

#### Step 5: 테스트 및 수정

**Web 앱 테스트**:
```
1. Preview URL 접속
2. 모바일 브라우저에서 기능 테스트
3. 문제 발견 시:
   - GitHub 앱으로 다시 파일 수정
   - 커밋 & 푸시
   - 자동으로 Preview 재배포
```

**Android 앱 테스트** (Internal Testing 활성화 시):
```
1. Play Store Internal Testing 링크 접속
2. "테스터 참여" 클릭
3. "다운로드" → 앱 설치
4. 실제 디바이스에서 테스트
```

**iOS 앱 테스트** (TestFlight 활성화 시):
```
1. TestFlight 앱 설치
2. 초대 링크 클릭
3. "설치" → 앱 테스트
```

#### Step 6: PR 머지 및 배포

**승인 및 머지 (GitHub 앱)**:
```
1. PR 페이지에서 "Merge pull request" 버튼
2. 머지 후:
   - develop 브랜치: Staging 배포 자동 실행
   - main 브랜치: Production 배포 자동 실행
```

**배포 확인**:
```
1. Actions 탭에서 배포 워크플로우 확인
2. 완료 후 Staging/Production URL 접속하여 확인
```

---

## 🎬 시나리오별 가이드

### 시나리오 1: 간단한 텍스트 수정 (5분)

**예**: 버튼 텍스트 변경

**과정**:
```
1. GitHub 앱 열기
2. Repository → Files → lib/src/features/auth/presentation/login_screen.dart
3. "⋮" → "Edit file"
4. 48번 줄 "로그인" → "로그인하기" 수정
5. Commit changes:
   Message: "fix: 로그인 버튼 텍스트 수정"
   Branch: feature/fix-login-button-text
6. Create pull request
7. Actions에서 테스트 통과 확인
8. Preview URL로 확인
9. 문제 없으면 Merge
```

### 시나리오 2: 새 기능 추가 (30분 ~ 1시간)

**예**: 알림 뱃지 추가

**과정**:
```
1. 브랜치 생성: feature/add-notification-badge
2. 여러 파일 수정 필요 → Working Copy 사용 권장
3. Working Copy에서 Repository 클론 (처음 한 번만)
4. 파일 수정:
   - lib/src/features/notification/presentation/widgets/notification_badge.dart (새 파일)
   - lib/src/features/home/presentation/home_screen.dart (기존 파일 수정)
5. 각 파일 저장 후 Stage
6. Commit: "feat: 알림 뱃지 위젯 추가"
7. Push
8. GitHub 앱에서 PR 생성
9. Actions 확인 → Preview 테스트
10. 수정 사항 있으면 반복
11. Merge
```

### 시나리오 3: 버그 수정 (10-20분)

**예**: Null safety 에러 수정

**과정**:
```
1. 이슈 확인 (GitHub 앱 → Issues)
2. 브랜치 생성: fix/null-safety-error-classroom-list
3. GitHub 앱으로 파일 수정:
   - lib/src/features/classroom/presentation/classroom_list_screen.dart
   - 134번 줄: classroom?.name → classroom.name ?? '-'
4. Commit: "fix: 교실 목록 null safety 에러 수정"
5. Push → PR 생성
6. Actions에서 테스트 통과 확인 (이전에 실패했던 테스트가 성공해야 함)
7. Merge
```

### 시나리오 4: 긴급 핫픽스 (Production)

**예**: Production에서 크리티컬 버그 발견

**과정**:
```
1. main 브랜치에서 hotfix 브랜치 생성:
   hotfix/critical-reservation-bug
2. 빠르게 수정 (GitHub 앱 또는 웹)
3. Commit: "hotfix: 예약 생성 시 서버 에러 수정"
4. PR 생성 (base: main)
5. 테스트 통과 즉시 Merge
6. Production 배포 자동 실행
7. 배포 완료 후 즉시 확인
8. develop 브랜치에도 머지 (cherrypick 또는 별도 PR)
```

### 시나리오 5: 여러 파일 동시 수정 (Working Copy 활용)

**예**: 새로운 기능 추가 (여러 파일 생성 및 수정)

**Working Copy 워크플로우**:
```
1. Repository 클론 (처음 한 번만):
   - Working Copy 앱 열기
   - "+" → "Clone repository"
   - GitHub 계정 연동
   - Uncany 저장소 선택

2. 브랜치 생성:
   - Repository 탭 → 브랜치 아이콘
   - "New branch" → feature/add-notification-feature
   - Base: develop

3. 파일 수정:
   - 파일 트리에서 수정할 파일 선택
   - 텍스트 에디터로 수정 (내장 or 외부)
   - 새 파일 생성: "+" → "New file"

4. 변경사항 확인:
   - "Status" 탭에서 수정된 파일 목록 확인
   - Diff 확인 가능

5. Commit:
   - 수정된 파일 체크
   - "Commit" 버튼
   - 커밋 메시지 입력
   - "Commit X files" 클릭

6. Push:
   - 상단 "Push" 버튼
   - GitHub 인증
   - Push 완료

7. PR 생성:
   - Working Copy에서 "Pull Request" 기능 or
   - GitHub 앱으로 전환하여 PR 생성
```

---

## 🔧 트러블슈팅

### 문제 1: "build_runner" 생성 파일이 없어 빌드 실패

**증상**:
```
Actions 로그에서:
Error: Could not find generated file for 'user_repository.dart'
```

**원인**:
- 코드 수정 후 `build_runner` 실행이 필요한데 자동 실행 안 됨

**해결책**:
```
GitHub Actions 워크플로우에서 자동 실행되어야 함.
test.yml 확인:

steps:
  - name: Run code generation
    run: flutter pub run build_runner build --delete-conflicting-outputs
```

**이미 워크플로우에 있다면**:
- Actions 로그 확인하여 실제로 실행되었는지 체크
- 실패 시 에러 메시지 확인

### 문제 2: Preview URL이 404 에러

**증상**:
```
PR 코멘트에 URL이 표시되었지만, 접속 시 404
```

**원인**:
- Firebase Hosting 배포 실패
- Preview 채널 만료

**해결책**:
```
1. Actions 로그에서 배포 워크플로우 확인
2. Firebase 배포 단계에서 에러 확인
3. Firebase 토큰이 유효한지 확인 (GitHub Secrets)
```

### 문제 3: Android 빌드 시 서명 에러

**증상**:
```
Actions 로그:
Execution failed for task ':app:validateSigningRelease'
```

**원인**:
- GitHub Secrets의 서명 키 설정 오류
- 키 비밀번호 불일치

**해결책**:
```
1. GitHub Secrets 확인:
   - ANDROID_KEYSTORE_BASE64
   - ANDROID_KEYSTORE_PASSWORD
   - ANDROID_KEY_ALIAS
   - ANDROID_KEY_PASSWORD

2. 로컬에서 키 재생성 (필요 시)
3. Base64 인코딩 확인
```

### 문제 4: 테스트가 계속 실패함

**증상**:
```
Actions 로그:
Test failed: expected true, but got false
```

**원인**:
- 코드 수정으로 기존 테스트 깨짐

**해결책**:
```
1. Actions 로그에서 실패한 테스트 파일 확인
2. 테스트 코드 수정 필요 or
3. 실제 버그 수정 필요

옵션 1: 로컬에서 확인 (가능한 경우)
옵션 2: 테스트 코드 수정 (GitHub 앱)
옵션 3: 코드 수정으로 테스트 통과시키기
```

### 문제 5: 코드 수정 후 앱에 반영 안 됨

**증상**:
```
코드를 수정하고 커밋했지만, Preview 앱에 변경사항이 없음
```

**원인**:
- 배포 워크플로우가 실행되지 않음
- 캐시 문제

**해결책**:
```
1. Actions 탭에서 배포 워크플로우 실행 여부 확인
2. 워크플로우 트리거 조건 확인:
   - PR 생성 시에만 실행되는지?
   - 푸시 시에도 실행되는지?
3. 브라우저 캐시 삭제 후 재접속
4. 시크릿 모드로 Preview URL 접속
```

### 문제 6: GitHub Actions 빌드 시간 초과

**증상**:
```
Actions 로그:
Error: The job running on runner has exceeded the maximum execution time of 360 minutes.
```

**원인**:
- 무한 루프 또는 hang
- 의존성 다운로드 실패

**해결책**:
```
1. 최근 커밋 확인 (무한 루프 코드?)
2. 워크플로우 단계별 시간 확인
3. Flutter 캐시 활성화 확인:
   uses: subosito/flutter-action@v2
   with:
     cache: true
```

---

## 💡 팁 & 트릭

### 1. 커밋 메시지 컨벤션

**일관된 커밋 메시지로 자동 문서화**:

```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅 (기능 변경 없음)
refactor: 리팩토링
test: 테스트 추가/수정
chore: 빌드 설정, 패키지 업데이트 등
```

**예**:
```
✅ 좋은 예:
feat: 알림 뱃지 위젯 추가
fix: 예약 목록 null safety 에러 수정
docs: MOBILE_WORKFLOW_GUIDE.md 작성

❌ 나쁜 예:
update
fix bug
수정
```

### 2. PR 템플릿 활용

**`.github/pull_request_template.md` 생성하면 자동으로 PR 본문에 표시**:

```markdown
## 변경사항
- [x] 기능 추가
- [ ] 버그 수정
- [ ] 리팩토링

## 설명
간단한 설명 작성...

## 스크린샷 (선택사항)
[스크린샷 첨부]

## 체크리스트
- [x] 테스트 통과
- [x] 코드 리뷰 준비 완료
- [ ] 문서 업데이트 (필요 시)
```

### 3. Draft PR 활용

**아직 완성되지 않았지만 피드백이 필요할 때**:

```
1. PR 생성 시 "Create draft pull request" 선택
2. 초록색 "Ready for review" 버튼 누르기 전까지 머지 불가
3. 중간 체크 및 Preview 테스트 가능
```

### 4. GitHub Actions 재실행

**일시적 네트워크 에러로 실패 시**:

```
1. Actions 탭 → 실패한 워크플로우 클릭
2. 우상단 "Re-run jobs" → "Re-run all jobs"
```

### 5. 코드 검색 활용

**모바일에서 특정 코드 찾기**:

```
1. Repository 페이지 상단 돋보기 아이콘
2. "Code" 탭 선택
3. 검색어 입력 (예: "ReservationRepository")
4. 파일 및 라인 번호 표시
```

### 6. Blame 기능으로 변경 이력 확인

**누가 언제 이 코드를 작성했는지 확인**:

```
GitHub 앱 (제한적):
- 파일 보기 → 커밋 이력 확인 가능

GitHub 웹 (추천):
- 파일 우상단 "Blame" 버튼
- 각 라인별로 커밋 정보 표시
```

### 7. Markdown 미리보기

**README나 문서 작성 시**:

```
GitHub 웹 에디터:
- "Preview" 탭으로 전환하여 렌더링 확인
- 모바일에서도 동일하게 작동
```

### 8. 여러 커밋을 한 번에 푸시

**Working Copy 사용 시**:

```
1. 여러 파일 수정
2. 각각 개별 커밋 (로컬)
3. 마지막에 한 번만 Push
4. GitHub Actions는 마지막 푸시에만 실행 (빌드 시간 절약)
```

### 9. 환경별 테스트 URL 북마크

**빠른 접근을 위해**:

```
브라우저 북마크 추가:
- Dev: https://uncany-dev.web.app
- Staging: https://uncany-staging.web.app
- Production: https://uncany.web.app
```

### 10. GitHub CLI 단축키 (모바일 브라우저)

**모바일 Safari/Chrome에서 GitHub 웹 단축키**:

```
- t: 파일 검색
- /: 전체 검색
- g c: 코드 탭으로 이동
- g i: 이슈 탭으로 이동
- g p: PR 탭으로 이동
```

---

## 🎓 학습 리소스

### 초보자용

- [GitHub 모바일 앱 가이드](https://docs.github.com/en/get-started/using-github/github-mobile)
- [Git 기초](https://git-scm.com/book/ko/v2)
- [Pull Request 가이드](https://docs.github.com/en/pull-requests)

### 중급자용

- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Working Copy 가이드](https://workingcopyapp.com/manual)

---

## 📞 도움이 필요할 때

### 1. GitHub Issues

```
문제 발생 시:
1. Repository → Issues 탭
2. "New issue" 버튼
3. 문제 상세 설명
```

### 2. GitHub Discussions (향후 활성화 예정)

```
질문/토론:
1. Repository → Discussions 탭
2. "New discussion"
```

### 3. Actions 로그 공유

```
빌드 실패 시:
1. Actions → 실패한 워크플로우
2. 로그 복사
3. Issue에 첨부
```

---

## ✅ 체크리스트

### 처음 설정할 때 (한 번만)

- [ ] GitHub 앱 설치 및 로그인
- [ ] Repository 접근 권한 확인
- [ ] 알림 설정 (Settings → Notifications)
- [ ] Working Copy 설치 및 Repository 클론 (선택사항)
- [ ] 배포 URL 북마크 추가

### 매 작업 시작 전

- [ ] 최신 develop 브랜치 확인
- [ ] 작업 브랜치 생성
- [ ] 관련 Issue 확인 (있다면)

### 코드 수정 후

- [ ] 커밋 메시지 작성 (컨벤션 준수)
- [ ] 푸시
- [ ] GitHub Actions 상태 확인
- [ ] 테스트 통과 확인

### PR 생성 전

- [ ] 변경사항 최종 확인
- [ ] 커밋 메시지 정리 (필요 시)
- [ ] PR 템플릿 작성

### PR 생성 후

- [ ] Preview 배포 확인
- [ ] Preview URL에서 기능 테스트
- [ ] 테스트 통과 확인
- [ ] 리뷰어 지정 (팀 프로젝트인 경우)

### 머지 후

- [ ] Staging/Production 배포 확인
- [ ] 실제 환경에서 최종 테스트
- [ ] 관련 Issue 닫기
- [ ] 작업 브랜치 삭제 (선택사항)

---

**다음 단계**: [CI/CD 계획서](./DEPLOYMENT_AND_CI_PLAN.md)로 돌아가기
