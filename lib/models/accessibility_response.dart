class AccessibilityResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic> data;

  AccessibilityResponse({
    required this.success,
    this.message,
    this.data = const {},
  });

  factory AccessibilityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccessibilityResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : {},
    );
  }
}
