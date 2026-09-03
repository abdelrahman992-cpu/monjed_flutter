import '../models/auth.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});

  // =========================
  // Register
  // =========================

  Future<AuthResponse> register({
    required String displayName,
    required String email,
    required String password,
    String? phone,
    String role = 'citizen',
    String? zoneId,
    String? country,
    String preferredLanguage = 'en',
    List<String>? accessibilityNeeds,
    bool notificationConsent = true,
  }) async {
    final response = await apiService.post(
      '/auth/register',
      body: {
        'display_name': displayName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
        'zone_id': zoneId,
        'country': country,
        'preferred_language': preferredLanguage,
        'accessibility_needs': accessibilityNeeds ?? [],
        'notification_consent': notificationConsent,
      },
    );

    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // =========================
  // Login
  // =========================

  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await apiService.post(
      '/auth/login',
      body: {
        'identifier': identifier,
        'password': password,
      },
    );

    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // =========================
  // Admin Login
  // =========================

  Future<AuthResponse> adminLogin({
    required String identifier,
    required String password,
  }) async {
    final response = await apiService.post(
      '/auth/admin',
      body: {
        'identifier': identifier,
        'password': password,
      },
    );

    return AuthResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // =========================
  // Contact / Support
  // =========================

  Future<ContactResponse> sendContact({
    required String name,
    required String email,
    String? phone,
    String? subject,
    required String message,
  }) async {
    final response = await apiService.post(
      '/auth/contact',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'subject': subject,
        'message': message,
      },
    );

    return ContactResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
