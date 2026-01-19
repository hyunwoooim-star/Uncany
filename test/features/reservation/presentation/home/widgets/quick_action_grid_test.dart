import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uncany/src/features/reservation/presentation/home/widgets/quick_action_grid.dart';

void main() {
  group('QuickActionGrid', () {
    /// 테스트용 앱 생성 (GoRouter 설정 포함)
    Widget createTestApp({
      void Function(String)? onNavigate,
    }) {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: QuickActionGrid(),
            ),
          ),
          GoRoute(
            path: '/classrooms',
            builder: (context, state) {
              onNavigate?.call('/classrooms');
              return const Scaffold(body: Text('교실 예약 화면'));
            },
          ),
          GoRoute(
            path: '/reservations/timetable',
            builder: (context, state) {
              onNavigate?.call('/reservations/timetable');
              return const Scaffold(body: Text('종합 시간표 화면'));
            },
          ),
          GoRoute(
            path: '/school/members',
            builder: (context, state) {
              onNavigate?.call('/school/members');
              return const Scaffold(body: Text('우리 학교 교사 화면'));
            },
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
      );
    }

    testWidgets('3개의 액션 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(createTestApp());

      expect(find.text('교실 예약'), findsOneWidget);
      expect(find.text('종합 시간표'), findsOneWidget);
      expect(find.text('우리 학교 교사'), findsOneWidget);
    });

    testWidgets('각 버튼에 올바른 아이콘이 표시된다', (tester) async {
      await tester.pumpWidget(createTestApp());

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('교실 예약 버튼 탭 시 /classrooms로 이동한다', (tester) async {
      String? navigatedTo;
      await tester.pumpWidget(createTestApp(
        onNavigate: (path) => navigatedTo = path,
      ));

      await tester.tap(find.text('교실 예약'));
      await tester.pumpAndSettle();

      expect(navigatedTo, '/classrooms');
    });

    testWidgets('종합 시간표 버튼 탭 시 /reservations/timetable로 이동한다', (tester) async {
      String? navigatedTo;
      await tester.pumpWidget(createTestApp(
        onNavigate: (path) => navigatedTo = path,
      ));

      await tester.tap(find.text('종합 시간표'));
      await tester.pumpAndSettle();

      expect(navigatedTo, '/reservations/timetable');
    });

    testWidgets('우리 학교 교사 버튼 탭 시 /school/members로 이동한다', (tester) async {
      String? navigatedTo;
      await tester.pumpWidget(createTestApp(
        onNavigate: (path) => navigatedTo = path,
      ));

      await tester.tap(find.text('우리 학교 교사'));
      await tester.pumpAndSettle();

      expect(navigatedTo, '/school/members');
    });

    testWidgets('모든 버튼에 chevron_right 아이콘이 표시된다', (tester) async {
      await tester.pumpWidget(createTestApp());

      // 3개의 CompactActionButton에 각각 chevron_right 아이콘이 있음
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    });
  });

  group('CompactActionButton', () {
    testWidgets('badge가 없으면 배지가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactActionButton(
              icon: Icons.star,
              label: '테스트',
              color: Colors.blue,
              onTap: () {},
            ),
          ),
        ),
      );

      // badge 컨테이너가 없어야 함
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('badge가 0이면 배지가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactActionButton(
              icon: Icons.star,
              label: '테스트',
              color: Colors.blue,
              onTap: () {},
              badge: 0,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('badge가 있으면 배지 숫자가 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactActionButton(
              icon: Icons.star,
              label: '테스트',
              color: Colors.blue,
              onTap: () {},
              badge: 5,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('badge가 99를 초과하면 99+로 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactActionButton(
              icon: Icons.star,
              label: '테스트',
              color: Colors.blue,
              onTap: () {},
              badge: 150,
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('탭 시 onTap 콜백이 호출된다', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactActionButton(
              icon: Icons.star,
              label: '테스트 버튼',
              color: Colors.blue,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('테스트 버튼'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
