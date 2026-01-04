# Uncany 프로젝트 개발 규칙

## 한글화 (Korean Localization)

이 앱은 한국인 사용자만을 위한 앱입니다. 모든 UI 텍스트와 메시지는 반드시 한국어로 작성해야 합니다.

### 필수 규칙

1. **에러 메시지**: 모든 에러 메시지는 한국어로 표시
   - `ErrorMessages.fromAuthError()` 또는 `ErrorMessages.fromError()` 사용
   - 새로운 에러 유형 발견 시 `error_messages.dart`에 추가

2. **UI 텍스트**: 모든 버튼, 라벨, 힌트 텍스트는 한국어
   - 영어 텍스트 절대 금지
   - placeholder도 한국어 (예: 'example@email.com'은 예외)

3. **알림/토스트 메시지**: 사용자에게 보이는 모든 메시지는 한국어

4. **폼 검증 메시지**: `ErrorMessages` 클래스의 상수 사용
   - `ErrorMessages.requiredField`
   - `ErrorMessages.invalidEmail`
   - `ErrorMessages.invalidPassword`
   - 등등

### 개인정보보호법 준수

한국 개인정보보호법(개인정보의 안전성 확보조치 기준)을 준수합니다:

1. **파일 저장**: 개인 식별 정보가 포함된 파일명 사용 금지
   - `ImageCompressor.generateAnonymousFileName()` 사용

2. **이미지 압축**: 업로드 전 이미지 압축 필수
   - `ImageCompressor.compressToWebP()` 사용

3. **저장소 접근**: 개인 문서는 private 버킷에 저장
   - RLS 정책으로 본인만 접근 가능하게 설정

## 개발 환경

- WSL 환경에서 Flutter 개발 (Windows shader 컴파일 이슈 회피)
- Flutter Web 플랫폼 사용

## 코드 스타일

- 주석은 한국어로 작성
- 변수명/함수명은 영어 (camelCase)
- 클래스명은 영어 (PascalCase)
