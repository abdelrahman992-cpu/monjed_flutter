import '../models/risk_assessment.dart';
import '../repositories/risk_repository.dart';

class RiskController {
  final RiskRepository repository;

  RiskController({required this.repository});

  Future<RiskAssessment> calculateFloodRisk({
    required String zoneId,
    required double rainfall1hMm,
    required double rainfall24hMm,
    double? previousRainfall24hMm,
    int dataAgeMinutes = 0,
  }) async {
    return await repository.calculateFloodRisk(
      zoneId: zoneId,
      rainfall1hMm: rainfall1hMm,
      rainfall24hMm: rainfall24hMm,
      previousRainfall24hMm: previousRainfall24hMm,
      dataAgeMinutes: dataAgeMinutes,
    );
  }
}
