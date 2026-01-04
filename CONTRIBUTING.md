# 기여 가이드

> Uncany 프로젝트에 기여해주셔서 감사합니다! 🎉

---

## 📋 목차
1. [행동 강령](#행동-강령)
2. [시작하기](#시작하기)
3. [개발 워크플로우](#개발-워크플로우)
4. [코드 스타일](#코드-스타일)
5. [커밋 규칙](#커밋-규칙)
6. [Pull Request 가이드](#pull-request-가이드)

---

## 🤝 행동 강령

우리는 모든 기여자를 존중합니다. 다음 원칙을 지켜주세요:

- ✅ 친절하고 포용적인 태도
- ✅ 건설적인 피드백
- ✅ 다른 관점 존중
- ❌ 차별적이거나 공격적인 언어

---

## 🚀 시작하기

### 1. 저장소 Fork & Clone

```bash
# Fork 후 클론
git clone https://github.com/YOUR_USERNAME/Uncany.git
cd Uncany

# Upstream 추가
git remote add upstream https://github.com/hyunwoooim-star/Uncany.git
```

### 2. 개발 환경 설정

```bash
# Flutter 설치 확인
flutter --version

# 의존성 설치
flutter pub get

# 코드 생성 (Freezed, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# 환경 변수 설정
cp .env.example .env
# .env 파일에 Supabase credentials 입력
```

### 3. 실행 확인

```bash
# Web
flutter run -d chrome

# iOS (macOS only)
flutter run -d ios

# Android
flutter run -d android
```

---

## 🔄 개발 워크플로우

### 1. 브랜치 생성

```bash
# develop 브랜치에서 시작
git checkout develop
git pull upstream develop

# 새 기능 브랜치 생성
git checkout -b feature/my-awesome-feature

# 또는 버그 수정
git checkout -b fix/bug-description
```

### 2. 작업 진행

```bash
# 코드 작성
# ...

# 린터 확인
flutter analyze

# 포맷 적용
flutter format .

# 테스트 실행
flutter test
```

### 3. 커밋

```bash
git add .
git commit -m "feat(auth): 재직증명서 업로드 기능 추가"
```

### 4. 푸시 & PR 생성

```bash
git push origin feature/my-awesome-feature
```

GitHub에서 Pull Request 생성!

---

## 🎨 코드 스타일

### Dart 규칙

- **린터**: `analysis_options.yaml` 준수
- **포맷**: `flutter format` 사용 (저장 시 자동 적용)
- **import 순서**:
  1. Dart SDK (`dart:`)
  2. Flutter SDK (`package:flutter/`)
  3. 외부 패키지 (`package:`)
  4. 상대 경로 (`../`)

```dart
// Good
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/user.dart';
```

### 파일 명명

- **Dart 파일**: `snake_case.dart`
- **클래스**: `PascalCase`
- **함수/변수**: `camelCase`
- **상수**: `kConstantName` 또는 `UPPER_SNAKE_CASE`

### 위젯 스타일

```dart
// Good - const 사용
const Text('Hello'),

// Good - trailing comma
ListView(
  children: [
    ListTile(),
    ListTile(),
  ], // <- 마지막 쉼표
),

// Bad - 불필요한 Container
Container(
  child: Text('Hello'),
),

// Good - 직접 사용
Text('Hello'),
```

---

## 📝 커밋 규칙

### Conventional Commits 형식

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 타입 (Type)

| 타입 | 설명 | 예시 |
|------|------|------|
| `feat` | 새 기능 | `feat(auth): 추천인 코드 입력 추가` |
| `fix` | 버그 수정 | `fix(reservation): 중복 예약 방지 로직 수정` |
| `docs` | 문서만 변경 | `docs(readme): 설치 가이드 업데이트` |
| `refactor` | 리팩토링 | `refactor(auth): Provider 구조 개선` |
| `test` | 테스트 추가 | `test(reservation): Unit test 추가` |
| `chore` | 빌드/설정 | `chore(deps): Riverpod 2.5로 업데이트` |
| `style` | 코드 포맷 | `style: Dart format 적용` |

### Scope (범위)

- `auth` - 인증
- `reservation` - 예약
- `classroom` - 교실 관리
- `audit` - 감사 로그
- `ui` - UI/UX
- `setup` - 프로젝트 설정

### 예시

```bash
# Good
git commit -m "feat(auth): 재직증명서 업로드 UI 구현"

# Good (with body)
git commit -m "fix(reservation): 시간 중복 검증 오류 수정

활성 예약만 검증하도록 쿼리 수정
deleted_at IS NULL 조건 추가

Closes #42"

# Bad
git commit -m "update"
git commit -m "fix bug"
```

---

## 🔀 Pull Request 가이드

### PR 생성 전 체크리스트

- [ ] `flutter analyze` 경고 없음
- [ ] `flutter format` 적용
- [ ] `flutter test` 통과
- [ ] 관련 문서 업데이트 (README, API 문서 등)
- [ ] 스크린샷 첨부 (UI 변경 시)

### PR 템플릿

템플릿은 자동으로 적용됩니다 (`.github/PULL_REQUEST_TEMPLATE.md`)

### PR 제목

```
feat(auth): 재직증명서 업로드 기능 추가
fix(reservation): 중복 예약 검증 오류 수정
docs(api): Classroom API 문서 업데이트
```

### 리뷰 프로세스

1. PR 생성 시 자동 테스트 실행 (GitHub Actions)
2. 코드 리뷰 진행
3. 변경 요청 반영
4. 승인 후 `develop` 브랜치로 머지

---

## 🧪 테스트 작성

### 테스트 위치

```
test/
├── unit/           # 비즈니스 로직
├── widget/         # UI 컴포넌트
└── integration/    # E2E 테스트
```

### Unit Test 예시

```dart
// test/unit/auth/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    test('should validate email domain', () {
      final result = AuthService.isValidEducationEmail('user@sen.go.kr');
      expect(result, true);
    });

    test('should reject invalid domain', () {
      final result = AuthService.isValidEducationEmail('user@gmail.com');
      expect(result, false);
    });
  });
}
```

### Widget Test 예시

```dart
// test/widget/auth/login_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should show login button', (tester) async {
    await tester.pumpWidget(const LoginScreen());

    expect(find.text('로그인'), findsOneWidget);
  });
}
```

---

## 🐛 버그 리포트

버그를 발견하셨나요?

1. [Issues](https://github.com/hyunwoooim-star/Uncany/issues) 에서 중복 확인
2. 새 Issue 생성 (템플릿 사용)
3. 자세한 재현 방법 작성

---

## 💡 기능 제안

새로운 아이디어가 있으신가요?

1. [Issues](https://github.com/hyunwoooim-star/Uncany/issues) → New Issue
2. "기능 요청" 템플릿 선택
3. 제안 내용 상세히 작성

---

## 📞 도움이 필요하신가요?

- 📧 Issue로 질문하기
- 💬 PR 코멘트로 질문하기

---

## 📄 라이선스

기여하신 코드는 프로젝트의 MIT 라이선스를 따릅니다.

---

**감사합니다! 🙏**
