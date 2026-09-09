class AssistanceRequest {
  final String id;
  final String? reportId;
  final String? requestType;
  final String? country;
  final String? zone;
  final String? priority;
  final String? status;
  final String? assignedVolunteerId;
  final List<String> accessibilityNeeds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssistanceRequest({
    required this.id,
    this.reportId,
    this.requestType,
    this.country,
    this.zone,
    this.priority,
    this.status,
    this.assignedVolunteerId,
    this.accessibilityNeeds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory AssistanceRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssistanceRequest(
      id: json['request_id'] ??
          json['_id'] ??
          '',
      reportId: json['report_id'],
      requestType: json['request_type'],
      country: json['country'],
      zone: json['zone'],
      priority: json['priority'],
      status: json['status'],
      assignedVolunteerId:
          json['assigned_volunteer_id'],
      accessibilityNeeds:
          json['accessibility_needs'] is List
              ? List<String>.from(
                  json['accessibility_needs'],
                )
              : [],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
