import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'toss_colors.dart';

/// 토스(Toss) 스타일 앱 테마
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 색상 스키마
      colorScheme: ColorScheme.light(
        primary: TossColors.primary,
        surface: TossColors.surface,
        error: TossColors.error,
      ),

      // 배경색
      scaffoldBackgroundColor: TossColors.background,

      // 타이포그래피
      textTheme: _buildTextTheme(),

      // 앱바
      appBarTheme: AppBarTheme(
        backgroundColor: TossColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TossColors.textMain,
        ),
        iconTheme: IconThemeData(
          color: TossColors.textMain,
        ),
      ),

      // 카드
      cardTheme: CardTheme(
        color: TossColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 버튼
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TossColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TossColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: TossColors.textSub.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: TossColors.textSub.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: TossColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: TossColors.primary,
        surface: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: _buildTextTheme(isDark: true),
    );
  }

  static TextTheme _buildTextTheme({bool isDark = false}) {
    final baseColor = isDark ? Colors.white : TossColors.textMain;
    final subColor = isDark ? Colors.white70 : TossColors.textSub;

    return TextTheme(
      // 헤딩
      headlineLarge: GoogleFonts.notoSansKr(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.notoSansKr(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.notoSansKr(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.4,
      ),

      // 본문
      bodyLarge: GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: subColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: subColor,
        height: 1.5,
      ),

      // 라벨
      labelLarge: GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
    );
  }
}
