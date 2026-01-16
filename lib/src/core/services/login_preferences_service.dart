import 'package:shared_preferences/shared_preferences.dart';

/// 로그인 관련 설정을 로컬에 저장하는 서비스
///
/// - 아이디 저장: 마지막으로 로그인한 아이디를 저장
/// - 자동 로그인: 자동 로그인 설정 (비밀번호는 저장하지 않음, 세션 유지만)
class LoginPreferencesService {
  static const String _keyRememberUsername = 'remember_username';
  static const String _keySavedUsername = 'saved_username';
  static const String _keyAutoLogin = 'auto_login';

  /// 아이디 저장 설정 조회
  static Future<bool> getRememberUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberUsername) ?? false;
  }

  /// 아이디 저장 설정 저장
  static Future<void> setRememberUsername(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberUsername, value);

    // 저장 해제 시 저장된 아이디도 삭제
    if (!value) {
      await prefs.remove(_keySavedUsername);
    }
  }

  /// 저장된 아이디 조회
  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberUsername = prefs.getBool(_keyRememberUsername) ?? false;
    if (!rememberUsername) return null;
    return prefs.getString(_keySavedUsername);
  }

  /// 아이디 저장
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySavedUsername, username);
  }

  /// 자동 로그인 설정 조회
  static Future<bool> getAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoLogin) ?? false;
  }

  /// 자동 로그인 설정 저장
  static Future<void> setAutoLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLogin, value);
  }

  /// 모든 로그인 설정 초기화 (로그아웃 시)
  static Future<void> clearAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLogin, false);
    // 아이디 저장 설정은 유지, 자동 로그인만 해제
  }

  /// 모든 로그인 설정 완전 초기화 (계정 삭제 시)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberUsername);
    await prefs.remove(_keySavedUsername);
    await prefs.remove(_keyAutoLogin);
  }
}
