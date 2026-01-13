# 🚀 다음 세션 바로 시작 명령어

**작성일**: 2026-01-13
**현재 상태**: 코드 100% 완성, 플랫폼 생성 대기 중

---

## 📍 현재까지 완료된 것

✅ flutter_localizations 추가 (pubspec.yaml, app.dart)
✅ iOS Privacy Manifest 템플릿 생성
✅ AndroidManifest.xml 템플릿 생성
✅ Info.plist 템플릿 생성
✅ file_paths.xml 템플릿 생성
✅ SafeArea 가이드 작성
✅ 모든 문서 커밋 & 푸시 완료

---

## 🎯 다음 세션에서 바로 실행할 명령어 (복사 붙여넣기)

### 1. WSL 터미널 열고 프로젝트 이동
```bash
cd /mnt/c/Users/임현우/.claude-worktrees/Uncany/musing-thompson
```

### 2. 최신 코드 pull
```bash
git pull origin musing-thompson
```

### 3. 백업 커밋 (플랫폼 추가 전 필수!)
```bash
git add -A
git commit -m "feat: 모바일 플랫폼 추가 전 백업"
```

### 4. 플랫폼 추가
```bash
flutter create --org com.uncany --platforms android,ios .
```

### 5. pubspec.yaml 복구 (덮어씌워졌을 경우)
```bash
git status
# pubspec.yaml이 modified로 나오면 아래 실행
git checkout -- pubspec.yaml
flutter pub get
```

### 6. 템플릿 파일 복사
```bash
# Android
cp docs/templates/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
mkdir -p android/app/src/main/res/xml
cp docs/templates/android/file_paths.xml android/app/src/main/res/xml/file_paths.xml

# iOS
cp docs/templates/ios/PrivacyInfo.xcprivacy ios/Runner/PrivacyInfo.xcprivacy
```

### 7. 이미지 폴더 생성
```bash
mkdir -p assets/images
```

### 8. 이미지 준비 확인 (Windows에서 수동 작업)
```bash
ls -lh assets/images/
# logo.png, logo_foreground.png, splash_logo.png 확인
```

### 9. 네이티브 에셋 생성 (이미지 준비 후)
```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### 10. Edge Function 배포
```bash
supabase functions deploy delete-account
supabase functions deploy neis-api
```

### 11. 빌드 테스트
```bash
# Android
flutter run -d android

# Web (기존 기능 확인)
flutter run -d chrome
```

---

## 📋 Info.plist 수동 병합 (Step 6 이후)

**파일 열기**:
```bash
code ios/Runner/Info.plist
```

**참조 파일**: `docs/templates/ios/Info.plist`

**병합 방법**:
1. `ios/Runner/Info.plist` 열기
2. `<dict>` 태그 안에 `docs/templates/ios/Info.plist` 내용 추가
3. 덮어쓰지 말고 기존 내용과 병합!

---

## 🔑 SHA-1 추출 (Windows PowerShell)

**PowerShell 열고 실행**:
```powershell
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

**SHA1 값 복사 후**:
1. Supabase Dashboard → Authentication → Providers → Google
2. Android Package Name: `com.uncany.uncany`
3. SHA-1 Certificate Fingerprint 입력
4. Save

---

## 📦 준비할 이미지 (Windows에서 작업)

**저장 위치**: `C:\Users\임현우\.claude-worktrees\Uncany\musing-thompson\assets\images\`

**필요한 파일** (3개):
- `logo.png` (1024x1024)
- `logo_foreground.png` (1024x1024, 투명 배경!)
- `splash_logo.png` (512x512)

**임시 로고 생성**: https://appicon.co/

---

## 🚨 문제 해결

### pubspec.yaml 덮어씌워짐
```bash
git checkout -- pubspec.yaml
flutter pub get
```

### Android 빌드 실패
```bash
flutter clean
flutter pub get
flutter doctor --android-licenses
```

### 이미지 없음 에러
```bash
# 임시로 아무 이미지 복사
cp some_image.png assets/images/logo.png
cp some_image.png assets/images/logo_foreground.png
cp some_image.png assets/images/splash_logo.png
```

---

## ✅ 체크리스트

```
[ ] git pull origin musing-thompson
[ ] git commit 백업
[ ] flutter create --platforms android,ios .
[ ] pubspec.yaml 복구 확인
[ ] AndroidManifest.xml 복사
[ ] file_paths.xml 복사
[ ] PrivacyInfo.xcprivacy 복사
[ ] Info.plist 수동 병합
[ ] assets/images/ 이미지 3개 준비
[ ] flutter pub run flutter_launcher_icons
[ ] flutter pub run flutter_native_splash:create
[ ] SHA-1 추출 및 Supabase 등록
[ ] supabase functions deploy delete-account
[ ] supabase functions deploy neis-api
[ ] flutter run -d android 테스트
```

---

## 📚 참고 문서

- `docs/MOBILE_IMPLEMENTATION_COMPLETE.md`: 전체 가이드
- `docs/SAFEAREA_GUIDE.md`: SafeArea 적용 가이드
- `docs/ADD_MOBILE_PLATFORMS.md`: 플랫폼 추가 상세
- `docs/templates/`: 모든 템플릿 파일

---

**최종 업데이트**: 2026-01-13
**다음 세션 시작 명령어**: 위 1번부터 순서대로 실행!
