import '../models/risk_assessment.dart';
import '../services/api_service.dart';

class RiskRepository {
  final ApiService apiService;

  RiskRepository({required this.apiService});

  Future<RiskAssessment> calculateFloodRisk({
    required String zoneId,
    required double rainfall1hMm,
    required double rainfall24hMm,
    double? previousRainfall24hMm,
    int dataAgeMinutes = 0,
  }) async {
    final response = await apiService.post(
      '/risk/flood',
      body: {
        'zone_id': zoneId,
        'rainfall_1h_mm': rainfall1hMm,
        'rainfall_24h_mm': rainfall24hMm,
        'previous_rainfall_24h_mm': previousRainfall24hMm,
        'data_age_minutes': dataAgeMinutes,
      },
    );

    return RiskAssessment.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
