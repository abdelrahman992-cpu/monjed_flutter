import '../models/decision.dart';
import '../services/api_service.dart';

class DecisionRepository {
  final ApiService apiService;

  DecisionRepository({required this.apiService});

  Future<DecisionRequest> createDecisionRequest({
    required String hazard,
    required String zoneId,
    required int riskScore,
    required String riskLevel,
    required double confidence,
    List<CommunityEvidence>? evidence,
  }) async {
    final response = await apiService.post(
      '/decision/evaluate',
      body: {
        'hazard': hazard,
        'zone_id': zoneId,
        'risk_score': riskScore,
        'risk_level': riskLevel,
        'confidence': confidence,
        'evidence': evidence,
      },
    );

    return DecisionRequest.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
