import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'toss_page_transition.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/admin_approvals_screen.dart';
import '../../features/auth/presentation/admin_users_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/edit_profile_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/reset_password_confirm_screen.dart';
import '../../features/auth/presentation/find_username_screen.dart';
import '../../features/auth/presentation/my_referral_codes_screen.dart';
import '../../features/auth/presentation/pending_approval_screen.dart';
import '../../features/settings/presentation/terms_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../features/settings/presentation/business_info_screen.dart';
import '../../features/auth/domain/models/user.dart';
import '../../features/reservation/presentation/home_screen.dart';
import '../../features/classroom/presentation/classroom_list_screen.dart';
import '../../features/classroom/presentation/classroom_detail_screen.dart';
import '../../features/classroom/presentation/admin_classroom_screen.dart';
import '../../features/classroom/presentation/classroom_form_screen.dart';
import '../../features/classroom/domain/models/classroom.dart';
import '../../features/reservation/presentation/my_reservations_screen.dart';
import '../../features/reservation/presentation/reservation_screen.dart';
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

      // 비밀번호 재설정 확인 페이지는 type=recovery가 있을 때 인증 없이 접근 허용
      final isResetPasswordConfirm = state.matchedLocation == '/auth/reset-password'
          && state.uri.queryParameters['type'] == 'recovery';

      // 미인증 사용자
      if (!isAuthenticated && !isAuthPage) {
        return '/auth/login';
      }

      // 인증된 사용자가 인증 페이지 접근 (비밀번호 재설정 확인 제외)
      if (isAuthenticated && isAuthPage && !isResetPasswordConfirm) {
        // 승인 대기 상태면 대기 화면으로
        if (currentUser?.verificationStatus == VerificationStatus.pending) {
          return '/pending-approval';
        }
        return '/home';
      }

      // 승인 대기 상태 체크 (관리자 제외)
      final isPendingPage = state.matchedLocation == '/pending-approval';
      if (isAuthenticated && currentUser != null) {
        final isPending = currentUser.verificationStatus == VerificationStatus.pending;
        final isAdmin = currentUser.role == UserRole.admin;

        // 승인 대기 중인데 대기 페이지가 아닌 곳으로 가려 할 때 (관리자 제외)
        if (isPending && !isAdmin && !isPendingPage && !isAuthPage) {
          return '/pending-approval';
        }

        // 승인 완료됐는데 대기 페이지에 있을 때
        if (!isPending && isPendingPage) {
          return '/home';
        }
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
      GoRoute(
        path: '/auth/reset-password',
        name: 'auth-reset-password',
        builder: (context, state) {
          // URL에 type=recovery가 있으면 확인 화면, 없으면 이메일 입력 화면
          final type = state.uri.queryParameters['type'];
          if (type == 'recovery') {
            return const ResetPasswordConfirmScreen();
          }
          return const ResetPasswordScreen();
        },
      ),
      GoRoute(
        path: '/auth/find-username',
        name: 'find-username',
        builder: (context, state) => const FindUsernameScreen(),
      ),

      // 승인 대기
      GoRoute(
        path: '/pending-approval',
        name: 'pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),

      // 메인
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => buildTossTransitionPage(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),

      // 프로필
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => buildTossTransitionPage(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        pageBuilder: (context, state) => buildTossSlideUpTransitionPage(
          context: context,
          state: state,
          child: const EditProfileScreen(),
        ),
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
        pageBuilder: (context, state) => buildTossTransitionPage(
          context: context,
          state: state,
          child: const ClassroomListScreen(),
        ),
      ),
      GoRoute(
        path: '/classrooms/create',
        name: 'classroom-create',
        pageBuilder: (context, state) => buildTossSlideUpTransitionPage(
          context: context,
          state: state,
          child: const ClassroomFormScreen(),
        ),
      ),
      GoRoute(
        path: '/classrooms/:id',
        name: 'classroom-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return buildTossTransitionPage(
            context: context,
            state: state,
            child: ClassroomDetailScreen(classroomId: id),
          );
        },
      ),
      GoRoute(
        path: '/classrooms/:id/edit',
        name: 'classroom-edit',
        builder: (context, state) {
          final classroom = state.extra as Classroom?;
          return ClassroomFormScreen(classroom: classroom);
        },
      ),

      // 예약
      GoRoute(
        path: '/reservations/my',
        name: 'my-reservations',
        pageBuilder: (context, state) => buildTossTransitionPage(
          context: context,
          state: state,
          child: const MyReservationsScreen(),
        ),
      ),
      GoRoute(
        path: '/reservations/:classroomId',
        name: 'reservation',
        pageBuilder: (context, state) {
          final classroomId = state.pathParameters['classroomId']!;
          final classroom = state.extra as Classroom?;
          return buildTossTransitionPage(
            context: context,
            state: state,
            child: ReservationScreen(
              classroomId: classroomId,
              classroom: classroom,
            ),
          );
        },
      ),

      // 설정/법적 문서
      GoRoute(
        path: '/settings/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/settings/business-info',
        name: 'business-info',
        builder: (context, state) => const BusinessInfoScreen(),
      ),
    ],
  );
}
