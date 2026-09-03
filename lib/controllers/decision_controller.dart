import '../models/decision.dart';
import '../repositories/decision_repository.dart';

class DecisionController {
  final DecisionRepository repository;

  DecisionController({required this.repository});

  Future<DecisionRequest> createDecisionRequest({
    required String hazard,
    required String zoneId,
    required int riskScore,
    required String riskLevel,
    required double confidence,
    List<CommunityEvidence>? evidence,
  }) async {
    return await repository.createDecisionRequest(
        'hazard': hazard,
        'zone_id': zoneId,
        'risk_score': riskScore,
        'risk_level': riskLevel,
        'confidence': confidence,
        'evidence': evidence,
    );
  }
}
