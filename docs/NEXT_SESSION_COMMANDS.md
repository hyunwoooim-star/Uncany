# 다음 세션 바로 시작 명령어

**작성일**: 2026-01-13
**현재 상태**: 코드 100% 완성, 플랫폼 생성 대기 중
**Git 브랜치**: `exciting-margulis` (musing-thompson과 병합됨)
**원격 저장소**: `https://github.com/hyunwoooim-star/Uncany.git`

---

## 현재까지 완료된 것

- flutter_localizations 추가 (pubspec.yaml, app.dart)
- iOS Privacy Manifest 템플릿 생성
- AndroidManifest.xml 템플릿 생성
- Info.plist 템플릿 생성
- file_paths.xml 템플릿 생성
- SafeArea 가이드 작성
- 보안 취약점 수정 (RLS, Advisory Lock, JWT 검증)

---

## 다음 세션에서 바로 실행할 명령어

### 1. 플랫폼 추가
```bash
flutter create --org com.uncany --platforms android,ios .
```

### 2. pubspec.yaml 복구 (덮어씌워졌을 경우)
```bash
git status
# pubspec.yaml이 modified로 나오면:
git checkout -- pubspec.yaml
flutter pub get
```

### 3. 템플릿 파일 복사
```bash
# Android
cp docs/templates/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
mkdir -p android/app/src/main/res/xml
cp docs/templates/android/file_paths.xml android/app/src/main/res/xml/file_paths.xml

# iOS
cp docs/templates/ios/PrivacyInfo.xcprivacy ios/Runner/PrivacyInfo.xcprivacy
```

### 4. 이미지 폴더 생성 및 준비
```bash
mkdir -p assets/images
# logo.png, logo_foreground.png, splash_logo.png 준비
```

### 5. 네이티브 에셋 생성 (이미지 준비 후)
```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### 6. Edge Function 배포
```bash
supabase functions deploy delete-account
supabase functions deploy neis-api
```

### 7. 빌드 테스트
```bash
flutter run -d android
flutter run -d chrome
```

---

## Info.plist 수동 병합

1. `ios/Runner/Info.plist` 열기
2. `<dict>` 태그 안에 `docs/templates/ios/Info.plist` 내용 추가
3. 덮어쓰지 말고 기존 내용과 병합!

---

## SHA-1 추출 (Windows PowerShell)

```powershell
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

SHA1 값 복사 후:
1. Supabase Dashboard → Authentication → Providers → Google
2. Android Package Name: `com.uncany.uncany`
3. SHA-1 Certificate Fingerprint 입력

---

## 준비할 이미지

저장 위치: `assets/images/`

필요한 파일 (3개):
- `logo.png` (1024x1024)
- `logo_foreground.png` (1024x1024, 투명 배경)
- `splash_logo.png` (512x512)

---

## 체크리스트

```
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
[ ] supabase functions deploy
[ ] flutter run -d android 테스트
```

---

## 참고 문서

- `docs/MOBILE_IMPLEMENTATION_COMPLETE.md`: 전체 가이드
- `docs/SAFEAREA_GUIDE.md`: SafeArea 적용 가이드
- `docs/ADD_MOBILE_PLATFORMS.md`: 플랫폼 추가 상세
- `docs/templates/`: 모든 템플릿 파일
- `docs/SESSION_SUMMARY.md`: 프로젝트 현황

---

**최종 업데이트**: 2026-01-13
