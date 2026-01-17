# Uncany Production 배포 체크리스트

> 작성일: 2026-01-17
> 작성자: Claude (자체 검토)
> 버전: v0.3.5

---

## 📋 Executive Summary

**전체 평가: 준비도 85%** - Production 배포 가능하나, 아래 항목 점검 필요

### 강점
- ✅ 보안 아키텍처 우수 (Advisory Lock + Exclusion Constraint + RLS)
- ✅ Feature-first 폴더 구조 적절
- ✅ Riverpod + Go Router 조합 표준적
- ✅ 에러 처리 한글화 완료
- ✅ N+1 쿼리 최적화 완료

### 개선 필요
- ⚠️ 환경 변수 분리 미흡
- ⚠️ Rate Limiting 미구현
- ⚠️ 에러 모니터링 미구현 (Sentry 등)
- ⚠️ 알림 시스템 미구현

---

## 1. 아키텍처 검토 ✅

### 1.1 Riverpod + Go Router 조합
**평가: 적절함**

```
장점:
- Riverpod: 타입 안전, 테스트 용이, 의존성 주입 간편
- Go Router: 선언적 라우팅, deep link 지원, 인증 guard 패턴

현재 구현 상태:
- router.dart: redirect 로직에서 인증/권한 체크 잘 되어있음
- auth_provider.dart: Riverpod로 인증 상태 관리 적절함
```

**개선 제안:**
1. `debugLogDiagnostics: true` → Production에서는 `false`로 변경
2. 라우터 리다이렉트 로직이 복잡해지면 별도 클래스로 분리 고려

### 1.2 Feature-first 폴더 구조
**평가: 적절함**

```
lib/src/
├── core/           # 공통 인프라 ✅
├── features/       # 기능별 분리 ✅
│   ├── auth/
│   ├── reservation/
│   ├── classroom/
│   └── ...
└── shared/         # 공유 위젯 ✅
```

각 feature 내부 구조도 `data/domain/presentation` 패턴으로 잘 나눠져 있음.

---

## 2. RLS 보안 검토 ✅

### 2.1 users UPDATE 정책 (role 변경 방지)
```sql
WITH CHECK (
  id = auth.uid()
  AND (role = (SELECT role FROM users WHERE id = auth.uid()))
)
```

**평가: 안전함**

- 본인 ID만 수정 가능
- role 변경 시 기존 role과 동일해야 함 (자가 권한 상승 차단)

**추가 강화 제안:**
```sql
-- verification_status도 변경 불가하게 추가
AND (verification_status = (SELECT verification_status FROM users WHERE id = auth.uid()))
```

### 2.2 예약 동시성 제어
**평가: 매우 안전함 (2중 방어)**

1. **Advisory Lock**: 트랜잭션 레벨 배타적 락
2. **Exclusion Constraint**: 물리적 시간 중복 차단
3. **periods && 배열 겹침**: 교시 충돌 검사

```sql
-- Advisory Lock (1차 방어)
PERFORM pg_advisory_xact_lock(lock_key);

-- Exclusion Constraint (2차 방어)
EXCLUDE USING GIST (
  classroom_id WITH =,
  tstzrange(start_time, end_time, '[)') WITH &&
) WHERE (deleted_at IS NULL);
```

### 2.3 SECURITY DEFINER 함수 주의사항

현재 사용 중인 함수:
- `is_admin()`: 관리자 확인
- `get_conflicting_periods()`: 충돌 조회

**주의:**
- SECURITY DEFINER 함수는 작성자 권한으로 실행됨
- SQL Injection 가능성 차단 필수
- 현재 구현은 안전함 (파라미터 바인딩 사용)

---

## 3. Production 배포 체크리스트 📋

### 3.1 Supabase 설정

- [ ] **Production 프로젝트 생성**
  - 새 Supabase 프로젝트 생성 (Staging과 분리)
  - Region: Northeast Asia (ap-northeast-1) 권장

- [ ] **환경 변수 분리**
  ```dart
  // environment.dart 수정
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  ```

- [ ] **RLS 정책 확인**
  - Dashboard > Authentication > Policies
  - 모든 테이블에 RLS 활성화 확인

- [ ] **Database Backup 설정**
  - Pro Plan: Point-in-time Recovery 활성화
  - 일일 백업 스케줄 확인

### 3.2 Firebase Hosting 설정

- [ ] **Production 채널 생성**
  ```bash
  firebase hosting:channel:create production
  ```

