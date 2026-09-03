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
    required this.preferredLanguage,
  });

  factory AuthUserResponse.fromJson(Map<String, dynamic> json) {
    return AuthUserResponse(
      userId: json['user_id'],
      displayName: json['display_name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      zoneId: json['zone_id'],
      country: json['country'],
      preferredLanguage: json['preferred_language'] ?? 'en',
    );
  }
}

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final AuthUserResponse user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'] ?? 'bearer',
      user: AuthUserResponse.fromJson(
        Map<String, dynamic>.from(json['user']),
      ),
    );
  }
}

class ContactResponse {
  final String contactId;
  final String status;
  final DateTime createdAt;

  ContactResponse({
    required this.contactId,
    required this.status,
    required this.createdAt,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      contactId: json['contact_id'],
      status: json['status'] ?? 'received',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
