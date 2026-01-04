import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/admin_approvals_screen.dart';
import '../../features/auth/presentation/admin_users_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/edit_profile_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/my_referral_codes_screen.dart';
import '../../features/auth/domain/models/user.dart';
import '../../features/reservation/presentation/home_screen.dart';
import '../../features/classroom/presentation/classroom_list_screen.dart';
import '../../features/classroom/presentation/classroom_detail_screen.dart';
import '../../features/classroom/presentation/admin_classroom_screen.dart';
import '../../features/classroom/presentation/classroom_form_screen.dart';
import '../../features/reservation/presentation/my_reservations_screen.dart';
import '../providers/auth_provider.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final currentUser = ref.watch(currentUserProvider).value;

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (context, state) {
      // 스플래시 화면은 리다이렉트 제외
      if (state.matchedLocation == '/') {
        return null;
      }

      // 인증 상태에 따른 리다이렉트
      final isAuthPage = state.matchedLocation.startsWith('/auth');
      final isAdminPage = state.matchedLocation.startsWith('/admin');

      // 미인증 사용자
      if (!isAuthenticated && !isAuthPage) {
        return '/auth/login';
      }

      // 인증된 사용자가 인증 페이지 접근
      if (isAuthenticated && isAuthPage) {
        return '/home';
      }

      // 관리자 페이지 권한 체크
      if (isAdminPage && currentUser?.role != UserRole.admin) {
        return '/home';
      }

      return null;
    },
    routes: [
      // 스플래시
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 인증
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // 메인
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // 프로필
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/profile/referral-codes',
        name: 'referral-codes',
        builder: (context, state) => const MyReferralCodesScreen(),
      ),

      // 관리자
      GoRoute(
        path: '/admin/approvals',
        name: 'admin-approvals',
        builder: (context, state) => const AdminApprovalsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/classrooms',
        name: 'admin-classrooms',
        builder: (context, state) => const AdminClassroomScreen(),
      ),
      GoRoute(
        path: '/admin/classrooms/create',
        name: 'admin-classrooms-create',
        builder: (context, state) => const ClassroomFormScreen(),
      ),
      GoRoute(
        path: '/admin/classrooms/:id/edit',
        name: 'admin-classrooms-edit',
        builder: (context, state) {
          final classroom = state.extra as Classroom?;
          return ClassroomFormScreen(classroom: classroom);
        },
      ),

      // 교실
      GoRoute(
        path: '/classrooms',
        name: 'classrooms',
        builder: (context, state) => const ClassroomListScreen(),
      ),
      GoRoute(
        path: '/classrooms/:id',
        name: 'classroom-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ClassroomDetailScreen(classroomId: id);
        },
      ),

      // 예약
      GoRoute(
        path: '/reservations/my',
        name: 'my-reservations',
        builder: (context, state) => const MyReservationsScreen(),
      ),
    ],
  );
}
