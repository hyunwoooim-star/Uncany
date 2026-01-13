# 📱 Uncany 모바일 배포 완벽 가이드

**작성일**: 2026-01-13
**대상**: Android (Play Store) + iOS (App Store)
**상태**: 보안 패치 완료, 모바일 설정 진행 중

---

## 📋 목차

1. [권한 설정 (Android 13+ 대응)](#1-권한-설정)
2. [소셜 로그인 및 SHA-1 설정](#2-소셜-로그인-설정)
3. [네이티브 에셋 생성](#3-네이티브-에셋-생성)
4. [애플 로그인 구현](#4-애플-로그인-구현)
5. [회원 탈퇴 기능](#5-회원-탈퇴-기능)
6. [배포 체크리스트](#6-배포-체크리스트)

---

## 1. 📱 권한 설정 (Android 13+ 대응)

### 1.1. pubspec.yaml 의존성 추가

```yaml
dependencies:
  flutter:
    sdk: flutter
  # 기존 의존성들...
  permission_handler: ^11.3.0  # 권한 관리

dev_dependencies:
  # 기존 dev 의존성들...
```

### 1.2. Android 설정

**파일**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 인터넷 필수 -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- 📸 이미지 선택 권한 (Android 13+ 대응) -->
    <!-- Android 12 이하 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="29"/>

    <!-- Android 13 이상 (SDK 33+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

    <!-- 📷 카메라 권한 (필요 시) -->
    <uses-permission android:name="android.permission.CAMERA"/>

    <application
        android:label="Uncany"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:enableOnBackInvokedCallback="true">

        <!-- Deep Link 설정 (비밀번호 재설정용) -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- 기본 런처 -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- 🔗 Deep Link (https://uncany.app) -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>

                <!-- 실제 도메인으로 변경 필요 -->
                <data
                    android:scheme="https"
                    android:host="uncany.app"/>
            </intent-filter>

            <!-- Custom Scheme (앱 전용) -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>

                <data android:scheme="uncany"/>
            </intent-filter>
        </activity>

        <!-- File Provider (이미지 공유용) -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths"/>
        </provider>
    </application>
</manifest>
```

**파일 생성**: `android/app/src/main/res/xml/file_paths.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="."/>
    <cache-path name="cache" path="."/>
</paths>
```

### 1.3. iOS 설정

**파일**: `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 기존 설정들... -->

    <!-- 📸 사진 라이브러리 접근 -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>프로필 사진 및 문서 이미지를 업로드하기 위해 사진 라이브러리 접근이 필요합니다.</string>

    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>사진을 저장하기 위해 접근 권한이 필요합니다.</string>

    <!-- 📷 카메라 접근 -->
    <key>NSCameraUsageDescription</key>
    <string>프로필 사진 촬영을 위해 카메라 접근이 필요합니다.</string>

    <!-- 🔗 Deep Link 설정 -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.uncany.app</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>uncany</string>
            </array>
        </dict>
    </array>

    <!-- Universal Links (https://uncany.app) -->
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:uncany.app</string>
    </array>
</dict>
</plist>
```

### 1.4. 권한 요청 헬퍼 클래스

**파일 생성**: `lib/src/core/services/permission_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// 권한 관리 서비스
class PermissionService {
  PermissionService._();

  /// 사진 라이브러리 권한 요청 (Android 13+ 대응)
  static Future<bool> requestPhotoLibraryPermission() async {
    if (kIsWeb) return true; // Web은 권한 불필요

    // Android 13 이상
    if (defaultTargetPlatform == TargetPlatform.android) {
      final deviceInfo = await _getAndroidVersion();
      if (deviceInfo >= 33) {
        // Android 13+: READ_MEDIA_IMAGES
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // Android 12 이하: READ_EXTERNAL_STORAGE
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }

    // iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    return false;
  }

  /// 카메라 권한 요청
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 권한 거부 시 설정 화면으로 이동
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Android 버전 확인 (내부 헬퍼)
  static Future<int> _getAndroidVersion() async {
    // device_info_plus 패키지 필요
    // final deviceInfo = await DeviceInfoPlugin().androidInfo;
    // return deviceInfo.version.sdkInt;

    // 임시로 33 반환 (실제로는 device_info_plus 사용)
    return 33;
  }
}
```

**pubspec.yaml에 추가**:
```yaml
dependencies:
  device_info_plus: ^10.1.0  # Android 버전 확인용
```

### 1.5. 사용 예시 (파일 선택 전)

**파일 수정**: `lib/src/features/profile/presentation/profile_edit_screen.dart`

```dart
import '../../core/services/permission_service.dart';

// 프로필 이미지 선택 시
Future<void> _pickImage() async {
  // 🔑 권한 요청
  final hasPermission = await PermissionService.requestPhotoLibraryPermission();

  if (!hasPermission) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사진 라이브러리 접근 권한이 필요합니다'),
          action: SnackBarAction(
            label: '설정',
            onPressed: PermissionService.openAppSettings,
          ),
        ),
      );
    }
    return;
  }

  // 권한 승인됨 → 파일 선택
  final result = await ImagePicker().pickImage(source: ImageSource.gallery);
  // ...
}
```

---

## 2. 🔑 소셜 로그인 및 SHA-1 설정

### 2.1. SHA-1 지문 추출

**Debug 키 (개발용)**:
```bash
# Windows
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android

# macOS/Linux
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
```

**Release 키 (배포용)**:
```bash
# 1. 키스토어 생성 (최초 1회)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. SHA-1 추출
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

**출력 예시**:
```
Certificate fingerprints:
SHA1: A1:B2:C3:D4:E5:F6:...
SHA256: 1A:2B:3C:4D:...
```

### 2.2. Supabase에 SHA-1 등록

1. **Supabase Dashboard** → Authentication → Providers → Google
2. **Android Package Name**: `com.uncany.app` (실제 패키지명)
3. **SHA-1 Certificate Fingerprint**: 위에서 추출한 SHA-1 값 입력
4. **Redirect URL**: `uncany://auth-callback` 또는 `https://uncany.app/auth/callback`

### 2.3. Deep Link 라우팅 설정

**파일 수정**: `lib/src/core/router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    // 🔗 Deep Link 처리 (비밀번호 재설정)
    final uri = state.uri;
    if (uri.queryParameters.containsKey('type')) {
      final type = uri.queryParameters['type'];

      if (type == 'recovery') {
        // Supabase Auth 토큰 처리
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];

        if (accessToken != null && refreshToken != null) {
          try {
            await Supabase.instance.client.auth.setSession(
              Session(
                accessToken: accessToken,
                refreshToken: refreshToken,
                tokenType: 'bearer',
                user: null, // Will be filled by Supabase
              ),
            );
            return '/reset-password'; // 비밀번호 재설정 화면으로
          } catch (e) {
            print('세션 설정 실패: $e');
          }
        }
      }
    }

    return null; // 정상 라우팅 진행
  },
  routes: [
    // 기존 라우트들...
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
  ],
);
```

### 2.4. main.dart에 Deep Link 리스너 추가

**파일 수정**: `lib/main.dart`

```dart
import 'package:uni_links/uni_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const UncanyApp());

  // 🔗 Deep Link 리스너 시작
  _initDeepLinkListener();
}

StreamSubscription? _deepLinkSub;

void _initDeepLinkListener() {
  _deepLinkSub = uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      // GoRouter가 자동으로 처리하지만, 추가 로직 필요 시 여기서
      print('Deep Link 수신: $uri');
    }
  }, onError: (err) {
    print('Deep Link 에러: $err');
  });
}
```

**pubspec.yaml 추가**:
```yaml
dependencies:
  uni_links: ^0.5.1  # Deep Link 감지
```

---

## 3. 🎨 네이티브 에셋 생성

### 3.1. pubspec.yaml 설정

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.10

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
  adaptive_icon_background: "#FFFFFF"  # 배경색
  adaptive_icon_foreground: "assets/images/logo_foreground.png"  # 전경 (투명 배경)

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/images/splash_logo.png
  android_12:
    image: assets/images/splash_logo.png
    color: "#FFFFFF"
  ios: true
  android: true
```

### 3.2. 이미지 준비

**필요한 파일**:
```
assets/images/
├── logo.png                 (1024x1024, 정사각형)
├── logo_foreground.png      (1024x1024, 투명 배경, Android Adaptive용)
└── splash_logo.png          (512x512, 스플래시 화면용)
```

**디자인 가이드**:
- **logo.png**: 배경색 포함, iOS 및 기본 Android 아이콘
- **logo_foreground.png**: 투명 배경, Android 13+ Adaptive Icon용
- **splash_logo.png**: 앱 로딩 시 표시되는 로고

### 3.3. 생성 명령어

```bash
# 1. 아이콘 생성
flutter pub run flutter_launcher_icons

# 2. 스플래시 화면 생성
flutter pub run flutter_native_splash:create
```

---

## 4. 🍎 애플 로그인 구현

### 4.1. pubspec.yaml 의존성

```yaml
dependencies:
  sign_in_with_apple: ^5.0.0
```

### 4.2. iOS Capability 설정

**Xcode 작업**:
1. `ios/Runner.xcworkspace` 열기
2. Runner 선택 → Signing & Capabilities
3. `+ Capability` 클릭
4. **Sign in with Apple** 추가

### 4.3. Supabase 설정

**Supabase Dashboard**:
1. Authentication → Providers → Apple
2. **Enabled** 체크
3. **Client ID**: `com.uncany.app` (Bundle ID와 동일)
4. **Services ID**: Apple Developer Console에서 생성한 ID

### 4.4. 로그인 로직 추가

**파일 수정**: `lib/src/features/auth/presentation/login_screen.dart`

```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends ConsumerWidget {
  // 기존 구글 로그인 버튼 아래에 추가

  Widget _buildAppleSignInButton(BuildContext context, WidgetRef ref) {
    // iOS에서만 표시 (애플 가이드라인 4.8 준수)
    if (!defaultTargetPlatform == TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    return SignInWithAppleButton(
      onPressed: () async {
        try {
          final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

          // Supabase Auth로 전달
          final response = await Supabase.instance.client.auth.signInWithIdToken(
            provider: OAuthProvider.apple,
            idToken: credential.identityToken!,
            nonce: credential.authorizationCode,
          );

          if (response.user != null) {
            // 로그인 성공
            context.go('/home');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('애플 로그인 실패: $e')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // 기존 구글 로그인 버튼
          _buildGoogleSignInButton(context, ref),

          const SizedBox(height: 16),

          // 애플 로그인 버튼 (iOS만)
          _buildAppleSignInButton(context, ref),
        ],
      ),
    );
  }
}
```

---

## 5. 🗑️ 회원 탈퇴 기능

### 5.1. Supabase Edge Function 생성

**파일 생성**: `supabase/functions/delete-account/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

serve(async (req: Request) => {
  try {
    // JWT 검증
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: '인증이 필요합니다' }),
        { status: 401 }
      );
    }

    // 사용자 확인
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const jwt = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(jwt);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401 }
      );
    }

    // 1. 사용자 데이터 Soft Delete (RLS 정책 우회 위해 Service Role 사용)
    const adminClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // users 테이블 soft delete
    await adminClient
      .from('users')
      .update({ deleted_at: new Date().toISOString() })
      .eq('id', user.id);

    // reservations 테이블 soft delete
    await adminClient
      .from('reservations')
      .update({ deleted_at: new Date().toISOString() })
      .eq('teacher_id', user.id);

    // 2. Supabase Auth 계정 삭제
    await adminClient.auth.admin.deleteUser(user.id);

    console.log(`[DELETE ACCOUNT] 사용자 삭제: ${user.email} (${user.id})`);

    return new Response(
      JSON.stringify({ message: '회원 탈퇴가 완료되었습니다' }),
      { status: 200 }
    );
  } catch (error) {
    console.error('회원 탈퇴 에러:', error);
    return new Response(
      JSON.stringify({ error: '서버 오류가 발생했습니다' }),
      { status: 500 }
    );
  }
});
```

**배포**:
```bash
supabase functions deploy delete-account
```

### 5.2. Flutter 클라이언트 구현

**파일 수정**: `lib/src/features/settings/presentation/profile_screen.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text(
          '정말로 탈퇴하시겠습니까?\n\n'
          '• 모든 예약 정보가 삭제됩니다\n'
          '• 이 작업은 취소할 수 없습니다',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Edge Function 호출
      final response = await Supabase.instance.client.functions.invoke(
        'delete-account',
      );

      if (response.status == 200) {
        // 로그아웃 처리
        await Supabase.instance.client.auth.signOut();

        if (context.mounted) {
          context.go('/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원 탈퇴가 완료되었습니다')),
          );
        }
      } else {
        throw Exception('탈퇴 실패');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: ListView(
        children: [
          // 기존 프로필 내용...

          const Divider(height: 32),

          // 🗑️ 회원 탈퇴 버튼
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              '회원 탈퇴',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. 📋 배포 체크리스트

### Android (Play Store)

- [ ] **AndroidManifest.xml** 권한 설정 완료
- [ ] **SHA-1 지문** Supabase/Firebase 등록
- [ ] **Release 키스토어** 생성 및 `android/key.properties` 설정
- [ ] **앱 아이콘** 생성 (`flutter_launcher_icons`)
- [ ] **스플래시 화면** 생성 (`flutter_native_splash`)
- [ ] **Deep Link** 테스트 (비밀번호 재설정 이메일)
- [ ] **회원 탈퇴** 기능 테스트
- [ ] **Proguard 규칙** 확인 (`android/app/proguard-rules.pro`)
- [ ] **버전 코드/이름** 업데이트 (`android/app/build.gradle`)

### iOS (App Store)

- [ ] **Info.plist** 권한 설명 문구 작성
- [ ] **Xcode Capability** Sign in with Apple 추가
- [ ] **Universal Links** 설정 (`apple-app-site-association` 파일)
- [ ] **앱 아이콘** 생성
- [ ] **스플래시 화면** 생성
- [ ] **애플 로그인** 테스트
- [ ] **회원 탈퇴** 기능 테스트
- [ ] **Bundle ID** 확인
- [ ] **버전/빌드 번호** 업데이트 (`ios/Runner/Info.plist`)
- [ ] **TestFlight** 빌드 업로드 및 내부 테스트

### 공통

- [ ] **Supabase Edge Function** 배포 (`delete-account`)
- [ ] **환경 변수** 프로덕션용 설정
- [ ] **에러 모니터링** (Sentry/Firebase Crashlytics)
- [ ] **개인정보 처리방침** URL 준비
- [ ] **이용약관** URL 준비
- [ ] **스토어 스크린샷** 준비 (5.5", 6.5" for iOS / 핸드폰, 태블릿 for Android)
- [ ] **앱 설명** 작성 (한국어 + 영어)

---

## 7. 🚀 빌드 및 배포 명령어

### Android Release 빌드

```bash
# 1. 앱 번들 생성 (권장)
flutter build appbundle --release

# 2. APK 생성 (직접 배포용)
flutter build apk --release --split-per-abi
```

**출력 위치**:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`

### iOS Release 빌드

```bash
# 1. Xcode에서 Archive 생성
open ios/Runner.xcworkspace

# 2. Product → Archive
# 3. Distribute App → App Store Connect
```

또는 CLI:
```bash
flutter build ipa --release
```

---

## 8. 📝 추가 설정 파일

### android/app/build.gradle (Release 서명)

```gradle
android {
    // ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### android/key.properties (Git에 추가 금지!)

```properties
storePassword=<키스토어 비밀번호>
keyPassword=<키 비밀번호>
keyAlias=upload
storeFile=<키스토어 파일 경로, 예: /Users/name/upload-keystore.jks>
```

### .gitignore에 추가

```
# Release 키
android/key.properties
android/*.jks
ios/Runner/GoogleService-Info.plist
```

---

**작성자**: Claude Sonnet 4.5
**검토자**: Gemini (승인 완료)
**최종 업데이트**: 2026-01-13
