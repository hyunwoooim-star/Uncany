# 📱 모바일 플랫폼 추가 가이드

**현재 상태**: Flutter Web 전용 프로젝트
**목표**: Android 및 iOS 플랫폼 추가

---

## ⚠️ 중요: 현재 프로젝트는 Web 전용입니다

`flutter create` 시 `--platforms web`으로 생성되어 `android/`와 `ios/` 폴더가 없습니다.
모바일 배포를 위해서는 플랫폼을 추가해야 합니다.

---

## 1. 🚀 모바일 플랫폼 추가

### 1.1. Android 추가

```bash
flutter create --platforms android .
```

실행 후 생성되는 파일:
```
android/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   ├── kotlin/com/uncany/app/MainActivity.kt
│   │   └── res/
│   └── build.gradle
├── gradle/
├── build.gradle
└── settings.gradle
```

### 1.2. iOS 추가

```bash
flutter create --platforms ios .
```

실행 후 생성되는 파일:
```
ios/
├── Runner/
│   ├── Info.plist
│   ├── AppDelegate.swift
│   └── Assets.xcassets/
├── Runner.xcodeproj/
└── Runner.xcworkspace/
```

### 1.3. 두 플랫폼 동시 추가

```bash
flutter create --platforms android,ios .
```

---

## 2. ⚠️ 플랫폼 추가 시 주의사항

### 2.1. 기존 Web 설정 유지

플랫폼 추가 시 `pubspec.yaml`과 `lib/` 폴더는 **덮어쓰지 않습니다**.
하지만 다음 파일들을 확인해야 합니다:

```bash
# 플랫폼 추가 전 백업
git stash  # 또는 커밋

# 플랫폼 추가
flutter create --platforms android,ios .

# 변경사항 확인
git status
git diff

# 필요 없는 변경사항은 되돌리기
git checkout -- pubspec.yaml  # 기존 의존성 유지
```

### 2.2. 패키지명 설정

플랫폼 추가 시 패키지명을 지정할 수 있습니다:

```bash
flutter create --org com.uncany --platforms android,ios .
```

**결과**:
- Android: `com.uncany.uncany`
- iOS: `com.uncany.uncany`

**권장**: `com.uncany.app`처럼 간결하게:

```bash
flutter create --org com.uncany --project-name uncany --platforms android,ios .
```

---

## 3. 📝 플랫폼 추가 후 필수 작업

### 3.1. AndroidManifest.xml 수정

**파일**: `android/app/src/main/AndroidManifest.xml`

