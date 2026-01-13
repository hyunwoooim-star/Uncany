# 🔧 시니어 개발자 코드 리뷰 피드백 반영

**작성일**: 2026-01-13
**목적**: 프로덕션 배포 전 보안 취약점 및 아키텍처 부채 해결

---

## 📋 수정 사항 요약

### 1. 🚨 [긴급] RLS 보안 정책 전면 수정

**파일**: `supabase/migrations/004_production_ready_security.sql`

#### 문제점
- `reservations` 테이블에 `FOR ALL` 정책이 적용되어 있어, 로그인한 교사 A가 교사 B의 예약을 삭제/수정할 수 있음
- `users` 테이블에 UPDATE 정책이 없어 타인의 프로필을 수정할 수 있음
- `periods` 컬럼이 없어 코드와 DB 스키마가 불일치

#### 해결 방법
```sql
-- SELECT: 모든 인증 사용자 허용
CREATE POLICY "reservations_select_active" ON reservations
  FOR SELECT
  USING (auth.role() = 'authenticated' AND deleted_at IS NULL);

-- INSERT: 본인 ID로만 생성 가능
CREATE POLICY "reservations_insert_own" ON reservations
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated' AND teacher_id = auth.uid());

-- UPDATE: 본인 예약만 수정 가능
CREATE POLICY "reservations_update_own" ON reservations
  FOR UPDATE
  USING (teacher_id = auth.uid() AND deleted_at IS NULL)
  WITH CHECK (teacher_id = auth.uid());

-- DELETE: 본인 예약만 삭제 가능
CREATE POLICY "reservations_delete_own" ON reservations
  FOR DELETE
  USING (teacher_id = auth.uid());

-- periods 컬럼 추가
ALTER TABLE reservations ADD COLUMN periods INTEGER[] DEFAULT '{}';
ALTER TABLE reservations ADD CONSTRAINT valid_periods_range
  CHECK (periods <@ ARRAY[1, 2, 3, 4, 5, 6]);
```

#### 기술적 설명 (Why)
- **RLS 세분화**: SELECT/INSERT/UPDATE/DELETE를 각각 분리하여 최소 권한 원칙 적용
- **auth.uid() 검증**: Supabase Auth의 JWT 토큰에서 추출한 사용자 ID로 본인 여부 확인
- **periods 컬럼**: 교시 정보를 PostgreSQL 배열로 저장 (GIN 인덱스 활용)

---

### 2. ⚡️ [긴급] Race Condition 방지

**파일**: `supabase/migrations/004_production_ready_security.sql`

#### 문제점
동시에 2명이 같은 교시를 예약하려고 할 때:
1. 사용자 A: "충돌 조회" → 없음
2. 사용자 B: "충돌 조회" → 없음 (A가 아직 저장 안 함)
3. 사용자 A: 예약 저장 ✅
4. 사용자 B: 예약 저장 ✅ ❌ (중복!)

#### 해결 방법
```sql
CREATE OR REPLACE FUNCTION check_and_prevent_reservation_conflict()
RETURNS TRIGGER AS $$
DECLARE
  conflict_count INTEGER;
BEGIN
  -- FOR UPDATE: Row-Level 락을 걸어 동시 접근 차단
  SELECT COUNT(*)
  INTO conflict_count
  FROM reservations
  WHERE classroom_id = NEW.classroom_id
    AND DATE(start_time) = DATE(NEW.start_time)
    AND deleted_at IS NULL
    AND periods && NEW.periods  -- 교시 배열 겹침 체크
  FOR UPDATE;  -- 🔒 락!

  IF conflict_count > 0 THEN
    RAISE EXCEPTION '이미 예약된 교시가 포함되어 있습니다';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_reservation_conflict
  BEFORE INSERT OR UPDATE ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION check_and_prevent_reservation_conflict();
```

#### 기술적 설명 (Why)
- **FOR UPDATE 락**: 트랜잭션이 끝날 때까지 해당 행을 다른 트랜잭션이 읽거나 수정하지 못하게 차단
- **BEFORE 트리거**: INSERT 전에 실행되어 중복 데이터 삽입 자체를 차단
- **원자성 보장**: 조회 → 검증 → 삽입이 하나의 트랜잭션으로 처리됨

