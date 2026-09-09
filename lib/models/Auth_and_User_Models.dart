```text
lib/models/auth/

auth_models.dart
```

```dart
// ============================================================
// ENUMS
// ============================================================

enum UserRole {
  citizen,
  volunteer,
  admin,
}

enum PreferredLanguage {
  en,
  ar,
  sw,
  fr,
}

// ============================================================
// REGISTER REQUEST
// POST /auth/register
// ============================================================

class RegisterRequest {
  final String displayName;
  final String email;
  final String password;
  final String? phone;
  final UserRole role;
  final String? zoneId;
  final String? country;
  final PreferredLanguage preferredLanguage;
  final List<String> accessibilityNeeds;
  final List<String> skills;
  final bool notificationConsent;

  RegisterRequest({
    required this.displayName,
    required this.email,
    required this.password,
    this.phone,
    this.role = UserRole.citizen,
    this.zoneId,
    this.country,
    this.preferredLanguage = PreferredLanguage.en,
    this.accessibilityNeeds = const [],
    this.skills = const [],
    this.notificationConsent = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role.name,
      'zone_id': zoneId,
      'country': country,
      'preferred_language': preferredLanguage.name,
      'accessibility_needs': accessibilityNeeds,
      'skills': skills,
      'notification_consent': notificationConsent,
    };
  }
}

// ============================================================
// LOGIN REQUEST
// POST /auth/login
// POST /auth/admin
// ============================================================

class LoginRequest {
  final String identifier;
  final String password;

  LoginRequest({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
    };
  }
}

// ============================================================
// VERIFY OTP
// POST /auth/verify-otp
// ============================================================

class VerifyOTPRequest {
  final String userId;
  final String code;

  VerifyOTPRequest({
    required this.userId,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'code': code,
    };
  }
}

// ============================================================
// OTP RESPONSE
// ============================================================

class OTPRequiredResponse {
  final bool requiresOtp;
  final String userId;
  final String email;
  final String message;

  OTPRequiredResponse({
    this.requiresOtp = true,
    required this.userId,
    required this.email,
    this.message =
        'A 6-digit verification code has been sent to your email.',
  });

  factory OTPRequiredResponse.fromJson(Map<String, dynamic> json) {
    return OTPRequiredResponse(
      requiresOtp: json['requires_otp'] ?? true,
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      message: json['message'] ??
          'A 6-digit verification code has been sent to your email.',
    );
  }
}

// ============================================================
// AUTH USER RESPONSE
// ============================================================

class AuthUserResponse {
  final String userId;
  final String? displayName;
  final String role;
  final String? email;
  final String? phone;
  final String? zoneId;
  final String? country;
  final String preferredLanguage;

  AuthUserResponse({
    required this.userId,
    this.displayName,
    required this.role,
    this.email,
    this.phone,
    this.zoneId,
    this.country,
    this.preferredLanguage = 'en',
  });

  factory AuthUserResponse.fromJson(Map<String, dynamic> json) {
    return AuthUserResponse(
      userId: json['user_id'] ?? '',
      displayName: json['display_name'],
      role: json['role'] ?? '',
      email: json['email'],
      phone: json['phone'],
      zoneId: json['zone_id'],
      country: json['country'],
      preferredLanguage:
          json['preferred_language'] ?? 'en',
    );
  }
}

// ============================================================
// AUTH RESPONSE
// ============================================================

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final AuthUserResponse user;

  AuthResponse({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      user: AuthUserResponse.fromJson(
        json['user'] ?? {},
      ),
    );
  }
}

// ============================================================
// CONTACT REQUEST
// POST /auth/contact
// ============================================================

class ContactRequest {
  final String name;
  final String email;
  final String? phone;
  final String? subject;
  final String message;

  ContactRequest({
    required this.name,
    required this.email,
    this.phone,
    this.subject,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
    };
  }
}

// ============================================================
// CONTACT RESPONSE
// ============================================================

class ContactResponse {
  final String contactId;
  final String status;
  final DateTime createdAt;

  ContactResponse({
    required this.contactId,
    this.status = 'received',
    required this.createdAt,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      contactId: json['contact_id'] ?? '',
      status: json['status'] ?? 'received',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// ============================================================
// USER LIST ITEM
// GET /users
// ============================================================

class UserListItem {
  final String userId;
  final String? displayName;
  final String? role;
  final String? email;
  final String? phone;
  final String? zoneId;
  final String? country;
  final String preferredLanguage;
  final bool notificationConsent;
  final bool smsEligible;

  UserListItem({
    required this.userId,
    this.displayName,
    this.role,
    this.email,
    this.phone,
    this.zoneId,
    this.country,
    this.preferredLanguage = 'en',
    this.notificationConsent = false,
    this.smsEligible = false,
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      userId: json['user_id'] ?? '',
      displayName: json['display_name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      zoneId: json['zone_id'],
      country: json['country'],
      preferredLanguage:
          json['preferred_language'] ?? 'en',
      notificationConsent:
          json['notification_consent'] ?? false,
      smsEligible:
          json['sms_eligible'] ?? false,
    );
  }
}

// ============================================================
// USER PROFILE RESPONSE
// ============================================================

class UserProfileResponse {
  final String userId;
  final String? displayName;
  final String? role;
  final String? roleTitle;
  final String? organization;
  final String? workEmail;
  final String? phone;
  final String? zoneId;
  final String? country;
  final String preferredLanguage;
  final List<String> accessibilityNeeds;
  final bool notificationConsent;

  UserProfileResponse({
    required this.userId,
    this.displayName,
    this.role,
    this.roleTitle,
    this.organization,
    this.workEmail,
    this.phone,
    this.zoneId,
    this.country,
    this.preferredLanguage = 'en',
    this.accessibilityNeeds = const [],
    this.notificationConsent = false,
  });

  factory UserProfileResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfileResponse(
      userId: json['user_id'] ?? '',
      displayName: json['display_name'],
      role: json['role'],
      roleTitle: json['role_title'],
      organization: json['organization'],
      workEmail: json['work_email'],
      phone: json['phone'],
      zoneId: json['zone_id'],
      country: json['country'],
      preferredLanguage:
          json['preferred_language'] ?? 'en',
      accessibilityNeeds:
          List<String>.from(
        json['accessibility_needs'] ?? [],
      ),
      notificationConsent:
          json['notification_consent'] ?? false,
    );
  }
}

// ============================================================
// USER PROFILE UPDATE
// PATCH /users/{user_id}/profile
// ============================================================

class UserProfileUpdate {
  final String? displayName;
  final String? roleTitle;
  final String? organization;
  final String? workEmail;
  final String? phone;
  final String? zoneId;
  final String? country;
  final PreferredLanguage? preferredLanguage;
  final List<String>? accessibilityNeeds;
  final bool? notificationConsent;

  UserProfileUpdate({
    this.displayName,
    this.roleTitle,
    this.organization,
    this.workEmail,
    this.phone,
    this.zoneId,
    this.country,
    this.preferredLanguage,
    this.accessibilityNeeds,
    this.notificationConsent,
  });

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'role_title': roleTitle,
      'organization': organization,
      'work_email': workEmail,
      'phone': phone,
      'zone_id': zoneId,
      'country': country,
      'preferred_language':
          preferredLanguage?.name,
      'accessibility_needs':
          accessibilityNeeds,
      'notification_consent':
          notificationConsent,
    };
  }
}
```