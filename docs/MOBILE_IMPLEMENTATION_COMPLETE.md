# 📱 모바일 배포 구현 완료 보고서

**작성일**: 2026-01-13
**상태**: 코드 100% 완성, 플랫폼 생성만 남음
**목표**: Android/iOS 스토어 제출 준비 완료

---

## ✅ 완료된 작업 (All Done!)

### 1. flutter_localizations 추가 ✅
**파일**: `pubspec.yaml`, `lib/src/app.dart`

**변경 사항**:
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

```dart
// lib/src/app.dart
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp.router(
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('ko', 'KR'),
  ],
  locale: const Locale('ko', 'KR'),
)
```

**효과**:
- 날짜 선택기, OK/Cancel 버튼 등이 한국어로 표시
- "Cancel" → "취소", "OK" → "확인"
- "Select Date" → "날짜 선택"

---

### 2. iOS Privacy Manifest 생성 ✅
**파일**: `docs/templates/ios/PrivacyInfo.xcprivacy`

**주요 내용**:
- NSPrivacyAccessedAPITypes 선언 (file_picker, image_picker 사용 이유)
- File Timestamp API (C617.1, 0A2A.1)
- User Defaults API (CA92.1)
- Disk Space API (E174.1)

**배치 방법**:
1. `flutter create --platforms ios .` 실행
2. `docs/templates/ios/PrivacyInfo.xcprivacy` → `ios/Runner/PrivacyInfo.xcprivacy` 복사
3. Xcode에서 Runner 타겟에 추가
4. Build Phases → Copy Bundle Resources 확인

**Apple 심사 통과 포인트**:
- ✅ file_picker: C617.1 (사용자가 명시적으로 선택한 파일)
- ✅ image_picker: 0A2A.1 (앱이 생성/관리하는 파일)
- ✅ 추적(Tracking): false (광고 없음)

---

### 3. AndroidManifest.xml 템플릿 생성 ✅
**파일**: `docs/templates/android/AndroidManifest.xml`

**주요 설정**:
```xml
<!-- Android 13+ 권한 (maxSdkVersion 분기) -->
<uses-permission
    android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Deep Link -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="https" android:host="uncany.app"/>
</intent-filter>

<!-- FileProvider (카메라 촬영 필수) -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths"/>
</provider>
```

**배치 방법**:
1. `flutter create --platforms android .` 실행
2. `docs/templates/android/AndroidManifest.xml` → `android/app/src/main/AndroidManifest.xml` 덮어쓰기
3. `uncany.app` 도메인을 실제 배포 도메인으로 변경

---

### 4. Info.plist 템플릿 생성 ✅
**파일**: `docs/templates/ios/Info.plist`

**주요 설정**:
```xml
<!-- 권한 설명 (Gemini 강조: 구체적인 이유!) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>프로필 사진 등록 및 재직증명서 첨부를 위해 사진 라이브러리에 접근합니다.</string>

<key>NSCameraUsageDescription</key>
<string>프로필 사진 촬영 및 문서 스캔을 위해 카메라 접근이 필요합니다.</string>

<!-- Deep Link -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>uncany</string>
        </array>
    </dict>
</array>

<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:uncany.app</string>
</array>
```

**배치 방법**:
1. `flutter create --platforms ios .` 실행
2. `ios/Runner/Info.plist` 열기
3. `<dict>` 태그 안에 위 내용 추가 (덮어쓰지 말고 병합!)

---

### 5. file_paths.xml 생성 ✅
**파일**: `docs/templates/android/file_paths.xml`

**내용**:
```xml
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <cache-path name="camera_images" path="camera/"/>
    <external-cache-path name="external_camera_images" path="camera/"/>
    <files-path name="internal_files" path="."/>
    <external-files-path name="external_files" path="."/>
</paths>
```

**배치 방법**:
1. `flutter create --platforms android .` 실행
2. `mkdir -p android/app/src/main/res/xml` (폴더 생성)
3. `docs/templates/android/file_paths.xml` → `android/app/src/main/res/xml/file_paths.xml` 복사

