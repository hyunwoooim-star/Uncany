import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/admin_approvals_screen.dart';
import '../../features/auth/presentation/admin_users_screen.dart';
import '../../features/auth/domain/models/user.dart';
import '../../features/reservation/presentation/home_screen.dart';
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
    ],
  );
}