- [ ] **SSL 인증서 확인**
  - 자동 발급됨 (Let's Encrypt)
  - Custom domain 사용 시 DNS 설정

- [ ] **캐시 정책 설정**
  ```json
  // firebase.json
  {
    "hosting": {
      "headers": [{
        "source": "**/*.@(js|css)",
        "headers": [{
          "key": "Cache-Control",
          "value": "max-age=31536000"
        }]
      }]
    }
  }
  ```

### 3.3 GitHub Actions CI/CD

- [ ] **Production Secrets 설정**
  - `SUPABASE_URL_PROD`
  - `SUPABASE_ANON_KEY_PROD`
  - `FIREBASE_SERVICE_ACCOUNT_PROD`

- [ ] **Production 배포 워크플로우**
  - main 브랜치 → Production 자동 배포
  - 태그 기반 배포 고려 (v1.0.0)

### 3.4 보안 체크리스트

- [ ] **API Key 노출 확인**
  - `.env` 파일 `.gitignore`에 포함 확인
  - 빌드된 JS에 민감 정보 없는지 확인

- [ ] **CORS 설정**
  - Supabase Dashboard > API Settings
  - 허용 도메인만 등록

- [ ] **Rate Limiting** (미구현 - 구현 권장)
  - Supabase Edge Functions에서 구현
  - 또는 Firebase Functions 사용

### 3.5 모니터링 (권장)

- [ ] **에러 모니터링**
  - Sentry 또는 Firebase Crashlytics 연동
  - `AppLogger` 확장하여 원격 로깅

- [ ] **성능 모니터링**
  - Firebase Performance 연동
  - Supabase Dashboard 쿼리 성능 확인

---

## 4. 알림 시스템 구현 방향 🔔

### 추천: FCM + Supabase Realtime 병행

| 요구사항 | FCM | Supabase Realtime |
|---------|-----|-------------------|
| 앱 꺼져있을 때 알림 | ✅ | ❌ |
| 실시간 UI 업데이트 | ❌ | ✅ |
| 웹 지원 | ✅ | ✅ |
| 구현 복잡도 | 중 | 하 |

### 구현 제안

```
1. FCM (Push Notification)
   - 예약 확인/취소 알림
   - 관리자 승인 알림
   - Supabase Edge Functions에서 FCM API 호출

2. Supabase Realtime (In-app)
   - 예약 현황 실시간 업데이트
   - 이미 reservation_realtime_provider.dart 존재
   - 확장하여 활용
```

### FCM 구현 순서

```
1. Firebase Console에서 FCM 설정
2. flutter pub add firebase_messaging
3. Supabase Edge Function 작성 (예약 생성 시 FCM 호출)
4. 클라이언트에서 FCM 토큰 저장
5. Supabase users 테이블에 fcm_token 컬럼 추가
```

---

## 5. 추가 개선점 🔧

### 5.1 높은 우선순위

| 항목 | 현황 | 제안 |
|-----|------|------|
| debugLogDiagnostics | true | Production에서 false |
| 에러 모니터링 | 없음 | Sentry 연동 |
| Rate Limiting | 없음 | Edge Function에서 구현 |

### 5.2 중간 우선순위

| 항목 | 현황 | 제안 |
|-----|------|------|
| 로딩 스켈레톤 | 부분 적용 | 전체 화면에 적용 |
| 오프라인 지원 | 없음 | 로컬 캐시 고려 |
| 접근성 | 기본 | Semantics 위젯 추가 |

### 5.3 낮은 우선순위

| 항목 | 현황 | 제안 |
|-----|------|------|
| 다크 모드 | 없음 | ThemeData 확장 |
| 다국어 | 한국어만 | 당분간 유지 |
| 앱 아이콘 | 기본 | 커스텀 아이콘 |

---

## 6. 마이그레이션 체크리스트 📦

### Staging → Production 데이터 이관

```
1. 스키마 이관
   supabase db dump --schema-only > schema.sql

2. RLS 정책 이관
   supabase db dump --role-only > roles.sql

3. Edge Functions 배포
   supabase functions deploy --project-ref <prod-ref>

4. 테스트 데이터는 이관하지 않음 (새로 시작)
```

### 롤백 계획

```
1. 이전 버전 태그로 Firebase 롤백
   firebase hosting:rollback

2. Supabase 마이그레이션 롤백
   supabase db reset (주의: 데이터 손실)

3. 점진적 롤아웃 권장
   - 먼저 내부 테스터만 접근
   - 안정화 후 전체 오픈
```

---

## 7. 최종 체크리스트 ✅

### 배포 전 필수

- [ ] 모든 마이그레이션 적용 완료
- [ ] RLS 정책 테스트 완료
- [ ] E2E 테스트 통과
- [ ] 환경 변수 Production 값 설정
- [ ] debugLogDiagnostics: false
- [ ] Firebase 프로젝트 Production 연결

### 배포 후 확인

- [ ] 로그인/회원가입 동작 확인
- [ ] 예약 생성/취소 동작 확인
- [ ] 관리자 기능 동작 확인
- [ ] SSL 인증서 유효 확인
- [ ] 모니터링 대시보드 확인

---

## 8. 결론

**Uncany는 Production 배포 준비가 잘 되어있습니다.**

핵심 보안 로직(RLS, Advisory Lock, Exclusion Constraint)이 잘 구현되어 있고,
아키텍처도 표준적인 패턴을 따르고 있습니다.

위 체크리스트의 "높은 우선순위" 항목만 완료하면 안전하게 배포할 수 있습니다.

---

*이 문서는 Claude가 코드 검토 후 작성했습니다.*
*Gemini 피드백 수렴 시 업데이트 예정*
