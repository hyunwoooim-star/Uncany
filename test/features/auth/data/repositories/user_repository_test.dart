import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uncany/src/features/auth/data/repositories/user_repository.dart';
import 'package:uncany/src/features/auth/domain/models/user.dart';

// Mock 클래스 정의
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockPostgrestClient mockPostgrest;
  late UserRepository userRepository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockPostgrest = MockPostgrestClient();
    userRepository = UserRepository(mockSupabase);

    // 기본 설정
    when(() => mockSupabase.from(any())).thenReturn(mockPostgrest as dynamic);
  });

  group('UserRepository -', () {
    group('getUsers', () {
      test('모든 사용자 조회 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => [
          {
            'id': 'user-1',
            'email': 'user1@example.com',
            'name': '사용자1',
            'username': 'user1',
            'school_id': 'school-1',
            'school_name': '테스트초등학교',
            'grade': 3,
            'class_num': 2,
            'verification_status': 'approved',
            'role': 'teacher',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'user-2',
            'email': 'user2@example.com',
            'name': '사용자2',
            'username': 'user2',
            'school_id': 'school-1',
            'school_name': '테스트초등학교',
            'grade': 4,
            'class_num': 1,
            'verification_status': 'pending',
            'role': 'teacher',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ]);

        // Act
        final result = await userRepository.getUsers();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].email, 'user1@example.com');
        expect(result[1].email, 'user2@example.com');
      });

      test('인증 상태로 필터링 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => [
          {
            'id': 'user-1',
            'email': 'user1@example.com',
            'name': '사용자1',
            'username': 'user1',
            'school_id': 'school-1',
            'school_name': '테스트초등학교',
            'grade': 3,
            'class_num': 2,
            'verification_status': 'pending',
            'role': 'teacher',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ]);

        // Act
        final result = await userRepository.getUsers(status: VerificationStatus.pending);

        // Assert
        expect(result, hasLength(1));
        expect(result[0].verificationStatus, VerificationStatus.pending);
      });
    });

    group('getUser', () {
      test('특정 사용자 조회 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.maybeSingle()).thenAnswer((_) async => {
          'id': 'test-user-id',
          'email': 'test@example.com',
          'name': '홍길동',
          'username': 'hong123',
          'school_id': 'school-id',
          'school_name': '테스트초등학교',
          'grade': 3,
          'class_num': 2,
          'verification_status': 'approved',
          'role': 'teacher',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        });

        // Act
        final result = await userRepository.getUser('test-user-id');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'test-user-id');
        expect(result?.name, '홍길동');
      });

      test('존재하지 않는 사용자는 null 반환', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);

        // Act
        final result = await userRepository.getUser('non-existent-id');

        // Assert
        expect(result, isNull);
      });
    });

    group('approveUser', () {
      test('사용자 승인 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.update(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.single()).thenAnswer((_) async => {
          'id': 'test-user-id',
          'email': 'test@example.com',
          'name': '홍길동',
          'username': 'hong123',
          'school_id': 'school-id',
          'school_name': '테스트초등학교',
          'grade': 3,
          'class_num': 2,
          'verification_status': 'approved',
          'role': 'teacher',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        });

        // Act & Assert
        await expectLater(
          userRepository.approveUser('test-user-id'),
          completes,
        );
      });
    });

    group('rejectUser', () {
      test('사용자 반려 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.update(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.single()).thenAnswer((_) async => {
          'id': 'test-user-id',
          'email': 'test@example.com',
          'name': '홍길동',
          'username': 'hong123',
          'school_id': 'school-id',
          'school_name': '테스트초등학교',
          'grade': 3,
          'class_num': 2,
          'verification_status': 'rejected',
          'rejected_reason': '재직증명서 불일치',
          'role': 'teacher',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        });

        // Act & Assert
        await expectLater(
          userRepository.rejectUser('test-user-id', '재직증명서 불일치'),
          completes,
        );
      });

      test('반려 사유 없이 호출 시 예외 발생', () async {
        // Act & Assert
        await expectLater(
          userRepository.rejectUser('test-user-id', ''),
          throwsException,
        );
      });
    });

    group('updateUserRole', () {
      test('사용자 권한 변경 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.update(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) async => []);

        // Act & Assert
        await expectLater(
          userRepository.updateUserRole('test-user-id', UserRole.admin),
          completes,
        );
      });
    });

    group('deleteUser', () {
      test('사용자 soft delete 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.update(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) async => []);

        // Act & Assert
        await expectLater(
          userRepository.deleteUser('test-user-id'),
          completes,
        );
      });
    });

    group('restoreUser', () {
      test('사용자 복원 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.update(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) async => []);

        // Act & Assert
        await expectLater(
          userRepository.restoreUser('test-user-id'),
          completes,
        );
      });
    });

    group('getPendingCount', () {
      test('대기 중인 사용자 수 조회 성공', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.count(any())).thenAnswer((_) async => [{'count': 5}]);

        // Act
        final result = await userRepository.getPendingCount();

        // Assert
        expect(result, 5);
      });

      test('대기 중인 사용자가 없으면 0 반환', () async {
        // Arrange
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.count(any())).thenAnswer((_) async => [{'count': 0}]);

        // Act
        final result = await userRepository.getPendingCount();

        // Assert
        expect(result, 0);
      });
    });
  });
}
