import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
