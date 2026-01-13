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

## AI 모델 선택 권한

- Claude Code는 **Opus**와 **Sonnet** 모델을 자율적으로 선택 가능
- 작업 복잡도에 따라 최적의 모델 사용
- 간단한 작업: Haiku 또는 Sonnet
- 복잡한 작업: Opus
- 비용 효율성과 성능 사이의 균형 유지

---

## 🚀 작업 최적화 및 속도 개선

### 토큰 소비 최적화

1. **파일 읽기 최소화**
   - 필요한 파일만 정확히 읽기
   - `limit` 파라미터 활용 (예: 처음 50줄만)
   - 전체 프로젝트를 읽지 말 것

2. **검색 우선 사용**
   - Grep으로 키워드 검색 후 필요한 파일만 Read
   - Glob으로 파일 목록만 확인
   - Task tool은 복잡한 탐색 시에만 사용

3. **문서 참조 순서**
   - SESSION_SUMMARY.md: 현재까지의 작업 현황
   - DEPLOYMENT_AND_CI_PLAN.md: 배포 관련
   - 필요할 때만 전체 파일 읽기

4. **중복 작업 방지**
   - 이미 있는 기능은 재구현하지 않기
   - SESSION_SUMMARY 먼저 확인

### 작업 속도 개선

1. **병렬 처리**
   - 독립적인 파일은 한 번에 여러 개 작성
   - 여러 파일 읽기는 한 번에 여러 개 Read

2. **간결한 구현**
   - MVP(최소 기능 제품) 우선
   - 완벽보다는 작동하는 코드
   - TODO 주석으로 향후 개선 표시

3. **즉시 커밋 & 푸시**
   - 의미 있는 단위마다 commit
   - 여러 작업을 하나로 묶어 commit
   - 자주 푸시하여 작업 내용 보존

4. **문서는 마지막에**
   - 코드 먼저, 문서는 나중에
   - 너무 상세한 문서보다는 핵심만
   - SESSION_SUMMARY만 업데이트

### 효율적인 작업 순서

```
1. Grep/Glob으로 현황 파악 (1-2개 명령어)
2. 필요한 파일만 Read (최대 3-5개)
3. 코드 작성/수정
4. Commit & Push
5. SESSION_SUMMARY 간단 업데이트
```

### 금지 사항

❌ 전체 프로젝트 파일 트리 읽기
❌ 불필요한 긴 문서 작성
❌ 이미 완료된 작업 재확인
❌ 중복 검색/읽기
❌ 모든 파일 다시 읽기
