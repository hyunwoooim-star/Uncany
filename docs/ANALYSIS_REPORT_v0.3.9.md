# Uncany v0.3.9 분석 보고서

> **작성자**: Claude
> **작성일**: 2026-01-19
> **목적**: Gemini 검토용 분석 보고서

---

## 📊 현재 상태 요약 (v0.3.8-rc)

### 완료된 기능
| 버전 | 기능 | 마이그레이션 |
|------|------|-------------|
| v0.3.8 | 교실 댓글/게시판 | 012_classroom_comments.sql |
| v0.3.8 | 교실 소유권 관리 | 011_classroom_ownership_and_unique.sql |
| v0.3.7 | 추천인 코드 RLS | 010_fix_referral_codes_rls.sql |
| v0.3.6 | 시간표 대시보드 UI | - |

---

## 🔴 코드 품질 문제점

### 1. home_screen.dart - 심각도: 🔴 Critical

**파일 정보:**
- 경로: `lib/src/features/reservation/presentation/home_screen.dart`
- 줄 수: **1602줄** (God Object 패턴)

**문제점:**
| 문제 | 상세 | 라인 |
|------|------|------|
| 코드 중복 | `_buildStatusBadge()` 3회 정의 | 1029, 1159, 1334 |
| 상태 관리 | AsyncNotifier 미사용, setState() 직접 호출 | 전체 |
| 단일 책임 위반 | 그리팅, 메뉴, 예약목록, 관리자메뉴 모두 처리 | 전체 |

**비교:**
- classroom_detail_screen.dart: 826줄 (관리 가능)
- reservation_screen.dart: 617줄 (적절)

---

### 2. Provider 패턴 - 심각도: 🟡 Warning

**현황:**
```
StateNotifier 사용: 0개
AsyncNotifier 사용: 0개
FutureProvider: 다수
StreamProvider: 다수
```

**문제:**
- 상태 변경이 모두 `ref.read()` + `setState()`로 처리
- Provider 무효화(invalidation)가 수동으로 분산 관리
- 테스트 어려움

**예시 (현재 패턴):**
```dart
Future<void> _logout() async {
  try {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    // setState() 또는 context.go() 직접 호출
  } catch (e) {
    TossSnackBar.error(context, message: '로그아웃 실패: $e');
  }
}
```

---

### 3. 에러 핸들링 - 심각도: 🟡 Warning

**현황:**
- `ErrorMessages` 클래스 존재 (`lib/src/core/utils/error_messages.dart`)
- 실제 사용률: **약 50% 미만**
- try-catch + setState 패턴: 29회 반복

**문제:**
```dart
// ❌ 현재 (직접 에러 메시지)
} catch (e) {
  TossSnackBar.error(context, message: '로그아웃 실패: $e');
}

// ✅ 권장 (ErrorMessages 사용)
} catch (e) {
  TossSnackBar.error(context, message: ErrorMessages.fromError(e));
}
```

---

### 4. 테스트 커버리지 - 심각도: 🟡 Warning

**현황:**
```
test/
├── core/extensions/string_extensions_test.dart
└── core/utils/validators_test.dart
```

**문제:**
- 테스트 파일: **2개만**
- 비즈니스 로직 테스트: **0개**
- Repository 테스트: **0개**
- Widget 테스트: **0개**

---

## ✅ 긍정적 요소

### DB/보안 - 심각도: 🟢 Good
| 항목 | 수치 | 평가 |
|------|------|------|
| RLS 정책 | 44개 | 다중 테넌트 격리 완벽 |
| RPC 함수 | 18개 | Race Condition 방지 |
| 마이그레이션 | 12개 | 체계적 관리 |

**주요 보안 기능:**
- Advisory Lock (예약 충돌 방지)
- Exclusion Constraint (시간 중복 방지)
- FOR UPDATE 락 (추천코드 Race Condition 방지)

### CI/CD - 심각도: 🟢 Good
| 워크플로우 | 목적 |
|-----------|------|
| test.yml | Flutter 분석 + 테스트 + Codecov |
| deploy-web-staging.yml | Staging 자동 배포 |
| deploy-web-preview.yml | PR 미리보기 |

---

## 📋 권장 작업 계획

### Phase 1: 즉시 (30분)
| 작업 | 명령어 |
|------|--------|
| Freezed 코드 생성 | `dart run build_runner build --delete-conflicting-outputs` |
| 로컬 빌드 검증 | `flutter run -d chrome` |

### Phase 2: 단기 (1-2일)
- [ ] ErrorMessages 일괄 적용 (29개 파일)
- [ ] 공통 위젯 추출 (StatusBadge, RoomTypeIcon)

### Phase 3: 중기 (3-5일)
- [ ] **home_screen.dart 리팩토링** (1602줄 → 300줄)
  - widgets/ 폴더로 분리
  - greeting_card.dart
  - quick_menu_grid.dart
  - my_reservations_section.dart
  - all_reservations_section.dart

### Phase 4: 장기 (1-2주)
- [ ] AsyncNotifier 패턴 도입
- [ ] 공통 로딩 패턴 추상화
- [ ] Realtime school_id 필터 추가

---

## 📁 핵심 파일 목록

| 파일 | 용도 | 우선순위 |
|------|------|---------|
| `home_screen.dart` | 리팩토링 대상 | 🔴 |
| `classroom_comment.dart` | Freezed 생성 필요 | 🔴 |
| `error_messages.dart` | 에러 핸들링 표준 | 🟡 |
| `reservation_repository_provider.dart` | AsyncNotifier 시작점 | 🟢 |

---

## 🎯 Gemini 검토 요청 사항

1. **home_screen.dart 리팩토링 구조** 검토
2. **AsyncNotifier 도입 우선순위** 의견
3. **테스트 커버리지 전략** 제안
4. **추가 발견된 문제점** 피드백

---

## 📝 세션 인수인계

```
### 인수인계 (Claude → Gemini)
- 완료: 분석 보고서 작성 (ANALYSIS_REPORT_v0.3.9.md)
- 완료: bypass permission 설정 완료
- 진행중: 없음
- 주의사항: Freezed 코드 생성 필요 (빌드 전 필수)
- 다음 할 일: Gemini 검토 후 Phase 1 실행
```
