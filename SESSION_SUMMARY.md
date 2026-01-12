# Uncany 세션 요약

## 최종 업데이트: 2026-01-12 (17:00)

---

## 🎉 오늘 완료된 작업 (2026-01-12 오후)

### 1. 회원가입 및 비밀번호 재설정 오류 수정
- **비밀번호 재설정**: redirectTo를 웹 URL로 변경 (`uncany://...` → `https://...`)
- **Environment.appUrl** 추가 (환경별 URL 자동 선택)
- **UpdatePasswordScreen** 신규 추가 (이메일 링크 → 비밀번호 설정)
- **회원가입 오류**: neisCode null 체크 강화
- 커밋: `e7fe557`

### 2. 사업자 정보, 날짜 필터, 나이스 API 연동
- **사업자 정보**: Mock 데이터 → 개발 단계 표시
- **감사 로그**: 날짜 범위 필터 추가 (시작일/종료일 DatePicker)
- **나이스 API**: GitHub Actions workflow에 `NEIS_API_KEY` 추가
- **README**: API 키 발급 가이드 추가
- 커밋: `14a221d`

### 3. 나이스 교육청 API 키 발급 완료 ✅
- **공공데이터포털** 활용신청 완료
- **인증키 발급**: `8625dd0f...` (숨김)
- **GitHub Secrets 등록**: `NEIS_API_KEY` 완료
- **효과**: 전국 모든 학교 검색 가능 (Mock 15개 → 실제 수천 개)

---

## 이전 완료된 작업 (2026-01-12 오전)

### 1. TODO 항목 4개 완료

#### signup_screen.dart: school_id 연동
- 선택한 학교를 DB에 자동 추가/조회 (neis_code 기준)
- users 테이블에 school_id 저장
- 파일: `lib/src/features/auth/presentation/signup_screen.dart:360-394`

#### user_repository.dart: 승인/반려 알림 발송
- `_sendApprovalNotification`, `_sendRejectionNotification` 함수 추가
- Phase 3에서 실제 이메일 발송 구현 예정 (현재는 로그만)
- 파일: `lib/src/features/auth/data/repositories/user_repository.dart:239-288`

#### audit_log_screen.dart: 실제 데이터 연결
- Supabase `audit_logs` 테이블 조회
- FutureBuilder로 실시간 데이터 표시
- 필터 기능 추가 (operation, 날짜)
- Mock 데이터 제거
- 파일: `lib/src/features/audit/presentation/audit_log_screen.dart`

#### school_api_service.dart: API 키 환경변수화
- `String.fromEnvironment('NEIS_API_KEY')` 사용
- 빌드 시 `--dart-define=NEIS_API_KEY=your_key`로 주입
- 파일: `lib/src/features/school/data/services/school_api_service.dart:10-17`

---

## 이전 작업 (2026-01-07)

### 1. UI 버그 수정
- **달력 날짜 색상**: 오늘 vs 선택일 구분 (오늘=테두리만, 선택=채움)
- **예약 시간 계산**: PeriodTimes 사용하여 실제 교시 시간 적용
- **교시 그리드 텍스트 오버플로우**: aspectRatio 조정 및 Padding 추가
- **비연속 교시 표시**: "1~6교시" → "1, 6교시" (연속 아닐 때)

### 2. 이메일 재발송 기능 구현
- `AuthRepository.resendVerificationEmail()` 메서드 추가
- `EmailVerificationScreen`에서 실제 Supabase API 호출 연동

### 3. 알림 시스템 (보류)
- 나중에 필요할 때 구현 예정

---

## 알려진 이슈

### Windows Flutter 빌드 셰이더 오류
```
ShaderCompilerException: ink_sparkle.frag failed with exit code -1073741819
```
**해결:** GitHub Actions에서 자동 빌드됨 (push 시)

---

## 남은 TODO (코드 내 주석)

| 파일 | 내용 | 우선순위 |
|------|------|----------|
| user_repository.dart | 실제 이메일 발송 구현 (Phase 3) | 중간 |
| business_info_screen.dart | 정식 사업자 정보로 업데이트 | 낮음 |

---

## 배포 정보

- **Staging:** https://uncany-staging.web.app
- **GitHub Actions:** push 시 자동 빌드/배포

---

## 재시작 명령어

```bash
cd C:\Users\임현우\Uncany
flutter pub get
flutter analyze lib --no-fatal-infos
flutter run -d chrome
```

---

## 다음 작업 우선순위

1. 모바일 앱 준비 (android/ios 폴더 생성)
2. 테스트 코드 추가
3. 알림 시스템 구현
4. Production 배포