**용도**:
- image_picker에서 카메라 촬영 시 임시 파일 저장 경로
- 없으면 앱 크래시!

---

### 6. SafeArea 가이드 작성 ✅
**파일**: `docs/SAFEAREA_GUIDE.md`

**내용**:
- SafeArea가 필요한 이유 (노치 대응)
- 적용 체크리스트 (AppBar 없는 화면, Stack 사용 시)
- 프로젝트별 적용 대상 (login_screen, onboarding_screen 등)
- 코드 예시 및 주의사항
- 테스트 방법

**우선순위**:
- High: login_screen, onboarding_screen, reservation_screen
- Medium: profile_screen, find_id_screen
- Low: home_screen (AppBar 있으면 불필요)

---

## 📦 생성된 파일 목록

```
✅ lib/src/app.dart (수정)
✅ pubspec.yaml (수정)
✅ docs/templates/ios/PrivacyInfo.xcprivacy (신규)
✅ docs/templates/android/AndroidManifest.xml (신규)
✅ docs/templates/android/file_paths.xml (신규)
✅ docs/templates/ios/Info.plist (신규)
✅ docs/SAFEAREA_GUIDE.md (신규)
✅ docs/MOBILE_IMPLEMENTATION_COMPLETE.md (신규, 본 파일)
```

---

## 🚀 사용자가 해야 할 작업

### Phase 1: 플랫폼 추가 (5분)

#### 1.1. 백업 (필수!)
```bash
git add -A
git commit -m "feat: 모바일 배포 설정 파일 추가"
```

#### 1.2. 플랫폼 생성
```bash
flutter create --org com.uncany --platforms android,ios .
```

#### 1.3. pubspec.yaml 복구 (만약 덮어씌워졌다면)
```bash
git checkout -- pubspec.yaml
flutter pub get
```

---

### Phase 2: 템플릿 파일 복사 (10분)

#### 2.1. Android 설정
```bash
# AndroidManifest.xml 복사
cp docs/templates/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml

# file_paths.xml 복사
mkdir -p android/app/src/main/res/xml
cp docs/templates/android/file_paths.xml android/app/src/main/res/xml/file_paths.xml
```

#### 2.2. iOS 설정
```bash
# PrivacyInfo.xcprivacy 복사
cp docs/templates/ios/PrivacyInfo.xcprivacy ios/Runner/PrivacyInfo.xcprivacy

# Info.plist는 수동 병합 필요!
# docs/templates/ios/Info.plist 내용을 ios/Runner/Info.plist에 추가
```

**⚠️ Info.plist 주의사항**:
- 덮어쓰지 말고 기존 `<dict>` 태그 안에 추가!
- 중복 키가 없는지 확인

---

### Phase 3: 이미지 에셋 준비 (30분-1시간)

#### 3.1. 폴더 생성
```bash
mkdir -p assets/images
```

#### 3.2. 필요한 이미지 (3개)
| 파일명 | 크기 | 용도 |
|--------|------|------|
| `logo.png` | 1024x1024 | 앱 아이콘 |
| `logo_foreground.png` | 1024x1024 (투명 배경) | Android Adaptive Icon |
| `splash_logo.png` | 512x512 | 스플래시 화면 |

**임시 로고 생성 사이트**:
- AppIcon.co: https://appicon.co/
- Canva: https://www.canva.com/
- Remove.bg: https://www.remove.bg/ (배경 제거)

#### 3.3. 네이티브 에셋 생성
```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

---

### Phase 4: SHA-1 키 등록 (10분)

#### 4.1. Debug SHA-1 추출
```bash
# Windows
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android
```

#### 4.2. Supabase에 등록
1. Supabase Dashboard → Authentication → Providers → Google
2. Android Package Name: `com.uncany.uncany`
3. SHA-1 Certificate Fingerprint: 위에서 추출한 값 입력

---

### Phase 5: Edge Function 배포 (5분)

```bash
# 회원 탈퇴 함수 배포
supabase functions deploy delete-account

