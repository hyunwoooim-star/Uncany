import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app.dart';
import 'src/core/config/env.dart';
import 'src/core/providers/supabase_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 날짜 포맷 초기화 (실패해도 앱 실행)
  try {
    await initializeDateFormatting('ko_KR', null);
  } catch (e) {
    // locale 데이터 로드 실패 시 무시
  }

  // 폰트 사전 로딩 (FOIT 방지: 네모 박스 표시 방지)
  try {
    await _preloadFonts();
  } catch (e) {
    // 폰트 로딩 실패해도 앱 실행 (fallback 폰트 사용)
  }

  // 환경 변수 검증
  Env.validate();

  // Supabase 초기화
  await initializeSupabase(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

/// Noto Sans KR 폰트 사전 로딩
/// - 첫 방문 시 네모 박스(□) 표시 방지
/// - Web: Google Fonts CDN에서 다운로드
/// - Mobile: 추후 로컬 assets 사용 예정
Future<void> _preloadFonts() async {
  // 주로 사용하는 font weight만 미리 로드
  final fontFutures = [
    GoogleFonts.notoSansKr(fontWeight: FontWeight.normal).fontFamily,
    GoogleFonts.notoSansKr(fontWeight: FontWeight.w500).fontFamily,
    GoogleFonts.notoSansKr(fontWeight: FontWeight.w600).fontFamily,
    GoogleFonts.notoSansKr(fontWeight: FontWeight.bold).fontFamily,
  ];

  await Future.wait(fontFutures.map((f) => Future.value(f)));
}
