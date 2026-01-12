import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uncany/src/features/auth/data/repositories/auth_repository.dart';
import 'package:uncany/src/features/auth/domain/models/user.dart';

// Mock 클래스 정의
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}
class MockSession extends Mock implements Session {}
class MockUser extends Mock implements AuthUser {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockPostgrestClient mockPostgrest;
  late AuthRepository authRepository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockPostgrest = MockPostgrestClient();
    authRepository = AuthRepository(mockSupabase);

    // 기본 설정
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockSupabase.from(any())).thenReturn(mockPostgrest as dynamic);
  });

  group('AuthRepository -', () {
    group('getCurrentUser', () {
      test('세션이 없으면 null 반환', () async {
        // Arrange
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });

      test('세션이 있고 users 테이블에 데이터가 있으면 User 반환', () async {
        // Arrange
        final mockSession = MockSession();
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockAuth.currentSession).thenReturn(mockSession);

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
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'test-user-id');
        expect(result?.email, 'test@example.com');
        expect(result?.name, '홍길동');
      });

      test('users 테이블에 데이터가 없으면 null 반환', () async {
        // Arrange
        final mockSession = MockSession();
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockAuth.currentSession).thenReturn(mockSession);

        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.select()).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('signOut', () {
      test('로그아웃 성공', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async => {});

        // Act & Assert - 예외 없이 완료되어야 함
        await expectLater(authRepository.signOut(), completes);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('로그아웃 실패 시 예외 발생', () async {
        // Arrange
        when(() => mockAuth.signOut()).thenThrow(
          AuthException('로그아웃 실패'),
        );

        // Act & Assert
        await expectLater(
          authRepository.signOut(),
          throwsException,
        );
      });
    });

    group('updateProfile', () {
      test('세션이 없으면 예외 발생', () async {
        // Arrange
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act & Assert
        await expectLater(
          authRepository.updateProfile(name: '새이름'),
          throwsException,
        );
      });

      test('프로필 업데이트 성공', () async {
        // Arrange
        final mockSession = MockSession();
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockSession.user).thenReturn(mockUser);
        when(() => mockAuth.currentSession).thenReturn(mockSession);

        final mockFilterBuilder = MockPostgrestFilterBuilder();
        when(() => mockPostgrest.update(any())).thenReturn(mockFilterBuilder as dynamic);
        when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) async => []);

        // Act & Assert
        await expectLater(
          authRepository.updateProfile(
            name: '새이름',
            grade: 5,
            classNum: 3,
          ),
          completes,
        );
      });
    });

    group('resetPassword', () {
      test('비밀번호 재설정 이메일 발송 성공', () async {
        // Arrange
        when(() => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        )).thenAnswer((_) async => {});

        // Act & Assert
        await expectLater(
          authRepository.resetPassword('test@example.com'),
          completes,
        );
        verify(() => mockAuth.resetPasswordForEmail(
          'test@example.com',
          redirectTo: any(named: 'redirectTo'),
        )).called(1);
      });

      test('잘못된 이메일로 예외 발생', () async {
        // Arrange
        when(() => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        )).thenThrow(
          AuthException('잘못된 이메일'),
        );

        // Act & Assert
        await expectLater(
          authRepository.resetPassword('invalid@email.com'),
          throwsException,
        );
      });
    });
  });
}
