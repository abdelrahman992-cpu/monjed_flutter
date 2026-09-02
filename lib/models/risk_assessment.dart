class RiskAssessment {
  final String hazard;
  final String zoneId;
  final int riskScore;
  final String riskLevel;
  final double confidence;
  final List<String> reasons;
  final DateTime evaluatedAt;

  RiskAssessment({
    required this.hazard,
    required this.zoneId,
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    required this.reasons,
    required this.evaluatedAt,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      hazard: json['hazard'],
      zoneId: json['zone_id'],
      riskScore: json['risk_score'],
      riskLevel: json['risk_level'],
      confidence: (json['confidence'] as num).toDouble(),
      reasons: List<String>.from(json['reasons'] ?? []),
      evaluatedAt: DateTime.parse(json['evaluated_at']),
    );
  }
}
