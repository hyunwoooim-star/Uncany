# Uncany 세션 요약

## 최종 업데이트: 2026-01-07

---

## 최근 완료된 작업 (2026-01-07)

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
| audit_log_screen.dart | 실제 데이터 연결, 필터 | 낮음 |
| user_repository.dart | 승인/반려 알림 발송 | 중간 |
| signup_screen.dart | school_id 연동 | 중간 |
| school_api_service.dart | API 키 환경변수화 | 낮음 |

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
