class AuthService {
  // مؤقتًا للتجربة.
  // بعد ما نوصل Login الحقيقي هنخليها تقرأ
  // الـ token/session من SharedPreferences أو secure storage.

  static bool isLoggedIn = false;

  static void login() {
    isLoggedIn = true;
  }

  static void logout() {
    isLoggedIn = false;
  }
}
