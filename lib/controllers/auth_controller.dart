import '../models/Auth_and_User_Models.dart';
import '../services/api_service.dart';
import '../core/services/auth_service.dart';

class AuthController {
  final ApiService api = ApiService();

  // ==========================================================
  // REGISTER
  // ==========================================================

  Future<OTPRequiredResponse> register({
    required String displayName,
    required String email,
    required String password,
    String? phone,
    String role = 'citizen',
    String? zoneId,
    String? country,
    String preferredLanguage = 'en',
    List<String> accessibilityNeeds = const [],
    List<String> skills = const [],
    bool notificationConsent = true,

    // Volunteer fields
    String? vehicleType,
    int? capacity,
  }) async {
    final body = {
      'display_name': displayName,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'zone_id': zoneId,
      'country': country,
      'preferred_language': preferredLanguage,
      'accessibility_needs': accessibilityNeeds,
      'skills': skills,
      'notification_consent': notificationConsent,

      // Volunteer data
      'vehicle_type': vehicleType,
      'capacity': capacity,
    };

    // Remove nullable fields when they are null.
    body.removeWhere(
      (key, value) => value == null,
    );

    final response = await api.post(
      '/auth/register',
      body: body,
    );

    return OTPRequiredResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<dynamic> login({
    required String identifier,
    required String password,
  }) async {
    final response = await api.post(
      '/auth/login',
      body: {
        'identifier': identifier,
        'password': password,
      },
    );

    // The backend may return OTPRequiredResponse
    // or AuthResponse depending on the authentication state.

    if (response is Map<String, dynamic>) {
      if (response['requires_otp'] == true) {
        return OTPRequiredResponse.fromJson(response);
      }

      if (response['access_token'] != null) {
        final authResponse =
            AuthResponse.fromJson(response);

        await _saveAuthentication(
          authResponse,
        );

        return authResponse;
      }
    }

    return response;
  }

  // ==========================================================
  // VERIFY OTP
  // ==========================================================

  Future<AuthResponse> verifyOtp({
    required String userId,
    required String code,
  }) async {
    final response = await api.post(
      '/auth/verify-otp',
      body: {
        'user_id': userId,
        'code': code,
      },
    );

    final authResponse = AuthResponse.fromJson(
      Map<String, dynamic>.from(response),
    );

    // Save JWT + user data.
    await _saveAuthentication(
      authResponse,
    );

    return authResponse;
  }

  // ==========================================================
  // SAVE AUTHENTICATION
  // ==========================================================

  Future<void> _saveAuthentication(
  AuthResponse authResponse,
) async {
  // Save JWT
  await api.saveToken(
    authResponse.accessToken,
  );

  // Save user information
  await api.saveUserData(
    userId: authResponse.user.userId,
    role: authResponse.user.role,
    displayName: authResponse.user.displayName ?? '',
    email: authResponse.user.email ?? '',
    phone: authResponse.user.phone,
    zoneId: authResponse.user.zoneId,
    country: authResponse.user.country,
  );

  // Save session
  await AuthService.login();

  // Save role for navigation
  final role = authResponse.user.role.trim().toLowerCase();

  if (role.isNotEmpty) {
    await AuthService.setRole(role);
  }
}
  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    await api.logout();
  }

  // ==========================================================
  // IS LOGGED IN
  // ==========================================================

  Future<bool> isLoggedIn() async {
    final token = await api.getToken();

    return token != null && token.isNotEmpty;
  }

  // ==========================================================
  // CONTACT
  // ==========================================================

  Future<ContactResponse> contact({
    required String name,
    required String email,
    String? phone,
    String? subject,
    required String message,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
    };

    body.removeWhere(
      (key, value) => value == null,
    );

    final response = await api.post(
      '/auth/contact',
      body: body,
    );

    return ContactResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
