import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 토스 스타일 페이지 전환 빌더
///
/// 슬라이드 + 페이드 조합으로 부드러운 화면 전환
CustomTransitionPage<T> buildTossTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 토스 느낌의 물리적 곡선 (시작은 빠르고 끝은 부드럽게)
      const curve = Curves.easeOutQuart;

      // 살짝만 이동 (5%)
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curve));

      // 페이드 인
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: curve));

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}

/// 페이드만 적용하는 전환 (모달, 다이얼로그 등)
CustomTransitionPage<T> buildTossFadeTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 150),
  );
}

/// 아래에서 위로 슬라이드 (바텀시트 스타일)
CustomTransitionPage<T> buildTossSlideUpTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeOutCubic;

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curve));

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: curve));

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}
