class RiskSnapshot {
  final String country;
  final String zone;
  final String hazard;
  final double score;
  final String level;
  final List<String> reasons;
  final double? latitude;
  final double? longitude;

  RiskSnapshot({
    required this.country,
    required this.zone,
    required this.hazard,
    required this.score,
    required this.level,
    required this.reasons,
    this.latitude,
    this.longitude,
  });

  factory RiskSnapshot.fromJson(Map<String, dynamic> json) {
    final location = json['location'];

    double? latitude;
    double? longitude;

    if (location is Map<String, dynamic>) {
      latitude = _toDouble(
        location['latitude'] ?? location['lat'],
      );

      longitude = _toDouble(
        location['longitude'] ?? location['lng'],
      );
    }

    return RiskSnapshot(
      country: json['country']?.toString() ?? '',
      zone: json['zone']?.toString() ??
          json['zone_id']?.toString() ??
          '',
      hazard: json['hazard']?.toString() ?? '',
      score: _toDouble(
            json['score'] ?? json['risk_score'],
          ) ??
          0.0,
      level: json['level']?.toString() ??
          json['risk_level']?.toString() ??
          'low',
      reasons: List<String>.from(
        json['reasons'] ?? [],
      ),
      latitude: latitude,
      longitude: longitude,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}