# NEIS API 함수 재배포 (JWT 검증 포함)
supabase functions deploy neis-api
```

---

### Phase 6: 빌드 테스트 (30분)

#### 6.1. Android
```bash
flutter run -d android
```

#### 6.2. iOS
```bash
flutter run -d iphone
```

#### 6.3. Web (기존 기능 확인)
```bash
flutter run -d chrome
```

---

## 📋 최종 체크리스트

### Critical (필수)
- [ ] `flutter create --platforms android,ios .` 실행
- [ ] AndroidManifest.xml 복사 및 도메인 수정
- [ ] file_paths.xml 복사
- [ ] PrivacyInfo.xcprivacy 복사 및 Xcode 추가
- [ ] Info.plist 병합
- [ ] 이미지 에셋 3개 준비
- [ ] `flutter pub run flutter_launcher_icons` 실행
- [ ] `flutter pub run flutter_native_splash:create` 실행
- [ ] SHA-1 키 Supabase 등록
- [ ] `supabase functions deploy delete-account` 실행
- [ ] Android/iOS 빌드 성공 확인

### High (강력 권장)
- [ ] SafeArea 적용 (login_screen, onboarding_screen)
- [ ] 실제 기기에서 테스트 (iPhone X 이상, Android 노치 기기)
- [ ] 권한 요청 동작 확인 (갤러리, 카메라)
- [ ] Deep Link 테스트 (비밀번호 재설정 이메일)
- [ ] 회원 탈퇴 기능 테스트

### Medium (선택)
- [ ] cached_network_image 추가 (성능 개선)
- [ ] Release 키스토어 생성
- [ ] Sentry/Crashlytics 에러 모니터링
- [ ] 스토어 스크린샷 준비

---

## 🎯 예상 작업 시간

| 단계 | 시간 | 난이도 |
|------|------|--------|
| Phase 1: 플랫폼 추가 | 5분 | 쉬움 |
| Phase 2: 템플릿 복사 | 10분 | 쉬움 |
| Phase 3: 이미지 에셋 | 30분-1시간 | 보통 |
| Phase 4: SHA-1 등록 | 10분 | 쉬움 |
| Phase 5: Edge Function | 5분 | 쉬움 |
| Phase 6: 빌드 테스트 | 30분 | 보통 |
| **총 예상 시간** | **1.5-2.5시간** | - |

---

## 💎 Gemini의 최종 메시지

> "모든 코드가 완성되었습니다. 이제 남은 건 실행뿐입니다."
>
> "Phase 1의 `flutter create` 명령어를 실행할 때, 기존 코드를 보호하면서 플랫폼 폴더만 생성하는 것이 가장 중요합니다. 백업만 확실하다면 나머지는 계획대로 차근차근 진행하시면 됩니다."
>
> "특히 iOS Privacy Manifest는 2024년 5월부터 필수 요구사항입니다. file_picker/image_picker를 사용하는 모든 앱은 PrivacyInfo.xcprivacy 파일이 없으면 심사 반려됩니다."
>
> "SafeArea는 앱 퀄리티를 결정짓는 디테일입니다. 실제 기기에서 꼭 테스트하세요!"
>
> "성공적인 앱 배포를 응원합니다! 🚀"

---

## 📚 참고 문서

- **ADD_MOBILE_PLATFORMS.md**: 플랫폼 추가 상세 가이드
- **MOBILE_DEPLOYMENT_GUIDE.md**: 5가지 필수 항목 완벽 가이드
- **SAFEAREA_GUIDE.md**: SafeArea 적용 가이드
- **CRITICAL_FIXES_COMPLETED.md**: 보안 수정 보고서

---

**작성자**: Claude Sonnet 4.5
**최종 업데이트**: 2026-01-13
**상태**: ✅ 모든 코드 작성 완료, 사용자 실행 대기 중
