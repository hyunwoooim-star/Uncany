# 🏫 Uncany 프로젝트 20시간 작업 계획

**작성일**: 2026-01-04
**현재 브랜치**: claude/school-booking-platform-M3ffi
**목표**: 20시간 내 MVP 기능 완성

---

## 📊 현재 상태 보고서

### ✅ 완전히 작동하는 기능

#### 1. 프로젝트 인프라 (100%)
- **폴더 구조**: Feature-first 아키텍처 완벽 구축
  - `/lib/src/features/` - 기능별 모듈화
  - `/lib/src/core/` - 라우터, Provider, 설정
  - `/lib/src/shared/` - 공유 위젯, 테마
- **환경 설정**: `.env` 파일, Supabase 연동 준비 완료
- **의존성**: pubspec.yaml 모든 필수 패키지 설치됨

#### 2. Supabase 백엔드 (100%)
- **데이터베이스 스키마**: `/supabase/migrations/001_initial_schema.sql`
  - ✅ 7개 테이블 완성: users, classrooms, reservations, referral_codes, referral_usage, audit_logs, education_offices
  - ✅ RLS (Row Level Security) 정책 설정
  - ✅ 인덱스 최적화
- **Provider**: `/lib/src/core/providers/supabase_provider.dart`
  - ✅ Supabase 클라이언트 초기화
  - ✅ PKCE 인증 플로우

#### 3. 인증 시스템 UI (95%)
- **Splash Screen** (`lib/src/features/auth/presentation/splash_screen.dart`): ✅ 완성
  - 인증 상태 자동 확인
  - 로그인 페이지 또는 홈으로 자동 라우팅
- **Login Screen** (`lib/src/features/auth/presentation/login_screen.dart`): ✅ 완성
  - 이메일/비밀번호 폼
  - Supabase Auth 직접 연동
  - 에러 메시지 한글화
  - Welcome UI + Form 전환 애니메이션
- **Signup Screen** (`lib/src/features/auth/presentation/signup_screen.dart`): ✅ 완성
  - 재직증명서 업로드 (이미지 압축 WebP)
  - 추천인 코드 입력
  - 약관 동의
  - Supabase Storage 업로드 연동

#### 4. 데이터 모델 (100%)
모든 모델이 Freezed로 완벽 정의됨:
- ✅ User, Classroom, Reservation, ReferralCode, EducationOffice

#### 5. UI 컴포넌트 (100%)
- **Toss 스타일 디자인 시스템**:
  - ✅ TossColors, TossButton, TossCard
  - ✅ AppTheme (Google Fonts)

#### 6. 유틸리티 (100%)
- ✅ ErrorMessages (한글 에러 메시지)
- ✅ ImageCompressor (WebP 압축)

#### 7. 라우팅 (100%)
- ✅ GoRouter 설정 (인증 기반 리다이렉트)

---

### ⚠️ 부분 구현 (UI만 있고 백엔드 미연동)

#### 1. Home Screen (20%)
- **파일**: `lib/src/features/reservation/presentation/home_screen.dart`
- **현재 상태**:
  - ✅ UI 레이아웃 완성
  - ❌ 모든 onTap이 TODO 상태

#### 2. Auth Provider (60%)
- **파일**: `lib/src/core/providers/auth_provider.dart`
- **현재 상태**:
  - ✅ authSessionProvider, currentUserProvider
  - ❌ 로그아웃 로직 미구현

---

### ❌ 미구현 기능

#### 1. Data Layer 전체 (0%)
**치명적 누락**: Repository 패턴이 전혀 구현되지 않음

필요한 Repository:
- ❌ AuthRepository
- ❌ UserRepository
- ❌ ClassroomRepository
- ❌ ReservationRepository
- ❌ ReferralCodeRepository

#### 2. 예약 시스템 UI (0%)
- ❌ 교실 목록 화면
- ❌ 시간표 그리드 위젯
- ❌ 예약 생성 바텀시트
- ❌ 내 예약 내역 화면

#### 3. 교실 관리 (0%)
- ❌ 교실 목록 화면
- ❌ 교실 등록 폼
- ❌ 비밀번호 보호 교실 설정

#### 4. 관리자 기능 (0%)
- ❌ 관리자 대시보드
- ❌ 승인 대기 사용자 목록
- ❌ 재직증명서 확인 UI
- ❌ 승인/반려 처리

#### 5. 추가 인증 기능 (0%)
- ❌ 프로필 화면
- ❌ 프로필 수정
- ❌ 비밀번호 재설정
- ❌ 추천인 코드 관리 UI
- ❌ 로그아웃 버튼

