import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uncany/src/features/auth/domain/models/user.dart';
import 'package:uncany/src/features/reservation/presentation/home/widgets/home_header.dart';

void main() {
  group('HomeHeader', () {
    /// 테스트용 사용자 생성
    User createTestUser({
      String name = '김선생',
      int? grade,
      int? classNum,
    }) {
      return User(
        id: 'test-user-id',
        name: name,
        schoolName: '테스트초등학교',
        grade: grade,
        classNum: classNum,
      );
    }

    testWidgets('사용자 이름이 "선생님" 접미사와 함께 표시된다', (tester) async {
      final user = createTestUser(name: '홍길동');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(user: user),
          ),
        ),
      );

      expect(find.text('홍길동 선생님'), findsOneWidget);
    });

    testWidgets('학년 및 반 정보가 있으면 표시된다', (tester) async {
      final user = createTestUser(name: '김선생', grade: 3, classNum: 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(user: user),
          ),
        ),
      );

      expect(find.text('김선생 선생님'), findsOneWidget);
      expect(find.text('3학년 2반'), findsOneWidget);
    });

    testWidgets('학년만 있고 반이 없으면 학년만 표시된다', (tester) async {
      final user = createTestUser(name: '박선생', grade: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(user: user),
          ),
        ),
      );

      expect(find.text('박선생 선생님'), findsOneWidget);
      expect(find.text('5학년'), findsOneWidget);
    });

    testWidgets('학년/반 정보가 없으면 학년반 컨테이너가 표시되지 않는다', (tester) async {
      final user = createTestUser(name: '이선생');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(user: user),
          ),
        ),
      );

      expect(find.text('이선생 선생님'), findsOneWidget);
      // gradeClassDisplay가 null이므로 학년반 컨테이너가 없어야 함
      expect(find.text('학년'), findsNothing);
    });

    testWidgets('손 흔드는 아이콘이 표시된다', (tester) async {
      final user = createTestUser();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(user: user),
          ),
        ),
      );

      expect(find.byIcon(Icons.waving_hand), findsOneWidget);
    });

    group('_getGreeting 시간대별 인사말', () {
      // Note: _getGreeting은 private 메서드이므로 직접 테스트할 수 없음
      // 대신 위젯 레벨에서 특정 시간의 인사말이 표시되는지 확인
      // 실제 테스트에서는 Clock을 mock하거나 시간을 주입해야 함

      testWidgets('인사말이 표시된다', (tester) async {
        final user = createTestUser();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeHeader(user: user),
            ),
          ),
        );

        // 시간에 따라 4가지 인사말 중 하나가 표시됨
        final greetings = ['새벽이에요', '좋은 아침이에요', '좋은 오후예요', '좋은 저녁이에요'];
        final foundGreeting = greetings.any(
          (greeting) => find.text(greeting).evaluate().isNotEmpty,
        );
        expect(foundGreeting, isTrue);
      });
    });
  });
}
