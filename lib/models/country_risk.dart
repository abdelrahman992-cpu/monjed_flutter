class CountryRisk {
  final String country;
  final String zone;
  final String hazard;
  final int score;
  final String level;
  final List<String> reasons;
  final String source;
  final DateTime? sourceTimestamp;
  final DateTime? createdAt;

  const CountryRisk({
    required this.country,
    required this.zone,
    required this.hazard,
    required this.score,
    required this.level,
    required this.reasons,
    required this.source,
    this.sourceTimestamp,
    this.createdAt,
  });

  factory CountryRisk.fromJson(Map<String, dynamic> json) {
    return CountryRisk(
      country: json['country'] ?? '',
      zone: json['zone'] ?? '',
      hazard: json['hazard'] ?? '',
      score: (json['score'] ?? 0) as int,
      level: json['level'] ?? 'low',
      reasons: List<String>.from(json['reasons'] ?? []),
      source: json['source'] ?? '',
      sourceTimestamp: json['source_timestamp'] != null
          ? DateTime.tryParse(json['source_timestamp'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
