# Uncany 정식 출시 체크리스트

**작성일**: 2026-01-12
**현재 상태**: 베타 테스트 단계

---

## 🎯 정식 출시 전 필수 작업

### 1. 사업자 등록 및 법률 준수 ⚠️ **필수**

#### 1-1. 사업자등록 업종 추가 (홈택스, 5분)
- [ ] 홈택스 접속 (www.hometax.go.kr)
- [ ] 신청/제출 → 사업자등록 정정신고
- [ ] 업종 추가: **721902** (응용 소프트웨어 개발 및 공급업)
- [ ] 신청 완료 확인

#### 1-2. 통신판매업 신고 (김포시청)
- [ ] 김포시청 민원실 전화: 031-980-2114
- [ ] 통신판매업 신고 여부 확인
- [ ] 미신고 시 → 김포시청 방문 신고
- [ ] 신고번호 발급 받기

**상세 가이드**: `BUSINESS_REGISTRATION_GUIDE.md` 참고

---

### 2. 앱 정보 업데이트 ⚠️ **필수**

#### 2-1. 사업자 정보 입력
**파일**: `lib/src/features/settings/presentation/business_info_screen.dart`

```dart
// 현재 (베타)
_InfoItem(label: '상호', value: '정식 사업자 등록 절차 진행 중'),
_InfoItem(label: '대표자', value: '정식 사업자 등록 절차 진행 중'),
_InfoItem(label: '사업자등록번호', value: '등록 예정 (출시 전 완료)'),

// 수정 (정식 출시)
_InfoItem(label: '상호', value: '아는사람'),
_InfoItem(label: '대표자', value: '임원철'),
_InfoItem(label: '사업자등록번호', value: '726-02-02763'),
_InfoItem(label: '통신판매업 신고번호', value: 'XXXX-경기김포-XXXX'),
_InfoItem(label: '사업장 소재지', value: '경기도 김포시 대곶면 대곶남로 453-8'),
_InfoItem(label: '서비스 상태', value: '정식 운영'),
```

**작업 순서**:
- [ ] 파일 열기
- [ ] 실제 사업자 정보로 수정
- [ ] 통신판매업 신고번호 입력
- [ ] "베타 테스트" → "정식 운영" 변경
- [ ] 커밋 & 푸시

---

### 3. 테스트 ✅ **권장**

#### 3-1. 로컬 테스트 (개발 환경)
```bash
cd /home/user/Uncany
flutter pub get
flutter run -d chrome --dart-define=NEIS_API_KEY=your_key
```

**테스트 시나리오**:
- [ ] 회원가입 → 이메일 인증 → 로그인
- [ ] 학교 검색 (NEIS API)
- [ ] 재직증명서 업로드
- [ ] 관리자 승인/반려 (admin 계정)
- [ ] 상담실 예약 생성/조회/취소
- [ ] 개인정보 관리 화면 (열람/다운로드/탈퇴)
- [ ] 마케팅 동의 on/off
- [ ] 프로필 수정
- [ ] 비밀번호 재설정

#### 3-2. Staging 환경 테스트
**URL**: https://uncany-staging.web.app

- [ ] 배포 확인 (git push 후 GitHub Actions)
- [ ] 위 시나리오 전체 테스트
- [ ] 모바일 브라우저 테스트 (Chrome, Safari)
- [ ] 다양한 화면 크기 테스트

#### 3-3. Database 확인
**Supabase Dashboard**: https://supabase.com/dashboard

- [ ] users 테이블 데이터 확인
- [ ] 재직증명서 자동 삭제 예정일 확인 (`document_delete_scheduled_at`)
- [ ] 동의 날짜 기록 확인 (`terms_agreed_at`, `privacy_agreed_at`)
- [ ] 마케팅 동의 확인 (`agree_to_email_marketing`, `agree_to_sms_marketing`)
- [ ] RLS 정책 동작 확인

---

### 4. 보안 점검 ✅ **권장**

#### 4-1. 환경변수 확인
- [ ] GitHub Secrets에 `NEIS_API_KEY` 등록 확인
- [ ] Supabase 환경변수 확인
- [ ] API 키가 코드에 하드코딩되지 않았는지 확인

