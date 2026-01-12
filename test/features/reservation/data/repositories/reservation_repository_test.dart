import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uncany/src/features/reservation/data/repositories/reservation_repository.dart';
import 'package:uncany/src/features/reservation/domain/models/reservation.dart';

// Mock 클래스 정의
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockPostgrestClient mockPostgrest;
  late ReservationRepository reservationRepository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockPostgrest = MockPostgrestClient();
    reservationRepository = ReservationRepository(mockSupabase);

    // 기본 설정
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockSupabase.from(any())).thenReturn(mockPostgrest as dynamic);
  });

  group('ReservationRepository -', () {
    group('getMyReservations', () {
      test('세션이 없으면 예외 발생', () async {
        // Arrange
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act & Assert
        await expectLater(
          reservationRepository.getMyReservations(),
          throwsException,
        );
      });

      test('내 예약 목록 조회 성공', () async {
        // Arrange
        final mockSession = MockSession();
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-teacher-id');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockAuth.currentSession).thenReturn(mockSession);

        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.isFilter(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => [
          {
            'id': 'reservation-1',
            'classroom_id': 'classroom-1',
            'teacher_id': 'test-teacher-id',
            'reservation_date': '2024-01-15',
            'periods': [1, 2],
            'start_time': '2024-01-15T09:00:00Z',
            'end_time': '2024-01-15T10:40:00Z',
            'purpose': '수업',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ]);

        // Act
        final result = await reservationRepository.getMyReservations();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].teacherId, 'test-teacher-id');
        expect(result[0].periods, [1, 2]);
      });

      test('날짜 필터링으로 예약 조회', () async {
        // Arrange
        final mockSession = MockSession();
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-teacher-id');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockAuth.currentSession).thenReturn(mockSession);

        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.isFilter(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.gte(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.lte(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => []);

        // Act
        final result = await reservationRepository.getMyReservations(
          startDate: DateTime(2024, 1, 15),
          endDate: DateTime(2024, 1, 20),
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getReservationsByClassroom', () {
      test('교실별 예약 조회 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.gte(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.lt(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.isFilter(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => [
          {
            'id': 'reservation-1',
            'classroom_id': 'classroom-1',
            'teacher_id': 'teacher-1',
            'reservation_date': '2024-01-15',
            'periods': [1, 2, 3],
            'start_time': '2024-01-15T09:00:00Z',
            'end_time': '2024-01-15T11:30:00Z',
            'purpose': '체육 수업',
            'users': {
              'name': '김선생',
              'grade': 3,
              'class_num': 2,
            },
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ]);

        // Act
        final result = await reservationRepository.getReservationsByClassroom(
          'classroom-1',
          date: DateTime(2024, 1, 15),
        );

        // Assert
        expect(result, hasLength(1));
        expect(result[0].classroomId, 'classroom-1');
        expect(result[0].periods, [1, 2, 3]);
      });

      test('해당 날짜에 예약이 없으면 빈 목록 반환', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.gte(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.lt(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.isFilter(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => []);

        // Act
        final result = await reservationRepository.getReservationsByClassroom(
          'classroom-1',
          date: DateTime(2024, 1, 15),
        );

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
