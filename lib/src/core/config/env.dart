/// 환경 변수 처리
class Env {
  Env._();

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

  /// 환경 (development, staging, production)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// 개발 환경인지 확인
  static bool get isDevelopment => environment == 'development';

  /// 프로덕션 환경인지 확인
  static bool get isProduction => environment == 'production';

  /// 환경 변수가 올바르게 설정되었는지 검증
  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL이 설정되지 않았습니다.');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY가 설정되지 않았습니다.');
    }
  }
}
