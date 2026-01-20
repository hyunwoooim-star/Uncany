# 🎯 v0.4.0 작업 계획서

> **작성일**: 2026-01-20
> **작성자**: Claude
> **목적**: Gemini 피드백 요청

---

## 📊 현재 상태 요약

### v0.3.9 완료 ✅

| 지표 | Before | After | 변화 |
|------|--------|-------|------|
| home_screen.dart | 1602줄 | 293줄 | **-82%** |
| 테스트 케이스 | 37개 | 80개 | **+116%** |
| AsyncNotifier | 0개 | 4개 | +4 |
| CI 통과율 | 가변 | 100% | 안정화 |

### 완료된 리팩토링
- ✅ StatusBadge 공통 위젯 추출
- ✅ RoomTypeUtils 유틸리티화
- ✅ home_screen.dart God Object 해체
- ✅ AsyncNotifier 패턴 도입 (4개)
- ✅ Widget 테스트 17개 추가

---

## 🚀 다음 단계 계획

### Phase 4: Staging 검증 (즉시)

**목표**: v0.3.9 변경사항 실제 환경 검증

| # | 작업 | 설명 | 예상 소요 |
|---|------|------|----------|
| 4-1 | 마이그레이션 확인 | `007_fix_user_email_sync.sql` 적용 확인 | 짧음 |
| 4-2 | 인증 플로우 테스트 | 로그인/로그아웃/자동 로그인 | 짧음 |
| 4-3 | 홈 화면 검증 | God Object 해체 영향 확인 | 짧음 |
| 4-4 | 예약 플로우 테스트 | 생성/취소/동시성 | 중간 |

**Staging URL**: https://uncany-staging.web.app

---

### Phase 5: 추가 리팩토링 (선택)

**목표**: 나머지 대형 파일 리팩토링

| # | 대상 | 현재 줄 수 | 우선순위 |
|---|------|-----------|----------|
| 5-1 | classroom_detail_screen.dart | 827줄 | 높음 |
| 5-2 | reservation_screen.dart | ~500줄 | 중간 |
| 5-3 | 나머지 화면 AsyncNotifier 적용 | - | 중간 |

---

### Phase 6: 신규 기능 (v0.4.0)

**목표**: 사용자 경험 개선

| # | 기능 | 설명 | 우선순위 |
|---|------|------|----------|
| 6-1 | 알림 시스템 (FCM) | 예약 확인/취소 알림 | 높음 |
| 6-2 | Realtime 필터 | school_id 기반 실시간 업데이트 | 중간 |
| 6-3 | 관리자 승인 고도화 | 이메일 알림, 대시보드 | 중간 |
| 6-4 | 오프라인 지원 | 캐싱, 동기화 | 낮음 |

---

## ❓ Gemini 피드백 요청 사항

### 1. 우선순위 확인

**질문**: 다음 중 어떤 순서로 진행할까요?

- **옵션 A**: Phase 4 (Staging 검증) → Phase 6 (신규 기능)
- **옵션 B**: Phase 4 (Staging 검증) → Phase 5 (추가 리팩토링) → Phase 6
- **옵션 C**: Phase 4만 진행 후 Production 배포 준비

### 2. 신규 기능 우선순위

**질문**: Phase 6 신규 기능 중 가장 먼저 구현할 것은?

1. 알림 시스템 (FCM)
2. Realtime school_id 필터
3. 관리자 승인 고도화
4. 기타 (제안해주세요)

### 3. classroom_detail_screen.dart 리팩토링

**질문**: 827줄 파일을 home_screen.dart처럼 분리할까요?

- 예: 위젯 분리 + AsyncNotifier 패턴 적용
- 아니오: 현재 상태 유지 (작동하면 건드리지 않기)

### 4. 기타 피드백

- 아키텍처 개선 제안
- 누락된 테스트 케이스
- 성능 우려 사항
- 기타

---

## 📅 제안 일정

```
Phase 4 (Staging 검증)     → 즉시
Phase 5 (추가 리팩토링)    → 피드백 후 결정
Phase 6 (신규 기능)        → 피드백 후 결정
Production 배포            → Staging 검증 완료 후
```

---

## 🔗 참고 문서

- [SESSION_SUMMARY.md](./SESSION_SUMMARY.md) - 전체 진행 상황
- [PHASE3-B_COMPLETION_REPORT.md](./PHASE3-B_COMPLETION_REPORT.md) - v0.3.9 완료 보고서
- [ANALYSIS_REPORT_v0.3.9.md](./ANALYSIS_REPORT_v0.3.9.md) - 코드 분석 보고서

---

**Claude의 권장사항**: 옵션 A (Phase 4 → Phase 6)

이유:
1. v0.3.9 리팩토링으로 코드 품질 충분히 개선됨
2. 사용자 가치 있는 신규 기능(알림) 우선
3. 추가 리팩토링은 필요 시 점진적으로

---

*피드백 부탁드립니다!*
