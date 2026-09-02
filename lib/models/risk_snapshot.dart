class RiskSnapshot {
  final String country;
  final String zone;
  final String hazard;
  final double score;
  final String level;

  RiskSnapshot({
    required this.country,
    required this.zone,
    required this.hazard,
    required this.score,
    required this.level,
  });

  factory RiskSnapshot.fromJson(Map<String, dynamic> json) {
    return RiskSnapshot(
      country: json['country'] ?? '',
      zone: json['zone'] ?? '',
      hazard: json['hazard'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      level: json['level'] ?? '',
    );
  }
}