---

## 🎯 20시간 작업 계획

### Phase 1-A: 핵심 백엔드 연동 (0-5시간)

**목표**: Repository 레이어 구축 + 기존 UI와 연결

#### 1.1 Auth Repository 구현 (1.5시간)
**파일**: `lib/src/features/auth/data/repositories/auth_repository.dart`

**구현 내용**:
```dart
class AuthRepository {
  Future<void> signOut()
  Future<User?> getCurrentUser()
  Future<void> updateProfile({name, schoolName})
  Future<void> resetPassword(String email)
}
```

**예상 소요**: 1.5시간

---

#### 1.2 User Repository 구현 (1시간)
**파일**: `lib/src/features/auth/data/repositories/user_repository.dart`

**구현 내용**:
```dart
class UserRepository {
  Future<List<User>> getUsers({VerificationStatus? status})
  Future<void> approveUser(String userId)
  Future<void> rejectUser(String userId, String reason)
  Future<void> updateUserRole(String userId, UserRole role)
}
```

**예상 소요**: 1시간

---

#### 1.3 ReferralCode Repository 구현 (1시간)
**파일**: `lib/src/features/auth/data/repositories/referral_code_repository.dart`

**구현 내용**:
```dart
class ReferralCodeRepository {
  Future<List<ReferralCode>> getMyReferralCodes()
  Future<ReferralCode> createReferralCode({required String schoolName, int maxUses = 5})
  Future<ReferralCode?> validateCode(String code)
  Future<void> useReferralCode(String codeId, String userId)
}
```

**예상 소요**: 1시간

---

#### 1.4 Classroom Repository 구현 (1.5시간)
**파일**: `lib/src/features/classroom/data/repositories/classroom_repository.dart`

**구현 내용**:
```dart
class ClassroomRepository {
  Future<List<Classroom>> getClassrooms({bool activeOnly = true})
  Future<Classroom?> getClassroom(String id)
  Future<Classroom> createClassroom({required String name, String? accessCode, ...})
  Future<void> updateClassroom(String id, {...})
  Future<void> deleteClassroom(String id)
  Future<bool> verifyAccessCode(String classroomId, String code)
}
```

**예상 소요**: 1.5시간

---

**Phase 1-A 완료 기준**: 회원가입 → 로그인 → 홈 → 로그아웃 플로우 완전 작동

---

### Phase 1-B: 관리자 승인 시스템 (5-10시간)

**목표**: 관리자 대시보드 구축 + 사용자 승인/반려

#### 1.5 관리자 라우트 추가 (0.5시간)
**파일**: `lib/src/core/router/router.dart`

**예상 소요**: 0.5시간

---

#### 1.6 승인 대기 목록 화면 (2시간)
**파일**: `lib/src/features/auth/presentation/admin_approvals_screen.dart`

**UI 구성**:
1. 승인 대기 중인 교사 목록
2. 재직증명서 썸네일
3. 승인/반려 버튼
4. 상태 탭

**예상 소요**: 2시간

---

#### 1.7 재직증명서 확인 UI (1시간)
**파일**: `lib/src/features/auth/presentation/widgets/document_viewer.dart`

**예상 소요**: 1시간

---

#### 1.8 사용자 관리 화면 (1.5시간)
**파일**: `lib/src/features/auth/presentation/admin_users_screen.dart`

**예상 소요**: 1.5시간

---

**Phase 1-B 완료 기준**: 관리자 로그인 → 대기 목록 확인 → 승인 → 일반 사용자 로그인 가능

---

### Phase 1-C: 추가 인증 기능 (10-15시간)

**목표**: 프로필 관리 + 추천인 코드 UI + 비밀번호 재설정

#### 1.9 프로필 화면 (2시간)
**파일**: `lib/src/features/auth/presentation/profile_screen.dart`

**예상 소요**: 2시간

---

#### 1.10 프로필 수정 화면 (1.5시간)
**파일**: `lib/src/features/auth/presentation/edit_profile_screen.dart`

**예상 소요**: 1.5시간

---

#### 1.11 비밀번호 재설정 화면 (1.5시간)
**파일**: `lib/src/features/auth/presentation/reset_password_screen.dart`

**예상 소요**: 1.5시간

---

#### 1.12 내 추천인 코드 화면 (2시간)
**파일**: `lib/src/features/auth/presentation/my_referral_codes_screen.dart`

**예상 소요**: 2시간

---

#### 1.13 코드 생성 다이얼로그 (1시간)
**파일**: `lib/src/features/auth/presentation/widgets/create_referral_dialog.dart`

**예상 소요**: 1시간

