# 📈 Uncany 확장 전략

> **목표**: 사용자 증가에 따른 성능 저하 없이 안정적인 서비스 제공

**최종 업데이트**: 2026-01-04

---

## 📋 목차
1. [현재 아키텍처](#현재-아키텍처)
2. [예상 성장 시나리오](#예상-성장-시나리오)
3. [단계별 확장 계획](#단계별-확장-계획)
4. [성능 최적화 전략](#성능-최적화-전략)
5. [모니터링 및 알림](#모니터링-및-알림)
6. [비용 최적화](#비용-최적화)

---

## 🏗️ 현재 아키텍처

### Phase 1: MVP (0 ~ 1,000명)

```
Flutter App (Web + Mobile)
        ↓
   Supabase Free Tier
   ├─ PostgreSQL (500MB)
   ├─ Storage (1GB)
   ├─ Auth
   └─ Edge Functions
```

**예상 비용**: $0/월 (Free Tier)

**한계**:
- DB: 500MB
- 동시 접속: ~50명
- API 요청: 50,000/월

---

## 📊 예상 성장 시나리오

### 시나리오 1: 단일 학교 (100명)
```
- 교사 수: 100명
- 일일 활성 사용자: 30명
- 예약 수: ~50개/일
- DB 사용량: ~10MB
```
**상태**: ✅ Free Tier로 충분

---

### 시나리오 2: 지역 확산 (1,000명)
```
- 학교 수: 10개
- 교사 수: 1,000명
- 일일 활성 사용자: 300명
- 예약 수: ~500개/일
- DB 사용량: ~100MB
```
**상태**: ✅ Free Tier → ⚠️ Pro Tier 고려

---

### 시나리오 3: 전국 확산 (10,000명)
```
- 학교 수: 100개
- 교사 수: 10,000명
- 일일 활성 사용자: 3,000명
- 예약 수: ~5,000개/일
- DB 사용량: ~1GB
```
**상태**: 🔥 **확장 필수**

---

### 시나리오 4: 대규모 (100,000명)
```
- 학교 수: 1,000개
- 교사 수: 100,000명
- 일일 활성 사용자: 30,000명
- 예약 수: ~50,000개/일
- DB 사용량: ~10GB
```
**상태**: 🚀 **전면 아키텍처 개편**

---

## 🚀 단계별 확장 계획

### Stage 1: Free Tier (0 ~ 1,000명)
**목표**: MVP 검증, 초기 사용자 확보

**인프라**:
```yaml
Supabase Free Tier:
  - PostgreSQL: 500MB
  - Storage: 1GB
  - Bandwidth: 2GB
```

**모니터링**:
- Supabase 대시보드 (기본)
- Google Analytics (웹)
- Firebase Crashlytics (앱)

**비용**: $0/월

---

### Stage 2: Pro Tier (1,000 ~ 10,000명)
**목표**: 안정적 서비스, 지역 확산

**인프라 업그레이드**:
```yaml
Supabase Pro Tier ($25/월):
  - PostgreSQL: 8GB
  - Storage: 100GB
  - Bandwidth: 50GB
  - Daily Backups
  - Email Support
```

**성능 최적화**:
1. **데이터베이스 인덱싱**
   ```sql
   -- 자주 조회하는 쿼리 최적화
   CREATE INDEX idx_reservations_teacher
   ON reservations(teacher_id, start_time)
   WHERE deleted_at IS NULL;

   CREATE INDEX idx_reservations_classroom
   ON reservations(classroom_id, start_time)
   WHERE deleted_at IS NULL;
   ```

2. **쿼리 최적화**
   ```dart
   // Bad: N+1 문제
   for (var reservation in reservations) {
     final classroom = await getClassroom(reservation.classroomId);
   }

   // Good: JOIN 사용
   final reservations = await supabase
     .from('reservations')
     .select('*, classroom:classrooms(*)')
     .eq('deleted_at', null);
   ```

3. **캐싱 도입**
   ```dart
   // 자주 변경되지 않는 데이터 캐싱
   final cachedClassrooms = await cache.get('classrooms') ??
     await supabase.from('classrooms').select();
   ```

**비용**: ~$50/월 (Supabase Pro + CDN)

---

### Stage 3: Team Tier + CDN (10,000 ~ 50,000명)
**목표**: 전국 확산, 빠른 응답 속도

**인프라 업그레이드**:
```yaml
Supabase Team Tier ($599/월):
  - PostgreSQL: Dedicated Instance
  - Connection Pooling
  - Read Replicas (읽기 전용 복제본)
  - Priority Support

CDN (Cloudflare):
  - Static Assets 캐싱
  - DDoS 방어
  - 전 세계 엣지 서버
```

**아키텍처 개선**:
```
Flutter App
     ↓
[Cloudflare CDN] → Static Assets
     ↓
Supabase Load Balancer
     ├─ Master (Write)
     └─ Replicas (Read) × 2
         ↓
    PostgreSQL
```

**최적화**:
1. **Read Replica 활용**
   ```dart
   // 쓰기: Master
   await supabase.from('reservations').insert(newReservation);

   // 읽기: Replica (부하 분산)
   final reservations = await supabase
     .from('reservations')
     .select()
     .withReplica(); // 읽기 전용 복제본 사용
   ```

2. **Connection Pooling**
   - 동시 접속 수 증가 대응
   - DB 연결 재사용

3. **이미지 최적화**
   ```dart
   // 썸네일 자동 생성
   await supabase.storage
     .from('photos')
     .upload('image.jpg', file, transform: {
       'width': 300,
       'quality': 80,
     });
   ```

**비용**: ~$700/월

---

### Stage 4: Enterprise (50,000명+)
**목표**: 대규모 안정성, 고가용성

**아키텍처 전면 개편**:
```
Flutter App
     ↓
[Cloudflare CDN]
     ↓
[API Gateway - Kong]
     ↓
Kubernetes Cluster
├─ Auth Service (Supabase Auth)
├─ API Service (Node.js/Deno)
├─ Reservation Service
└─ Notification Service
     ↓
Database Layer
├─ PostgreSQL (Primary)
├─ PostgreSQL (Standby)
└─ Redis (Cache)
```

**고가용성 (HA)**:
- Multi-AZ 배포
- Auto Scaling
- Failover 자동화

**데이터베이스 샤딩**:
```sql
-- 학교별로 데이터 분할
shard_1: schools 1-100
shard_2: schools 101-200
...
```

**비용**: ~$3,000/월

---

## ⚡ 성능 최적화 전략

### 1. 프론트엔드 최적화

#### Flutter Web
```dart
// Code Splitting
// 초기 로딩 속도 향상
flutter build web --split-debug-info

// Tree Shaking
// 사용하지 않는 코드 제거
flutter build web --release
```

#### 이미지 최적화
```dart
// Progressive Image Loading
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);
```

#### 리스트 가상화
```dart
// 긴 리스트 성능 개선
ListView.builder(
  itemCount: reservations.length,
  itemBuilder: (context, index) {
    // 화면에 보이는 아이템만 렌더링
    return ReservationCard(reservations[index]);
  },
);
```

---

### 2. 백엔드 최적화

#### 쿼리 최적화
```sql
-- Bad: 전체 스캔
SELECT * FROM reservations
WHERE DATE(start_time) = '2026-01-04';

-- Good: 인덱스 활용
SELECT * FROM reservations
WHERE start_time >= '2026-01-04 00:00:00'
  AND start_time < '2026-01-05 00:00:00'
  AND deleted_at IS NULL;
```

#### Pagination
```dart
// 무한 스크롤
final reservations = await supabase
  .from('reservations')
  .select()
  .range(page * pageSize, (page + 1) * pageSize - 1);
```

#### Batch 처리
```dart
// Bad: N번 쿼리
for (var id in ids) {
  await deleteReservation(id);
}

// Good: 1번 쿼리
await supabase
  .from('reservations')
  .delete()
  .in_('id', ids);
```

---

### 3. 캐싱 전략

#### 계층별 캐싱
```
[Client Cache] → 1분
     ↓
[CDN Cache] → 5분
     ↓
[Application Cache] → 15분
     ↓
[Database]
```

#### 캐시 무효화
```dart
// 예약 생성 시 캐시 삭제
await createReservation(reservation);
await cache.delete('reservations:$classroomId');
```

---

## 📊 모니터링 및 알림

### 핵심 지표 (KPI)

| 지표 | 목표 | 알림 기준 |
|------|------|-----------|
| **응답 시간** | < 200ms | > 500ms |
| **에러율** | < 0.1% | > 1% |
| **DB 사용량** | < 80% | > 90% |
| **동시 접속** | - | > 임계값 |
| **API 요청** | - | > 임계값 |

### 모니터링 도구

#### Stage 1-2
- Supabase Dashboard (기본)
- Google Analytics
- Firebase Crashlytics

#### Stage 3-4
- **APM**: Datadog / New Relic
- **로그**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **알림**: PagerDuty / Slack

---

## 💰 비용 최적화

### 단계별 예상 비용

| Stage | 사용자 수 | 월 비용 | 사용자당 비용 |
|-------|-----------|---------|---------------|
| 1 | 0 ~ 1K | $0 | $0 |
| 2 | 1K ~ 10K | $50 | $0.005 |
| 3 | 10K ~ 50K | $700 | $0.014 |
| 4 | 50K+ | $3,000 | $0.06 |

### 비용 절감 전략

1. **Reserved Instances** (장기 할인)
2. **Spot Instances** (비핵심 워크로드)
3. **데이터 압축** (저장 공간 절약)
4. **Auto Scaling** (필요한 만큼만 사용)

---

## 🔄 마이그레이션 계획

### Supabase Free → Pro

**트리거**: DB 사용량 > 400MB 또는 사용자 > 800명

**절차**:
1. Supabase Pro 플랜 업그레이드 (다운타임 없음)
2. 백업 설정 활성화
3. 모니터링 강화

**소요 시간**: 1시간

---

### Supabase Pro → Team

**트리거**: 동시 접속 > 200명 또는 응답 시간 > 500ms

**절차**:
1. Read Replica 생성
2. Connection Pooling 설정
3. 애플리케이션 코드 수정 (Replica 활용)
4. 단계적 전환 (Canary Deployment)

**소요 시간**: 1주

---

### Self-Hosted 전환

**트리거**: 비용 > $1,000/월 또는 특수 요구사항

**절차**:
1. AWS/GCP 인프라 구축
2. PostgreSQL HA 클러스터 설정
3. 데이터 마이그레이션 (pgdump/pg_restore)
4. DNS 전환
5. 모니터링 이전

**소요 시간**: 1개월

---

## ✅ 단계별 체크리스트

### Stage 1 → Stage 2 전환 시
- [ ] DB 사용량 80% 도달 시 알림 설정
- [ ] 백업 자동화 확인
- [ ] 인덱스 최적화 완료
- [ ] 캐싱 레이어 도입

### Stage 2 → Stage 3 전환 시
- [ ] Read Replica 테스트
- [ ] CDN 설정 완료
- [ ] APM 도입
- [ ] 부하 테스트 수행

### Stage 3 → Stage 4 전환 시
- [ ] 마이크로서비스 아키텍처 설계
- [ ] Kubernetes 클러스터 구축
- [ ] 데이터베이스 샤딩 전략 수립
- [ ] DR (Disaster Recovery) 계획 수립

---

## 🎯 성공 지표

### 기술 지표
- 99.9% 가용성 (연간 다운타임 < 8.76시간)
- 응답 시간 P95 < 300ms
- 에러율 < 0.1%

### 비즈니스 지표
- 사용자 만족도 > 4.5/5.0
- 일일 활성 사용자 (DAU) 성장률 > 10%/월
- 이탈률 < 5%/월

---

**이 확장 전략은 사용자 증가에 따라 유연하게 조정되며, 정기적으로 검토 및 업데이트됩니다.**
