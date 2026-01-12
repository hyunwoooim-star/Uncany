# Uncany 테스트 가이드

## 개요

이 프로젝트는 **단위 테스트(Unit Test)**를 통해 코드 품질을 보장합니다.
테스트는 `mocktail` 라이브러리를 사용하여 외부 의존성(Supabase 등)을 Mock으로 대체합니다.

---

## 테스트 실행 방법

### 모든 테스트 실행

```bash
flutter test
```

### 특정 파일만 실행

```bash
flutter test test/core/utils/validators_test.dart
```

### 테스트 커버리지 확인

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

---

## 테스트 구조

```
test/
├── core/                          # 핵심 유틸리티 테스트
│   ├── extensions/
│   │   └── string_extensions_test.dart  # 문자열 확장 함수 테스트
│   └── utils/
│       └── validators_test.dart          # 검증 로직 테스트
│
└── features/                      # 기능별 테스트
    ├── auth/                      # 인증/사용자 관리
    │   └── data/
    │       └── repositories/
    │           ├── auth_repository_test.dart       # 인증 Repository
    │           └── user_repository_test.dart       # 사용자 관리 Repository
    │
    └── reservation/               # 예약 관리
        └── data/
            └── repositories/
                └── reservation_repository_test.dart  # 예약 Repository
```

---

## 작성된 테스트 목록

### ✅ Core 테스트

#### 1. Validators (validators_test.dart)
- 이메일 검증 (일반 이메일, 교육청 이메일)
- 비밀번호 검증 (길이, 영문+숫자, 강도)
- 한국 이름 검증
- 휴대폰 번호 검증
- 예약 시간/기간 검증

#### 2. String Extensions (string_extensions_test.dart)
- capitalize: 첫 글자 대문자 변환
- isBlank: 공백 확인
- getKoreanInitials: 한글 이니셜 추출
- maskEmail: 이메일 마스킹
- formatPhoneNumber: 휴대폰 번호 포맷팅
- ellipsize: 문자열 말줄임

### ✅ Features 테스트

#### 1. AuthRepository (auth_repository_test.dart)
- `getCurrentUser()`: 현재 로그인 사용자 조회
  - 세션 없음 → null 반환
  - 세션 있음 + DB 데이터 있음 → User 반환
  - 세션 있음 + DB 데이터 없음 → null 반환
- `signOut()`: 로그아웃
  - 성공 케이스
  - 실패 시 예외 발생
- `updateProfile()`: 프로필 업데이트
  - 세션 없으면 예외 발생
  - 성공 케이스
- `resetPassword()`: 비밀번호 재설정 이메일 발송
  - 성공 케이스
  - 잘못된 이메일로 예외 발생

#### 2. UserRepository (user_repository_test.dart)
- `getUsers()`: 사용자 목록 조회
  - 전체 조회
  - 인증 상태 필터링
- `getUser()`: 특정 사용자 조회
  - 존재하는 사용자
  - 존재하지 않는 사용자
- `approveUser()`: 사용자 승인
- `rejectUser()`: 사용자 반려
  - 반려 사유 필수 검증
- `updateUserRole()`: 권한 변경
- `deleteUser()`: Soft delete
- `restoreUser()`: 사용자 복원
- `getPendingCount()`: 대기 중인 사용자 수
  - 0명 케이스
  - N명 케이스

#### 3. ReservationRepository (reservation_repository_test.dart)
- `getMyReservations()`: 내 예약 목록 조회
  - 세션 없으면 예외 발생
  - 전체 조회
  - 날짜 필터링
- `getReservationsByClassroom()`: 교실별 예약 조회
  - 예약 있음
  - 예약 없음 (빈 목록)

---

## 테스트 작성 가이드

### 1. Mock 클래스 정의

`mocktail` 라이브러리를 사용하여 Supabase 클라이언트를 Mock으로 대체합니다.

```dart
import 'package:mocktail/mocktail.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
```

### 2. setUp() 메서드

각 테스트 실행 전 Mock 객체를 초기화합니다.

```dart
setUp(() {
  mockSupabase = MockSupabaseClient();
  mockAuth = MockGoTrueClient();

  when(() => mockSupabase.auth).thenReturn(mockAuth);
  when(() => mockSupabase.from(any())).thenReturn(mockPostgrest as dynamic);
});
```

### 3. 테스트 케이스 작성

**AAA 패턴**을 따릅니다:
- **Arrange**: 테스트 데이터 준비
- **Act**: 테스트 대상 메서드 실행
- **Assert**: 결과 검증

```dart
test('세션이 없으면 null 반환', () async {
  // Arrange
  when(() => mockAuth.currentSession).thenReturn(null);

  // Act
  final result = await authRepository.getCurrentUser();

  // Assert
  expect(result, isNull);
});
```

### 4. 예외 처리 테스트

```dart
test('로그아웃 실패 시 예외 발생', () async {
  // Arrange
  when(() => mockAuth.signOut()).thenThrow(
    AuthException('로그아웃 실패'),
  );

  // Act & Assert
  await expectLater(
    authRepository.signOut(),
    throwsException,
  );
});
```

---

## 테스트 작성 원칙

### 1. 한글 테스트 이름 사용
테스트 이름은 **한글**로 작성하여 가독성을 높입니다.

```dart
test('세션이 없으면 null 반환', () async {
  // ...
});
```

### 2. 단일 책임 원칙
하나의 테스트는 **하나의 기능**만 검증합니다.

❌ 나쁜 예:
```dart
test('사용자 조회 및 승인', () async {
  // 조회 + 승인을 한 번에 테스트 (X)
});
```

✅ 좋은 예:
```dart
test('사용자 조회 성공', () async { /* ... */ });
test('사용자 승인 성공', () async { /* ... */ });
```

### 3. Edge Case 테스트
정상 케이스뿐만 아니라 **예외 상황**도 테스트합니다:
- null 값
- 빈 목록
- 잘못된 입력
- 네트워크 오류

### 4. Mock 검증
메서드 호출 횟수를 검증합니다:

```dart
verify(() => mockAuth.signOut()).called(1);
```

---

## CI/CD 통합

### GitHub Actions에서 테스트 자동 실행

`.github/workflows/test.yml` 예시:

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Generate coverage
        run: flutter test --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

---

## 추가 작업 필요 (TODO)

### 1. Widget 테스트
- [ ] LoginScreen 위젯 테스트
- [ ] SignupScreen 위젯 테스트
- [ ] ReservationCalendar 위젯 테스트

### 2. Integration 테스트
- [ ] 회원가입 → 로그인 → 예약 생성 플로우
- [ ] 관리자 승인/반려 플로우

### 3. Repository 테스트 추가
- [ ] SchoolRepository 테스트
- [ ] ClassroomRepository 테스트
- [ ] ReferralCodeRepository 테스트

### 4. Service 테스트
- [ ] SchoolApiService 테스트 (NEIS API Mock)
- [ ] ImageCompressor 테스트
- [ ] AppLogger 테스트

---

## 참고 자료

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)

---

**작성일**: 2026-01-12
**문서 버전**: 1.0
