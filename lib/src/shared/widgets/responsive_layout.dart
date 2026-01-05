import 'package:flutter/material.dart';

/// 반응형 브레이크포인트
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wideDesktop = 1440;
}

/// 최대 콘텐츠 너비 (PC에서 중앙 정렬용)
class ContentWidth {
  static const double mobile = double.infinity;
  static const double tablet = 600;
  static const double desktop = 640;
  static const double wideDesktop = 720;
}

/// 현재 디바이스 타입
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wideDesktop,
}

/// 디바이스 타입 판별
DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < Breakpoints.mobile) return DeviceType.mobile;
  if (width < Breakpoints.tablet) return DeviceType.mobile;
  if (width < Breakpoints.desktop) return DeviceType.tablet;
  if (width < Breakpoints.wideDesktop) return DeviceType.desktop;
  return DeviceType.wideDesktop;
}

/// 반응형 콘텐츠 래퍼
///
/// PC에서 콘텐츠를 중앙 정렬하고 최대 너비를 제한합니다.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);

    // 디바이스 타입에 따른 최대 너비 결정
    final effectiveMaxWidth = maxWidth ??
        switch (deviceType) {
          DeviceType.mobile => ContentWidth.mobile,
          DeviceType.tablet => ContentWidth.tablet,
          DeviceType.desktop => ContentWidth.desktop,
          DeviceType.wideDesktop => ContentWidth.wideDesktop,
        };

    // 모바일에서는 최대 너비 제한 없음
    if (effectiveMaxWidth == double.infinity || screenWidth <= effectiveMaxWidth) {
      return Container(
        color: backgroundColor,
        padding: padding,
        child: child,
      );
    }

    // PC에서 중앙 정렬
    return Container(
      color: backgroundColor,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// 반응형 Scaffold 래퍼
///
/// Scaffold의 body를 자동으로 반응형으로 감싸줍니다.
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final double? maxContentWidth;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop ||
        deviceType == DeviceType.wideDesktop;

    // PC에서 사이드 패널 배경색
    final sideColor = isDesktop
        ? Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95)
        : null;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: ResponsiveContent(
        maxWidth: maxContentWidth,
        backgroundColor: sideColor,
        child: body,
      ),
    );
  }
}

/// 반응형 값 선택
///
/// 디바이스 타입에 따라 다른 값을 반환합니다.
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
  T? wideDesktop,
}) {
  final deviceType = getDeviceType(context);
  return switch (deviceType) {
    DeviceType.mobile => mobile,
    DeviceType.tablet => tablet ?? mobile,
    DeviceType.desktop => desktop ?? tablet ?? mobile,
    DeviceType.wideDesktop => wideDesktop ?? desktop ?? tablet ?? mobile,
  };
}

/// 반응형 패딩 값
EdgeInsets responsivePadding(BuildContext context) {
  return responsiveValue(
    context,
    mobile: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(20),
    desktop: const EdgeInsets.all(24),
  );
}

/// 반응형 카드 패딩
EdgeInsets responsiveCardPadding(BuildContext context) {
  return responsiveValue(
    context,
    mobile: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(20),
    desktop: const EdgeInsets.all(24),
  );
}

/// 반응형 그리드 열 수
int responsiveGridColumns(BuildContext context) {
  return responsiveValue(
    context,
    mobile: 2,
    tablet: 3,
    desktop: 4,
    wideDesktop: 5,
  );
}

/// 반응형 폰트 크기
double responsiveFontSize(
  BuildContext context, {
  required double base,
  double? scaleTablet,
  double? scaleDesktop,
}) {
  return responsiveValue(
    context,
    mobile: base,
    tablet: base * (scaleTablet ?? 1.1),
    desktop: base * (scaleDesktop ?? 1.15),
  );
}

/// 반응형 아이콘 크기
double responsiveIconSize(BuildContext context, {double base = 24}) {
  return responsiveValue(
    context,
    mobile: base,
    tablet: base * 1.1,
    desktop: base * 1.2,
  );
}

/// 반응형 간격
double responsiveSpacing(BuildContext context, {double base = 16}) {
  return responsiveValue(
    context,
    mobile: base,
    tablet: base * 1.25,
    desktop: base * 1.5,
  );
}

/// 반응형 위젯 빌더
///
/// 디바이스 타입에 따라 다른 위젯을 빌드합니다.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// 반응형 그리드 뷰
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1,
    this.padding,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    final columns = responsiveValue(
      context,
      mobile: mobileColumns ?? 2,
      tablet: tabletColumns ?? 3,
      desktop: desktopColumns ?? 4,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
      children: children,
    );
  }
}
