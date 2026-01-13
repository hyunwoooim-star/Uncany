# 📱 SafeArea 적용 가이드

**목적**: 모바일 노치(Notch) 및 시스템 UI 대응
**대상**: iPhone X 이상, Android 노치 디바이스
**작성일**: 2026-01-13

---

## 🎯 SafeArea가 필요한 이유

### 문제 상황
- **iPhone X 이상**: 상단 노치, 하단 홈 인디케이터
- **Android 노치**: 삼성/샤오미 등 노치 디바이스
- **UI 잘림**: 중요한 버튼/텍스트가 노치에 가려짐

### SafeArea 역할
```dart
SafeArea(
  child: YourWidget(),
)
```
- 시스템 UI를 피해 안전 영역에만 콘텐츠 표시
- 자동으로 패딩 추가 (상단/하단/좌우)

---

## 📋 적용 체크리스트

### ✅ 필수 적용 화면

#### 1. Scaffold를 사용하는 모든 화면
```dart
// ❌ Before
Scaffold(
  body: Column(
    children: [...],
  ),
)

// ✅ After
Scaffold(
  body: SafeArea(
    child: Column(
      children: [...],
    ),
  ),
)
```

#### 2. AppBar가 없는 화면
```dart
// AppBar가 있으면 SafeArea 불필요 (AppBar가 자동 처리)
Scaffold(
  appBar: AppBar(title: Text('제목')),
  body: Content(), // SafeArea 불필요
)

// AppBar가 없으면 SafeArea 필수!
Scaffold(
  body: SafeArea(
    child: Content(),
  ),
)
```

#### 3. Stack으로 전체 화면을 덮는 경우
```dart
Stack(
  children: [
    // 배경 이미지 (전체 화면)
    Positioned.fill(
      child: Image.asset('background.png'),
    ),

    // 콘텐츠 (SafeArea 필수!)
    SafeArea(
      child: Column(
        children: [
          Text('노치를 피해 표시됨'),
        ],
      ),
    ),
  ],
)
```

---

## 🔍 프로젝트 내 적용 대상

### 현재 프로젝트 구조 분석

#### 1. 로그인/회원가입 화면
**파일**: `lib/src/features/auth/presentation/screens/login_screen.dart`

```dart
// ✅ 확인 필요
Scaffold(
  body: SafeArea( // ← 있는지 확인!
    child: Center(
      child: LoginForm(),
    ),
  ),
)
```

#### 2. 온보딩 화면
**파일**: `lib/src/features/onboarding/presentation/screens/onboarding_screen.dart`

```dart
// ✅ 전체 화면 사용 시 SafeArea 필수
Scaffold(
  body: SafeArea(
    child: PageView(
      children: onboardingPages,
    ),
  ),
)
```

#### 3. 메인 화면 (BottomNavigationBar)
**파일**: `lib/src/features/home/presentation/screens/home_screen.dart`

```dart
// ⚠️ BottomNavigationBar는 자동으로 SafeArea 적용됨
Scaffold(
  appBar: AppBar(...), // 자동 SafeArea
  body: Content(), // AppBar 있으면 불필요
  bottomNavigationBar: BottomNavigationBar(...), // 자동 SafeArea
)

// 단, body에 Stack을 사용하면 SafeArea 필요!
Scaffold(
  body: SafeArea(
    child: Stack(
      children: [...],
    ),
  ),
  bottomNavigationBar: BottomNavigationBar(...),
)
```

#### 4. 예약 화면
**파일**: `lib/src/features/reservation/presentation/screens/reservation_screen.dart`

```dart
// ✅ AppBar 없으면 SafeArea 필수
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        DatePicker(),
        PeriodGrid(),
        SubmitButton(),
      ],
    ),
  ),
)
```

#### 5. 프로필 화면
**파일**: `lib/src/features/profile/presentation/screens/profile_screen.dart`

```dart
// ✅ 상단에 커스텀 헤더가 있다면 SafeArea 필수
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        ProfileHeader(),
        ProfileOptions(),
      ],
    ),
  ),
)
```

---

## 🛠️ 고급 사용법

### 1. 선택적 SafeArea (일부만 적용)
```dart
SafeArea(
  top: true,      // 상단 노치 피하기
  bottom: false,  // 하단 홈 인디케이터 무시 (배경 이미지 시)
  left: true,
  right: true,
  child: YourWidget(),
)
```

### 2. 최소 패딩 설정
```dart
SafeArea(
  minimum: EdgeInsets.all(16.0), // 최소 16px 패딩 보장
  child: YourWidget(),
)
```

### 3. MediaQuery로 SafeArea 크기 확인
```dart
final padding = MediaQuery.of(context).padding;
print('상단 노치 크기: ${padding.top}');
print('하단 홈 인디케이터: ${padding.bottom}');

// 조건부 SafeArea
if (padding.top > 20) {
  // 노치가 있는 기기
  return SafeArea(child: Content());
} else {
  // 노치가 없는 기기
  return Content();
}
```

---

## 🧪 테스트 방법

