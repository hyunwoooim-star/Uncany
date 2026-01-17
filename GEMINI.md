# Gemini 프로젝트 개발 규칙

## 프로젝트 개요

- **프로젝트**: Uncany (Flutter Web 앱)
- **언어**: 한국어 전용 앱
- **환경**: WSL + Flutter Web

## Claude와 협업 시 규칙

### 작업 시작 전 (필수)

```bash
git pull
```
그 후 `docs/SESSION_SUMMARY.md` 확인하여 Claude가 남긴 인수인계 확인

### 작업 완료 시 (필수)

1. 커밋 & 푸시
2. `docs/SESSION_SUMMARY.md` 업데이트:

```markdown
## 최근 작업 (YYYY-MM-DD HH:MM)
- 작업자: Gemini
- 작업 내용: [간단한 설명]
- 변경된 파일: [파일 목록]
- 다음 작업자에게: [인수인계 사항]
```

### Claude에게 피드백/문제 전달 시

Claude가 이해하기 쉽게:

1. **위치 명시**: `파일명:라인번호` 형식
   - 예: `lib/services/auth_service.dart:45`

2. **문제 설명 포맷**:
   ```
   [문제] 간단한 설명
   [위치] 파일명:라인번호
   [현상] 무슨 일이 일어나는지
   [예상] 무슨 일이 일어나야 하는지
   ```

3. **에러 전달 시**: 전체 에러 메시지 + 스택트레이스 포함

### Claude에게 요청 시

```
[요청] 무엇을 해달라는지
[이유] 왜 필요한지 (선택)
[참고] 관련 파일/코드 (있으면)
```

## 코드 규칙 (CLAUDE.md와 동일)

- 모든 UI/에러 메시지: 한국어
- 변수명/함수명: 영어 camelCase
- 클래스명: 영어 PascalCase
- 주석: 한국어

## 핵심 파일 위치

- `docs/SESSION_SUMMARY.md` - 작업 현황
- `CLAUDE.md` - Claude 규칙 (상세)
- `lib/` - Flutter 소스코드