---

### 3. ♻️ Riverpod 아키텍처 리팩토링

**파일**:
- `lib/src/features/reservation/presentation/providers/reservation_state_provider.dart`
- `lib/src/features/reservation/presentation/reservation_screen_v2.dart`

#### 문제점
```dart
// ❌ 안티패턴
class _ReservationScreenState extends ConsumerState {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final repository = ReservationRepository(supabase); // 매번 생성
      final data = await repository.getData();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
```

#### 해결 방법
```dart
// ✅ Riverpod 2.0 패턴
@riverpod
class ReservationScreenNotifier extends _$ReservationScreenNotifier {
  @override
  Future<ReservationState> build({required String classroomId}) async {
    final repository = ref.read(reservationRepositoryProvider);
    final reservedMap = await repository.getReservedPeriodsMap(classroomId, DateTime.now());

    return ReservationState(
      reservedPeriods: reservedMap,
      selectedPeriods: {},
      selectedDate: DateTime.now(),
    );
  }

  Future<void> selectDate(DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final reservedMap = await _loadReservations(date);
      final current = await future;
      return current.copyWith(selectedDate: date, reservedPeriods: reservedMap);
    });
  }
}

// 화면에서 사용
class ReservationScreenV2 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reservationScreenNotifierProvider(classroomId: classroomId));

    return state.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorView(error: error),
      data: (reservationState) => _ReservationContent(state: reservationState),
    );
  }
}
```

#### 기술적 설명 (Why)
- **AsyncValue**: 로딩/에러/데이터 상태를 자동 관리, `try-catch` 보일러플레이트 제거
- **Provider 주입**: Repository를 매번 생성하지 않고 싱글톤으로 관리
- **Code Generation**: `@riverpod` 어노테이션으로 타입 안전성 보장
- **Immutable State**: `copyWith`로 상태 변경, 예측 가능한 상태 관리

---

### 4. 🔒 나이스 API 키 보안 처리

**파일**: `supabase/functions/neis-api/index.ts`

#### 문제점
```dart
// ❌ 클라이언트 코드에 API 키 노출
class SchoolApiService {
  static const String API_KEY = 'abc123...'; // 브라우저 개발자 도구에서 보임!

  Future<List<School>> search(String query) async {
    final url = 'https://open.neis.go.kr/hub?KEY=$API_KEY&...';
    // ...
  }
}
```

#### 해결 방법
```typescript
// ✅ Supabase Edge Function (서버 사이드)
const NEIS_API_KEY = Deno.env.get('NEIS_API_KEY');  // 환경 변수

serve(async (req: Request) => {
  // 인증 확인
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return createResponse({ error: '인증 필요' }, { status: 401 });
  }

  // API 키는 서버에서만 사용
  const apiUrl = `${NEIS_BASE_URL}?KEY=${NEIS_API_KEY}&...`;
  const response = await fetch(apiUrl);

  // 클라이언트에는 필터링된 데이터만 반환
  return createResponse({ schools: transformedData });
});
```

```dart
// 클라이언트에서 Edge Function 호출
Future<List<School>> searchSchools(String query) async {
  final response = await supabase.functions.invoke(
    'neis-api',
    body: {'action': 'search_schools', 'query': query},
  );
  return (response.data['schools'] as List)
      .map((json) => School.fromJson(json))
      .toList();
}
```

#### 기술적 설명 (Why)
- **서버 사이드 실행**: API 키는 Deno Edge Function 환경 변수에만 존재
- **클라이언트 분리**: 브라우저/앱에서는 키를 전혀 볼 수 없음
- **추가 보안**: Supabase Auth 토큰으로 Edge Function 접근 제어

---

### 5. 🚀 이미지 압축 성능 개선

**파일**: `lib/src/core/utils/image_compressor_v2.dart`

#### 문제점
```dart
// ❌ 메인 스레드에서 동기 실행
static Future<Uint8List> compressToWebP(Uint8List bytes) async {
  final image = img.decodeImage(bytes);  // 고해상도 이미지면 3초+ 걸림
  final resized = img.copyResize(image, width: 1920);  // UI 프리즈!
  return img.encodeWebP(resized, quality: 85);
}
```

