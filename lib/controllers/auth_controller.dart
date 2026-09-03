import '../models/auth.dart';
import '../repositories/auth_repository.dart';

class AuthController {
  final AuthRepository repository;

  AuthController({required this.repository});

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
    return await repository.register(
      displayName: displayName,
      email: email,
      password: password,
      phone: phone,
      role: role,
      zoneId: zoneId,
      country: country,
      preferredLanguage: preferredLanguage,
      accessibilityNeeds: accessibilityNeeds,
      notificationConsent: notificationConsent,
    );
  }

  // =========================
  // Login
  // =========================

  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    return await repository.login(
      identifier: identifier,
      password: password,
    );
  }

  // =========================
  // Admin Login
  // =========================

  Future<AuthResponse> adminLogin({
    required String identifier,
    required String password,
  }) async {
    return await repository.adminLogin(
      identifier: identifier,
      password: password,
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
    return await repository.sendContact(
      name: name,
      email: email,
      phone: phone,
      subject: subject,
      message: message,
    );
  }
}