#### 4-2. RLS 정책 검토
- [ ] users 테이블: 본인만 조회/수정 가능
- [ ] reservations 테이블: 본인 예약만 조회
- [ ] schools 테이블: 모두 조회 가능
- [ ] classrooms 테이블: 해당 학교 학생만 조회

#### 4-3. Storage 권한 확인
- [ ] private 버킷: 본인만 접근
- [ ] public 버킷: 없음 (모든 파일 private)

---

### 5. 성능 최적화 (선택)

#### 5-1. RLS 정책 최적화
**현재**: 9개 경고 (Performance Advisor)
- Auth RLS Initialization Plan (6건)
- Multiple Permissive Policies (3건)

**영향**: 미미 (사용자 수백~수천명까지는 문제 없음)

**최적화 시점**: 사용자 수만명 이상 or 쿼리 속도 느려질 때

#### 5-2. 이미지 최적화
- [ ] 로고/아이콘 WebP 포맷 사용 확인
- [ ] 불필요한 asset 제거

---

### 6. 문서 최종 검토 (선택)

#### 6-1. 필수 문서 확인
- [ ] README.md: 프로젝트 설명 최신화
- [ ] CLAUDE.md: 개발 규칙 확인
- [ ] BUSINESS_REGISTRATION_GUIDE.md: 사업자 등록 가이드
- [ ] RELEASE_CHECKLIST.md: 이 문서

#### 6-2. 불필요한 문서 제거
- [ ] 중복 파일 삭제
- [ ] 오래된 TODO 제거
- [ ] 임시 파일 정리

---

## 🚀 배포 프로세스

### Production 배포 (Firebase Hosting)

#### 사전 준비
- [ ] Firebase 프로젝트 생성 (Production용)
- [ ] 커스텀 도메인 설정 (선택)
- [ ] Firebase CLI 설치: `npm install -g firebase-tools`

#### 배포 명령어
```bash
# 1. Firebase 로그인
firebase login

# 2. 프로젝트 초기화
firebase init hosting

# 3. 빌드
flutter build web --release --dart-define=NEIS_API_KEY=your_key

# 4. 배포
firebase deploy --only hosting

# 5. 배포 확인
# https://your-project.web.app 접속
```

#### GitHub Actions 자동 배포 (권장)
**파일**: `.github/workflows/deploy-production.yml` 생성

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
      - run: flutter pub get
      - run: flutter build web --release --dart-define=NEIS_API_KEY=${{ secrets.NEIS_API_KEY }}
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
```

---

## 📊 출시 후 모니터링

### 1주차 체크리스트
- [ ] 신규 회원가입 수 확인
- [ ] 에러 로그 확인 (Supabase Logs)
- [ ] 재직증명서 승인/반려 처리
- [ ] 사용자 피드백 수집
- [ ] 서버 성능 모니터링

### 1개월 체크리스트
- [ ] 재직증명서 30일 자동 삭제 동작 확인
- [ ] 마케팅 이메일 발송 (동의자만)
- [ ] Database 백업 확인
- [ ] 사용자 통계 분석

---

## ✅ 체크리스트 요약

### 필수 (정식 출시 전)
1. ⚠️ 사업자등록 업종 추가
2. ⚠️ 통신판매업 신고
3. ⚠️ 앱 내 사업자 정보 업데이트

### 권장 (출시 전)
1. ✅ 전체 기능 테스트
2. ✅ Staging 환경 테스트
3. ✅ Database 데이터 확인
4. ✅ 보안 점검

### 선택 (필요 시)
1. 🔧 RLS 정책 최적화
2. 🔧 이미지 최적화
3. 🔧 문서 정리

---

## 📞 문의 및 지원

- **사업자등록**: 국세청 126, 홈택스 1544-9944
- **통신판매업**: 김포시청 031-980-2114
- **기술 지원**: Supabase Dashboard, Firebase Console

---

**마지막 업데이트**: 2026-01-12
**현재 진행 상황**: 베타 테스트 단계 (법률 준수 완료, 모든 기능 정상 작동)
