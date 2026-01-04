/// 환경 설정
class Environment {
  Environment._();

  /// 현재 환경
  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Supabase URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase Anon Key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// 개발 환경 여부
  static bool get isDevelopment => current == 'development';

  /// 스테이징 환경 여부
  static bool get isStaging => current == 'staging';

  /// 프로덕션 환경 여부
  static bool get isProduction => current == 'production';

  /// Preview 환경 여부
  static bool get isPreview => current == 'preview';

  /// 디버그 모드 여부
  static bool get isDebugMode => isDevelopment || isStaging || isPreview;
}
