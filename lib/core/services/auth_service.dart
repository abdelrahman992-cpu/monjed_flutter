import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _sessionKey = 'monjed_logged_in';
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';

  static bool isLoggedIn = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final hasFlag = prefs.getBool(_sessionKey) ?? false;
    final token = prefs.getString(_tokenKey);

    isLoggedIn = hasFlag || (token != null && token.isNotEmpty);

    if (isLoggedIn && !hasFlag) {
      await prefs.setBool(_sessionKey, true);
    }
  }

  static Future<void> login() async {
    isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<void> logout() async {
    isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }
}