### 1. iOS 시뮬레이터
```bash
# iPhone 14 Pro (노치 있음)
flutter run -d "iPhone 14 Pro"

# iPhone SE (노치 없음)
flutter run -d "iPhone SE"
```

### 2. Android 에뮬레이터
```bash
# Pixel 6 (노치 있음)
flutter emulators --launch Pixel_6_API_33

flutter run -d emulator-5554
```

### 3. 실제 기기 테스트 (필수!)
- iPhone X 이상에서 테스트
- 삼성 Galaxy S10+ (노치 있음)
- 샤오미 Redmi Note 시리즈

### 4. 확인 항목
- [ ] 상단 텍스트가 노치에 가려지지 않는가?
- [ ] 하단 버튼이 홈 인디케이터에 가려지지 않는가?
- [ ] 좌우 콘텐츠가 화면 밖으로 나가지 않는가?
- [ ] 배경 이미지는 전체 화면을 덮는가? (SafeArea 제외)

---

## 📝 코드 예시

### 예시 1: 로그인 화면 (AppBar 없음)
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('로그인', style: TextStyle(fontSize: 32)),
              SizedBox(height: 32),
              TextField(decoration: InputDecoration(labelText: '이메일')),
              SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: '비밀번호')),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 예시 2: 전체 화면 배경 이미지 + 콘텐츠
```dart
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경: SafeArea 없이 전체 화면
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_logo.png',
              fit: BoxFit.cover,
            ),
          ),

          // 콘텐츠: SafeArea로 노치 피하기
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Uncany', style: TextStyle(fontSize: 48)),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('시작하기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 예시 3: AppBar 있는 화면 (SafeArea 불필요)
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈'),
      ),
      body: ListView( // SafeArea 불필요 (AppBar가 처리)
        children: [
          ListTile(title: Text('항목 1')),
          ListTile(title: Text('항목 2')),
        ],
      ),
    );
  }
}
```

---

## 🚨 주의사항

### 1. 중복 SafeArea 금지
```dart
// ❌ Bad: 중복 SafeArea
Scaffold(
  body: SafeArea(
    child: SafeArea( // 중복!
      child: Content(),
    ),
  ),
)

// ✅ Good: 한 번만
Scaffold(
  body: SafeArea(
    child: Content(),
  ),
)
```

### 2. AppBar와 SafeArea 충돌
```dart
// ❌ Bad: AppBar가 있는데 SafeArea 사용
Scaffold(
  appBar: AppBar(title: Text('제목')),
  body: SafeArea( // 불필요!
    child: Content(),
  ),
)

// ✅ Good: AppBar만 사용
Scaffold(
  appBar: AppBar(title: Text('제목')),
  body: Content(),
)
```

### 3. 배경 이미지 잘림
```dart
// ❌ Bad: 배경 이미지에 SafeArea 적용
SafeArea(
  child: Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('background.png'),
        fit: BoxFit.cover, // 노치 부분이 잘림!
      ),
    ),
  ),
)

// ✅ Good: Stack으로 분리
Stack(
  children: [
    Positioned.fill( // 배경: SafeArea 없이
      child: Image.asset('background.png', fit: BoxFit.cover),
    ),
    SafeArea( // 콘텐츠: SafeArea 적용
      child: Content(),
    ),
  ],
)
```

---

## 📊 프로젝트 적용 우선순위

### High Priority (필수)
- [ ] `login_screen.dart` - 로그인 화면
- [ ] `onboarding_screen.dart` - 온보딩 화면
- [ ] `reservation_screen.dart` - 예약 화면

### Medium Priority (권장)
- [ ] `profile_screen.dart` - 프로필 화면
- [ ] `find_id_screen.dart` - 아이디 찾기 화면
- [ ] `reset_password_screen.dart` - 비밀번호 재설정 화면

### Low Priority (선택)
- [ ] `home_screen.dart` - 홈 화면 (AppBar 있으면 불필요)
- [ ] `settings_screen.dart` - 설정 화면 (AppBar 있으면 불필요)

---

## 🔍 자동 검사 스크립트

프로젝트 내 SafeArea가 필요한 위치를 찾는 Grep 명령어:

```bash
# AppBar 없는 Scaffold 찾기
grep -r "Scaffold" lib/ --include="*.dart" -A 5 | grep -v "appBar"

# SafeArea가 없는 Scaffold 찾기
grep -r "Scaffold" lib/ --include="*.dart" -A 10 | grep -v "SafeArea"
```

---

## 📚 참고 자료

- Flutter SafeArea: https://api.flutter.dev/flutter/widgets/SafeArea-class.html
- MediaQuery Padding: https://api.flutter.dev/flutter/widgets/MediaQueryData/padding.html
- iOS Safe Area: https://developer.apple.com/design/human-interface-guidelines/layout

---

**최종 업데이트**: 2026-01-13
**작성자**: Claude Sonnet 4.5
**Gemini 피드백**: "SafeArea는 앱 퀄리티를 결정짓는 디테일입니다. 꼭 테스트하세요!"
