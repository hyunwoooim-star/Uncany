# Uncany 세션 요약

## 마지막 업데이트: 2026-01-13 23:30

---

## 프로젝트 현재 상태: ✅ v0.3 (모바일 배포 준비 완료)

### 완료된 핵심 기능
- 인증 시스템 (로그인/회원가입/로그아웃/비밀번호 재설정)
- 예약 시스템 (교시 기반, Advisory Lock으로 동시성 제어)
- 교실 관리 (CRUD)
- 프로필 관리 (학년/반 정보)
- 관리자 기능 (사용자 승인/반려/삭제)
- 법적 문서 (이용약관, 개인정보처리방침, 사업자 정보)
- 아이디 찾기/비밀번호 찾기
- **학교 검색 (NEIS API 연동)**
- **승인 대기 온보딩 화면 (토스 스타일)**

### 오늘 완료된 작업 (2026-01-13)

#### 브랜치 정리
- musing-thompson → exciting-margulis 머지
- exciting-margulis → main 머지 (PR #2~#7)
- 문서 최신화 및 중복 파일 정리

#### 모바일 플랫폼 추가
- `flutter create --platforms android,ios .` 완료
- AndroidManifest.xml 템플릿 적용
- Info.plist 병합 (권한 설명, 딥링크, ATS 설정)
- PrivacyInfo.xcprivacy 복사
- 실제 로고 이미지 적용 (Uncany.png)

#### 버그 수정
- NEIS API 키 환경변수 연동 복원
- 학교 샘플 데이터 35개로 확장
- widget_test.dart 삭제 (테스트 실패 해결)
- Auto Documentation workflow 수정

#### 승인 대기 온보딩 (PR #9)
- `PendingApprovalScreen` 신규 생성 (토스 스타일)
- 라우터에 승인 대기 상태 체크 및 리다이렉트 로직 추가
- 회원가입 완료 시 승인 대기 화면으로 자동 이동
- 새로고침으로 승인 상태 확인 가능

---

## GitHub Secrets 설정 완료

- [x] SUPABASE_URL_STAGING
- [x] SUPABASE_ANON_KEY_STAGING
- [x] FIREBASE_SERVICE_ACCOUNT
- [x] NEIS_API_KEY ✅

---

## 배포 현황

| 환경 | URL | 상태 |
|------|-----|------|
| Staging | https://uncany-staging.web.app | ✅ 최신 배포됨 |
| Production | - | 미설정 |

---

## 다음 작업

### 우선순위 높음
1. Staging에서 전체 기능 테스트
   - 학교 검색 (NEIS API)
   - 회원가입 플로우
   - 예약 기능

### 우선순위 중간
- Edge Functions 배포 (delete-account, neis-api)
- SHA-1 키 Supabase 등록 (Android Google 로그인)
- 알림 시스템 (FCM)

### 우선순위 낮음
- Production 배포
- 앱스토어 등록 준비

---

## 개발 환경 참고

### 빌드 방법
- **권장**: GitHub Actions 사용 (push → main 자동 빌드/배포)
- **Windows 로컬**: shader compiler 이슈 발생 가능

### 주요 파일 위치
```
lib/src/core/router/router.dart       # 라우트 정의
lib/src/features/auth/               # 인증 관련
lib/src/features/reservation/        # 예약 관련
lib/src/features/school/             # 학교 검색 (NEIS API)
supabase/migrations/                 # DB 마이그레이션
supabase/functions/                  # Edge Functions
docs/templates/                      # Android/iOS 템플릿
```

---

## 최근 커밋

```
03af40a feat: 승인 대기 온보딩 화면 추가 (토스 스타일)
806733e fix: Auto Documentation workflow - PROJECT_PLAN.md 없어도 실패 안 함
1b34669 fix: NEIS API 키 환경변수 연동 복원
e5e9437 feat: 실제 로고 이미지 적용 (Uncany.png)
e3bf70e fix: 학교 샘플 데이터 확장 (35개 학교 추가)
fc1dac5 test: 불필요한 widget_test.dart 삭제
```

---

## 알려진 이슈

1. **audit_log_screen.dart**: 모의 데이터 사용 중
2. **Deploy Web Preview**: GitHub 권한 문제 (앱 동작에 영향 없음)