---

**Phase 1-C 완료 기준**: 사용자가 프로필 확인 → 수정 → 추천인 코드 생성 가능

---

### Phase 2-A: 예약 시스템 시작 (15-20시간)

**목표**: 교실 목록 + 예약 생성 UI

#### 1.14 Reservation Repository 구현 (2시간)
**파일**: `lib/src/features/reservation/data/repositories/reservation_repository.dart`

**예상 소요**: 2시간

---

#### 1.15 교실 목록 화면 (1.5시간)
**파일**: `lib/src/features/classroom/presentation/classroom_list_screen.dart`

**예상 소요**: 1.5시간

---

#### 1.16 비밀번호 입력 다이얼로그 (0.5시간)
**파일**: `lib/src/features/classroom/presentation/widgets/access_code_dialog.dart`

**예상 소요**: 0.5시간

---

#### 1.17 교실 상세 화면 (1시간)
**파일**: `lib/src/features/classroom/presentation/classroom_detail_screen.dart`

**예상 소요**: 1시간

---

#### 1.18 예약 생성 바텀시트 (2시간)
**파일**: `lib/src/features/reservation/presentation/widgets/create_reservation_sheet.dart`

**예상 소요**: 2시간

---

#### 1.19 내 예약 내역 화면 (1.5시간)
**파일**: `lib/src/features/reservation/presentation/my_reservations_screen.dart`

**예상 소요**: 1.5시간

---

#### 1.20 교실 관리 화면 (1.5시간)
**파일**: `lib/src/features/classroom/presentation/admin_classroom_screen.dart`

**예상 소요**: 1.5시간

---

#### 1.21 교실 등록/수정 폼 (1시간)
**파일**: `lib/src/features/classroom/presentation/classroom_form_screen.dart`

**예상 소요**: 1시간

---

**Phase 2-A 완료 기준**:
- 일반 사용자: 교실 목록 → 상세 → 예약 생성 → 내 예약 확인 → 취소
- 관리자: 교실 생성 → 비밀번호 설정 → 공지사항 입력

---

## 📋 전체 타임라인 요약

| Phase | 시간 | 주요 산출물 | 배포 가능 여부 |
|-------|------|------------|--------------|
| **Phase 1-A** | 0-5h | Repository 4개, Provider 연결 | ❌ (내부 로직만) |
| **Phase 1-B** | 5-10h | 관리자 대시보드, 승인 시스템 | ✅ (관리자 기능) |
| **Phase 1-C** | 10-15h | 프로필, 추천인 코드 UI | ✅ (사용자 관리) |
| **Phase 2-A** | 15-20h | 교실 목록, 예약 생성, 내 예약 | ✅ (MVP 완성) |

---

## 🎯 우선순위 근거

### 1. Phase 1-A: 핵심 백엔드 연동 (최우선)
**이유**: 현재 UI는 완성되었지만 "빈 껍데기" 상태. Repository 없이는 어떤 기능도 실제로 작동하지 않음.

### 2. Phase 1-B: 관리자 승인 시스템 (긴급)
**이유**: 관리자가 승인하지 않으면 일반 사용자는 아무것도 못 함.

### 3. Phase 1-C: 추가 인증 기능 (사용자 경험)
**이유**: 사용자가 프로필을 관리하고 추천인 코드를 생성할 수 있어야 함.

### 4. Phase 2-A: 예약 시스템 시작 (핵심 가치)
**이유**: "예약 시스템"이 이 앱의 존재 이유. 사용자가 즉시 느끼는 가치.

---

## 🚀 완료 후 상태 (20시간 후)

### 달성 가능한 기능

#### 일반 사용자 플로우
1. 회원가입 → ✅
2. 관리자 승인 대기 → ✅
3. 로그인 → ✅
4. 프로필 확인 및 수정 → ✅
5. 추천인 코드 생성 → ✅
6. 교실 목록 조회 → ✅
7. 예약 생성 → ✅
8. 내 예약 확인 → ✅
9. 예약 취소 → ✅

#### 관리자 플로우
1. 승인 대기 사용자 목록 → ✅
2. 재직증명서 확인 → ✅
3. 승인/반려 → ✅
4. 교실 생성/수정 → ✅

---

## ❌ 20시간 내 구현 불가능한 기능

- 시간표 그리드 UI (복잡한 위젯, 5시간 추가 소요)
- Realtime 구독 (3시간)
- 교육청 이메일 인증 (4시간)
- Audit Log UI (4시간)
- 알림 시스템 (6시간)

---

**작성자**: Claude Code Agent
**최종 업데이트**: 2026-01-04
