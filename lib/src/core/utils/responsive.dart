import 'package:flutter/material.dart';

/// 반응형 레이아웃 유틸리티
class Responsive {
  Responsive._();

  /// 모바일 최대 너비
  static const double mobileMaxWidth = 600;

  /// 태블릿 최대 너비
  static const double tabletMaxWidth = 1024;

  /// 데스크톱 최소 너비
  static const double desktopMinWidth = 1024;

  /// 모바일 여부
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// 태블릿 여부
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < desktopMinWidth;
  }

  /// 데스크톱 여부
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  /// 화면 너비에 따른 값 반환
  static T valueWhen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// 그리드 열 개수
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// 최대 콘텐츠 너비
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 900;
    return double.infinity;
  }
}

/// 반응형 빌더
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && desktop != null) {
      return desktop!(context);
    } else if (Responsive.isTablet(context) && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

/// 반응형 패딩
class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.valueWhen(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

/// 중앙 정렬 컨테이너 (최대 너비 제한)
class CenteredContainer extends StatelessWidget {
  final Widget child;

  const CenteredContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