#### 해결 방법
```dart
// ✅ compute() 활용 (별도 Isolate에서 실행)
static Future<Uint8List> compressToWebP(Uint8List imageBytes) async {
  if (kIsWeb) {
    // Web: Isolate 미지원, 메인 스레드 실행 (제한적)
    return _compressImageSync(imageBytes);
  } else {
    // 모바일: compute()로 별도 Isolate 실행 ✅
    return await compute(_compressImageSync, _CompressionParams(...));
  }
}

static Uint8List _compressImageSync(_CompressionParams params) {
  // 실제 압축 로직
  final image = img.decodeImage(params.imageBytes);
  final resized = img.copyResize(image, ...);
  return img.encodeWebP(resized, quality: params.quality);
}
```

#### 기술적 설명 (Why)
- **compute() 함수**: Flutter의 Isolate 헬퍼, CPU 집약적 작업을 백그라운드에서 실행
- **Web 제한**: Flutter Web은 Isolate를 지원하지 않으므로 메인 스레드 실행 (성능 trade-off)
- **프로덕션 권장**: **Supabase Storage Hook**으로 서버 사이드 압축 권장 (Sharp.js 사용)

#### 추가 제안: Supabase Storage Hook
```typescript
// supabase/functions/storage-hook-resize/index.ts
import sharp from 'sharp';

serve(async (req) => {
  const { name, bucket } = await req.json();

  const original = await supabase.storage.from(bucket).download(name);
  const resized = await sharp(original.data)
    .resize(1920, 1920, { fit: 'inside' })
    .webp({ quality: 85 })
    .toBuffer();

  await supabase.storage.from(bucket).upload(name, resized, { upsert: true });
});
```

---

## 📊 수정 전/후 비교

| 항목 | 수정 전 | 수정 후 |
|------|---------|---------|
| **보안** | ⚠️ 타인 예약 삭제 가능 | ✅ 본인만 수정/삭제 |
| **동시성** | ❌ Race Condition 발생 | ✅ DB 락으로 원자성 보장 |
| **상태 관리** | ⚠️ setState 지옥 | ✅ AsyncValue 패턴 |
| **API 키** | ❌ 클라이언트 노출 | ✅ Edge Function 숨김 |
| **이미지 압축** | ⚠️ UI 프리즈 | ✅ compute() 비동기 처리 |

---

## 🚀 배포 전 체크리스트

### Critical (필수)
- [ ] `004_production_ready_security.sql` 마이그레이션 실행
- [ ] Supabase Dashboard에서 RLS 정책 확인
- [ ] 동시 예약 테스트 (2명이 동시에 같은 교시 예약 시도)
- [ ] 타인 예약 삭제 시도 (에러 발생해야 함)
- [ ] Edge Function 환경 변수 설정 (`NEIS_API_KEY`)
- [ ] `reservation_screen_v2.dart`로 교체 후 build_runner 실행

### High (강력 권장)
- [ ] 프로덕션 DB에 백업 생성
- [ ] Staging 환경에서 먼저 테스트
- [ ] 이미지 압축 성능 벤치마크 (모바일/Web 각각)
- [ ] Sentry/Crashlytics로 에러 모니터링 설정

---

## 📝 후속 작업 (선택)

1. **Supabase Storage Hook**: 서버 사이드 이미지 압축으로 전환
2. **Web Worker**: Flutter Web에서 compute() 대신 Web Worker 직접 구현
3. **Unit Test**: 추가된 함수/Provider에 대한 테스트 작성
4. **인덱스 최적화**: PostgreSQL EXPLAIN ANALYZE로 쿼리 성능 분석

---

## 🔗 관련 문서

- [Supabase RLS 가이드](https://supabase.com/docs/guides/auth/row-level-security)
- [Riverpod 2.0 마이그레이션](https://riverpod.dev/docs/migration/from_state_notifier)
- [Flutter compute() 함수](https://api.flutter.dev/flutter/foundation/compute-constant.html)
- [PostgreSQL FOR UPDATE](https://www.postgresql.org/docs/current/sql-select.html#SQL-FOR-UPDATE-SHARE)

---

**작성자**: Claude Sonnet 4.5 + 임현우
**검토자**: 시니어 개발자
**최종 업데이트**: 2026-01-13
