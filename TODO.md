# Uncany 남은 작업 목록

**최종 업데이트**: 2026-01-12 (23:30)

---

## ✅ 완료된 작업

### 2026-01-12
- ✅ Phase 1 이메일/SMS 수신동의 체크박스
- ✅ 법률 준수 코드 구현 (CPO 정보, 재직증명서 자동삭제, 동의 추적)
- ✅ 개인정보 관리 화면 (열람/다운로드/탈퇴/마케팅 동의 철회)
- ✅ 사업자등록증 분석 및 가이드 작성
- ✅ Database 마이그레이션 적용 (003, 004, 005)
- ✅ 정식 출시 체크리스트 작성

**결과**: 모든 핵심 기능 완료, 법률 준수 완료, 베타 테스트 준비 완료

---

## 🚀 정식 출시 전 필수 작업

### 1. 사업자 등록 (오프라인)
- [ ] 홈택스: 업종 추가 (721902)
- [ ] 김포시청: 통신판매업 신고 확인 및 신고

**상세 가이드**: `BUSINESS_REGISTRATION_GUIDE.md`

### 2. 앱 정보 업데이트 (코드 수정)
- [ ] `business_info_screen.dart`에 실제 사업자 정보 입력
- [ ] 통신판매업 신고번호 입력
- [ ] "베타 테스트" → "정식 운영" 변경

**상세 체크리스트**: `RELEASE_CHECKLIST.md`

---

## 🔧 선택적 작업

### 테스트 코드 (낮은 우선순위)
- [ ] Repository 테스트 Mock 에러 수정
  - `auth_repository_test.dart`
  - `user_repository_test.dart`
  - `reservation_repository_test.dart`

### 향후 계획
- [ ] 모바일 앱 준비 (Android/iOS)
- [ ] Phase 2 알림 업그레이드 (SendGrid/AWS SES)
- [ ] RLS 정책 최적화 (사용자 많아지면)

---

## 📝 테스트 방법

### 로컬 테스트
```bash
cd /home/user/Uncany
flutter pub get
flutter run -d chrome --dart-define=NEIS_API_KEY=your_key
```

### Staging 테스트
**URL**: https://uncany-staging.web.app

### 테스트 시나리오
1. 회원가입 → 이메일 인증 → 로그인
2. 학교 검색 및 선택
3. 재직증명서 업로드
4. 관리자 승인/반려
5. 상담실 예약
6. 개인정보 관리 (열람/다운로드/탈퇴)
7. 마케팅 동의 on/off

**상세 테스트 가이드**: `RELEASE_CHECKLIST.md` 참고

---

## 📚 문서 정리

### 필수 문서
- ✅ `README.md` - 프로젝트 소개
- ✅ `CLAUDE.md` - 개발 규칙
- ✅ `BUSINESS_REGISTRATION_GUIDE.md` - 사업자 등록 가이드
- ✅ `RELEASE_CHECKLIST.md` - 정식 출시 체크리스트
- ✅ `SESSION_SUMMARY.md` - 작업 기록
- ✅ `TODO.md` - 이 문서

### 참고 문서 (docs/)
- `DEPLOYMENT_AND_CI_PLAN.md` - 배포 가이드
- `PHASE2_UPGRADE_PLAN.md` - Phase 2 업그레이드 계획
- `PRIVACY_AND_SECURITY.md` - 보안 가이드
- `SUPABASE_SETUP.md` - Supabase 설정

---

## 🎯 현재 상태

**베타 테스트 준비 완료**: 95% ✨

**완료**:
- ✅ 모든 핵심 기능
- ✅ 법률 준수 시스템
- ✅ Database 스키마
- ✅ 개인정보 관리

**남음**:
- ⏳ 사업자등록 업종 추가 (나중에)
- ⏳ 통신판매업 신고 (나중에)

---

**다음 단계**: 베타 테스트 시작 or 정식 출시 준비 (`RELEASE_CHECKLIST.md` 참고)