[MOBILE_DEPLOYMENT_GUIDE.md의 내용 참조](#../MOBILE_DEPLOYMENT_GUIDE.md)

주요 추가 사항:
- 권한 설정 (READ_MEDIA_IMAGES, CAMERA 등)
- Deep Link Intent Filter
- File Provider

### 3.2. Info.plist 수정

**파일**: `ios/Runner/Info.plist`

[MOBILE_DEPLOYMENT_GUIDE.md의 내용 참조](#../MOBILE_DEPLOYMENT_GUIDE.md)

주요 추가 사항:
- NSPhotoLibraryUsageDescription
- NSCameraUsageDescription
- CFBundleURLTypes (Deep Link)

### 3.3. pubspec.yaml 의존성 확인

Web 전용 패키지가 있다면 조건부 import로 변경:

```yaml
dependencies:
  # Web과 모바일 모두 지원
  supabase_flutter: ^2.0.0
  riverpod: ^2.5.0

  # 모바일 전용 (Web에서는 무시됨)
  permission_handler: ^11.3.0
  device_info_plus: ^10.1.0
  sign_in_with_apple: ^5.0.0
  uni_links: ^0.5.1
```

---

## 4. 🔧 플랫폼별 빌드 테스트

### 4.1. Android 빌드 테스트

```bash
# Debug 빌드
flutter run -d android

# Release 빌드 (서명 설정 후)
flutter build apk --release
flutter build appbundle --release
```

### 4.2. iOS 빌드 테스트

```bash
# Debug 빌드 (시뮬레이터)
flutter run -d iphone

# Release 빌드
flutter build ios --release
```

### 4.3. Web 빌드 확인 (기존 기능 유지)

```bash
flutter run -d chrome
flutter build web --release
```

---

## 5. ⚡️ 플랫폼 추가 스크립트

자동화 스크립트를 만들어 실수를 방지할 수 있습니다.

**파일 생성**: `scripts/add_mobile_platforms.sh`

```bash
#!/bin/bash

echo "🚀 모바일 플랫폼 추가 시작..."

# 1. 현재 변경사항 백업
echo "📦 현재 상태 백업 중..."
git stash push -m "플랫폼 추가 전 백업"

# 2. 플랫폼 추가
echo "📱 Android 및 iOS 플랫폼 추가 중..."
flutter create --org com.uncany --platforms android,ios .

# 3. pubspec.yaml 복원 (기존 의존성 유지)
echo "📝 pubspec.yaml 복원 중..."
git checkout -- pubspec.yaml

# 4. 불필요한 파일 제거
echo "🗑️ 불필요한 파일 제거 중..."
rm -f test/widget_test.dart  # 기본 테스트 파일
rm -rf integration_test/  # 기본 통합 테스트

# 5. Android 설정 파일 복사
echo "⚙️ Android 설정 적용 중..."
# TODO: AndroidManifest.xml 템플릿 복사

# 6. iOS 설정 파일 복사
echo "⚙️ iOS 설정 적용 중..."
# TODO: Info.plist 템플릿 복사

# 7. 의존성 설치
echo "📦 의존성 설치 중..."
flutter pub get

# 8. 완료
echo "✅ 플랫폼 추가 완료!"
echo ""
echo "다음 단계:"
echo "  1. android/app/src/main/AndroidManifest.xml 수정"
echo "  2. ios/Runner/Info.plist 수정"
echo "  3. flutter run -d android 테스트"
echo "  4. flutter run -d iphone 테스트"
```

**실행**:
```bash
chmod +x scripts/add_mobile_platforms.sh
./scripts/add_mobile_platforms.sh
```

---

## 6. 🐛 문제 해결

### 문제 1: 플랫폼 추가 후 빌드 오류

**증상**: `flutter run` 시 "No pubspec.yaml file found" 에러

**해결**:
```bash
flutter clean
flutter pub get
```

### 문제 2: Android 라이센스 동의 필요

**증상**: "Android SDK licenses not accepted"

**해결**:
```bash
flutter doctor --android-licenses
```

### 문제 3: iOS CocoaPods 오류

**증상**: "CocoaPods not installed"

**해결**:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### 문제 4: Web 빌드가 깨짐

**증상**: 플랫폼 추가 후 Web이 작동 안 함

**해결**:
```bash
# pubspec.yaml 복원
git checkout -- pubspec.yaml

# Web 의존성 재설치
flutter pub get

# Web 빌드 테스트
flutter run -d chrome
```

---

## 7. 📋 체크리스트

플랫폼 추가 후 확인 사항:

- [ ] `android/` 폴더 생성됨
- [ ] `ios/` 폴더 생성됨
- [ ] `pubspec.yaml` 기존 의존성 유지됨
- [ ] `flutter doctor` 오류 없음
- [ ] Android 빌드 성공 (`flutter run -d android`)
- [ ] iOS 빌드 성공 (`flutter run -d iphone`)
- [ ] Web 빌드 여전히 작동 (`flutter run -d chrome`)
- [ ] AndroidManifest.xml 수정 완료
- [ ] Info.plist 수정 완료
- [ ] Deep Link 테스트 완료
- [ ] 권한 요청 테스트 완료

---

## 8. 🚀 다음 단계

플랫폼 추가가 완료되면:

1. **[MOBILE_DEPLOYMENT_GUIDE.md](./MOBILE_DEPLOYMENT_GUIDE.md)** 참조하여 상세 설정
2. **아이콘 및 스플래시 화면** 생성
3. **소셜 로그인** 설정 (SHA-1, Apple 로그인)
4. **회원 탈퇴** 기능 구현
5. **스토어 제출**

---

**작성자**: Claude Sonnet 4.5
**최종 업데이트**: 2026-01-13
