import 'package:flutter/material.dart';

/// 토스(Toss) 스타일 컬러 팔레트
class TossColors {
  TossColors._();

  // Primary
  static const Color primary = Color(0xFF3182F6); // 토스 블루

  // Background & Surface
  static const Color background = Color(0xFFF2F4F6); // 라이트 그레이
  static const Color surface = Color(0xFFFFFFFF); // 화이트

  // Text
  static const Color textMain = Color(0xFF191F28); // 다크 그레이
  static const Color textSub = Color(0xFF4E5968); // 미디엄 그레이

  // Status
  static const Color error = Color(0xFFF04452); // 레드
  static const Color success = Color(0xFF05C075); // 그린
  static const Color warning = Color(0xFFFFB800); // 옐로우
  static const Color info = Color(0xFF3182F6); // 블루

  // Divider
  static const Color divider = Color(0xFFE5E8EB);

  // Disabled
  static const Color disabled = Color(0xFFB0B8C1);
}
