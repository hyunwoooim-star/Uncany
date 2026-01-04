# 🔒 개인정보 보호 및 보안 정책

> **중요**: 이 프로젝트는 실제 운영을 목표로 하며, 한국 개인정보 보호법을 준수합니다.

**최종 업데이트**: 2026-01-04

---

## 📋 목차
1. [법적 근거](#법적-근거)
2. [수집하는 개인정보](#수집하는-개인정보)
3. [데이터 보호 조치](#데이터-보호-조치)
4. [보안 아키텍처](#보안-아키텍처)
5. [개인정보 처리 방침](#개인정보-처리-방침)
6. [규정 준수 체크리스트](#규정-준수-체크리스트)

---

## ⚖️ 법적 근거

### 준수 법령
- **개인정보 보호법** (법률 제18583호)
- **정보통신망 이용촉진 및 정보보호 등에 관한 법률**
- **클라우드컴퓨팅 발전 및 이용자 보호에 관한 법률**

### 개인정보처리자로서의 의무
- 개인정보 처리방침 공개
- 정보주체의 권리 보장 (열람, 정정, 삭제 요구권)
- 개인정보 유출 시 72시간 이내 신고

---

## 📊 수집하는 개인정보

### 필수 정보
| 항목 | 목적 | 보유 기간 | 법적 근거 |
|------|------|-----------|-----------|
| 이름 | 사용자 식별 | 탈퇴 시까지 | 개인정보보호법 제15조 |
| 학교명 | 서비스 제공 | 탈퇴 시까지 | 이용약관 동의 |
| 교육청 이메일 (선택) | 본인 인증 | 인증 완료 후 삭제 가능 | 동의 |

### 수집하지 않는 정보
- ❌ 주민등록번호
- ❌ 운전면허번호
- ❌ 여권번호
- ❌ 외국인등록번호
- ❌ 신용카드 정보
- ❌ 계좌 정보

### 민감정보 처리
| 정보 | 처리 방식 | 보관 기간 |
|------|-----------|-----------|
| **재직증명서 이미지** | 암호화 저장 → **승인 후 즉시 삭제** | 최대 7일 |
| 주민등록번호 (문서 내) | **서버 저장 금지**, 클라이언트 마스킹 요구 | 저장 안 함 |

---

## 🛡️ 데이터 보호 조치

### 1. 암호화

#### 전송 구간 암호화 (TLS)
```
클라이언트 ←→ [TLS 1.3] ←→ Supabase
- 모든 API 통신 HTTPS 강제
- Certificate Pinning (모바일 앱)
```

#### 저장 구간 암호화
```sql
-- Supabase Storage: 서버 측 암호화 (AES-256)
CREATE POLICY "encrypted_storage" ON storage.objects
FOR ALL USING (bucket_id = 'verification-documents');

-- 비밀번호: Argon2id 해싱
-- 이메일: 평문 (검색 필요)
-- 재직증명서: SSE-S3 (Server-Side Encryption)
```

#### 민감 데이터 암호화 레벨
| 데이터 | 암호화 방식 | 키 관리 |
|--------|-------------|---------|
| 비밀번호 | Argon2id (단방향) | N/A |
| 재직증명서 | AES-256 (Supabase Storage) | AWS KMS |
| 데이터베이스 | PostgreSQL TDE | Supabase 관리 |

---

### 2. 접근 제어 (Row Level Security)

```sql
-- 예시: 사용자는 자신의 데이터만 조회 가능
CREATE POLICY "users_select_own"
ON users FOR SELECT
USING (auth.uid() = id);

-- 관리자만 인증 문서 조회 가능
CREATE POLICY "admin_only_verification"
ON users FOR SELECT
USING (
  auth.jwt() ->> 'role' = 'admin'
  AND verification_status = 'pending'
);
```

---

### 3. 데이터 최소화 원칙

#### 수집 단계
```dart
// Good: 필요한 정보만 수집
final user = User(
  name: name,
  schoolName: schoolName,
);

// Bad: 불필요한 정보 수집
// birthDate, phoneNumber, address → 수집하지 않음
```

#### 보관 단계
```dart
// 재직증명서: 승인 즉시 삭제
Future<void> approveUser(String userId) async {
  await supabase.from('users').update({
    'verification_status': 'approved',
  }).eq('id', userId);

  // 문서 즉시 삭제
  await supabase.storage
      .from('verification-documents')
      .remove(['$userId/certificate.jpg']);
}
```

---

### 4. 로그 관리

#### 로그 수집 정책
```dart
// 수집하는 로그
- 인증 시도 (성공/실패)
- 예약 생성/취소
- 관리자 작업 (승인/반려)

// 수집하지 않는 로그
- ❌ IP 주소 (개인정보에 해당)
- ❌ 디바이스 ID
- ❌ 위치 정보
```

#### 로그 보관 기간
| 로그 유형 | 보관 기간 | 사유 |
|-----------|-----------|------|
| 인증 로그 | 6개월 | 보안 감사 |
| 예약 이력 | 1년 | 서비스 개선 |
| 에러 로그 | 3개월 | 디버깅 |

---

## 🏗️ 보안 아키텍처

### 계층별 보안

```
┌─────────────────────────────────┐
│  클라이언트 (Flutter)            │
│  - Input 검증                   │
│  - 민감 정보 마스킹              │
│  - Certificate Pinning          │
└─────────────────────────────────┘
           ↓ HTTPS (TLS 1.3)
┌─────────────────────────────────┐
│  Supabase Edge Functions        │
│  - API Rate Limiting            │
│  - JWT 검증                     │
│  - 비즈니스 로직 검증            │
└─────────────────────────────────┘
           ↓
┌─────────────────────────────────┐
│  PostgreSQL                     │
│  - Row Level Security (RLS)    │
│  - 데이터 암호화 (TDE)          │
│  - Audit Log                    │
└─────────────────────────────────┘
```

### API 보안

#### Rate Limiting
```typescript
// Supabase Edge Function 예시
export async function handler(req: Request) {
  // IP 기반 Rate Limiting
  const limiter = new RateLimiter({
    points: 10, // 요청 수
    duration: 60, // 초
  });

  await limiter.consume(clientIp);

  // ... 비즈니스 로직
}
```

#### JWT 검증
```dart
// 모든 API 요청에 JWT 포함
final response = await supabase
  .from('reservations')
  .select()
  .headers({'Authorization': 'Bearer $token'});
```

---

## 📜 개인정보 처리 방침

### 필수 고지 사항

앱 내 "개인정보 처리방침" 페이지에 다음 내용 명시:

1. **개인정보의 수집 및 이용 목적**
   - 회원 관리 및 본인 인증
   - 교실 예약 서비스 제공
   - 공지사항 전달

2. **수집하는 개인정보 항목**
   - 필수: 이름, 학교명
   - 선택: 교육청 이메일

3. **개인정보의 보유 및 이용 기간**
   - 회원 탈퇴 시까지
   - 재직증명서: 승인 후 즉시 삭제

4. **개인정보의 제3자 제공**
   - **제공하지 않음**

5. **개인정보 처리 위탁**
   - 수탁업체: Supabase (미국)
   - 위탁 업무: 클라우드 서버 운영
   - [Supabase Privacy Policy](https://supabase.com/privacy)

6. **정보주체의 권리**
   - 열람 요구권
   - 정정·삭제 요구권
   - 처리정지 요구권

7. **개인정보 보호책임자**
   ```
   이름: [담당자명]
   이메일: privacy@uncany.com
   ```

---

## ✅ 규정 준수 체크리스트

### 개발 단계
- [x] 개인정보 영향평가 (PIA) 문서 작성
- [x] 데이터 최소화 원칙 적용
- [x] 암호화 구현 (전송/저장)
- [x] 접근 제어 (RLS) 설정
- [ ] 개인정보 처리방침 UI 구현
- [ ] 이용약관 UI 구현

### 운영 전
- [ ] 개인정보 보호책임자 지정
- [ ] 개인정보 처리방침 게시
- [ ] 이용약관 게시
- [ ] 개인정보 유출 대응 매뉴얼 작성
- [ ] 개인정보 파기 절차 수립

### 운영 중
- [ ] 정기 보안 점검 (분기별)
- [ ] 개인정보 처리 현황 기록
- [ ] 사용자 권리 요청 처리 시스템
- [ ] 개인정보 유출 모니터링

---

## 🚨 개인정보 유출 시 대응

### 1단계: 탐지 (Detection)
```
- 이상 접근 감지 (Supabase 로그)
- 사용자 신고 접수
```

### 2단계: 차단 (Containment)
```
- 즉시 해당 계정 정지
- API 키 재발급
- 영향 범위 파악
```

### 3단계: 신고 (Notification)
```
- 72시간 이내 개인정보보호위원회 신고
- 영향받은 사용자에게 이메일/앱 푸시 알림
```

### 4단계: 복구 (Recovery)
```
- 취약점 패치
- 보안 강화
- 재발 방지 대책 수립
```

---

## 📞 문의

개인정보 관련 문의:
- 이메일: privacy@uncany.com
- 개인정보 보호책임자: [담당자명]

---

**이 문서는 프로젝트의 개인정보 보호 정책을 정의하며, 모든 개발자는 이를 준수해야 합니다.**
