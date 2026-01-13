# 토스(Toss) 스타일 UI/UX 폴리싱 가이드

> Gemini 답변 기반 (2026-01-14)

## 핵심 원칙

토스 앱의 핵심:
- **"과하지 않은 마이크로 인터랙션"**
- **"물리적인 탄성(Bouncing)"**

---

## 1. 앱 아이콘 & 스플래시

### 패키지 추가
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.1
```

### 설정 (pubspec.yaml 하단에 추가)
```yaml
# 앱 아이콘 설정
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/Uncany.png"
  min_sdk_android: 21
  adaptive_icon_background: "#3182F6"  # 토스 블루 배경
  adaptive_icon_foreground: "assets/images/Uncany.png"

# 스플래시 화면 설정
flutter_native_splash:
  color: "#3182F6"  # 토스 블루
  image: "assets/images/splash_logo.png"  # 로고만 있는 흰색 이미지 권장
  fullscreen: true
  android_12:
    image: "assets/images/splash_logo.png"
    color: "#3182F6"
```

### 실행 명령어
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 2. 페이지 전환 애니메이션 (GoRouter)

토스는 화면이 전환될 때 묵직하면서도 빠른 CurvedAnimation 사용.

```dart
// lib/src/core/router/router_utils.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 토스 스타일 페이지 전환 (슬라이드 + 페이드)
CustomTransitionPage buildPageWithTransition<T>({
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

      var slideAnimation = Tween<Offset>(
        begin: const Offset(0.05, 0), // 5%만 이동 (너무 많이 움직이지 않음)
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: curve));

      var fadeAnimation = Tween<double>(
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
    transitionDuration: const Duration(milliseconds: 250), // 짧고 간결하게
  );
}
```

---

## 3. 버튼 터치 피드백 (TossBouncingButton)

InkWell(물결 효과)은 머티리얼 느낌이 강함.
토스는 버튼을 눌렀을 때 **"실제 물체처럼 작아지는(Scale Down)"** 효과 사용.

```dart
// lib/src/shared/widgets/toss_bouncing_button.dart

import 'package:flutter/material.dart';

class TossBouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const TossBouncingButton({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96, // 눌렀을 때 96% 크기로 축소
  });

  @override
  State<TossBouncingButton> createState() => _TossBouncingButtonState();
}

class _TossBouncingButtonState extends State<TossBouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // 매우 빠른 반응 속도
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
```

---

## 4. 로딩 스켈레톤 (Shimmer)

### 패키지 추가
```yaml
dependencies:
  shimmer: ^3.0.0
```

### 구현
```dart
// lib/src/shared/widgets/toss_skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TossSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const TossSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
```

---

## 5. 리스트 등장 애니메이션 (Staggered)

### 패키지 추가
```yaml
dependencies:
  flutter_staggered_animations: ^1.1.1
```

### 사용 예시
```dart
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

AnimationLimiter(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 20.0, // 아래에서 위로 살짝 올라옴
          child: FadeInAnimation(
            child: YourListItemWidget(item: items[index]),
          ),
        ),
      );
    },
  ),
)
```

---

## 토스 UI/UX 분석 및 팁

### 1. Spring Physics (탄성)
- 애니메이션이 끝날 때 딱 멈추지 않고 아주 미세하게 튕기거나(Over-scroll), 부드럽게 감속
- Flutter의 `BouncingScrollPhysics()`를 리스트뷰에 기본 적용

### 2. Depth (깊이감)
- 그림자를 많이 쓰지 않음
- 배경색의 미세한 차이(`#F2F4F6` vs `#FFFFFF`)와 `BorderRadius`로 계층 구분

### 3. Speed
- 애니메이션 Duration: **200ms~300ms** 가 가장 "빠릿하다"고 느껴짐
- 400ms를 넘어가면 사용자는 "느리다"고 느낌

---

## 적용 우선순위

1. **스플래시 + 앱 아이콘** - 첫인상
2. **버튼 터치 피드백** - 전체 앱에 적용
3. **페이지 전환** - GoRouter에 적용
4. **로딩 스켈레톤** - 데이터 로딩 화면
5. **리스트 애니메이션** - 목록 화면

---

## 참고 자료

- [Flutter Smooth Animated Button - Mitch Koko](https://www.youtube.com/watch?v=...)
- 토스 앱 직접 사용해보며 느낌 파악
