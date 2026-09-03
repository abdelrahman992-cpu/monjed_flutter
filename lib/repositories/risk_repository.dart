import '../models/risk_assessment.dart';
import '../services/api_service.dart';
import '../models/country_risk.dart';

class RiskRepository {
  final ApiService apiService;

  RiskRepository({required this.apiService});

  // =========================
  // Flood Risk
  // =========================

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

  // =========================
  // Earthquake Risk
  // =========================

  Future<RiskAssessment> calculateEarthquakeRisk({
    required String zoneId,
    required double magnitude,
    required double depthKm,
    required double distanceKm,
    int dataAgeMinutes = 0,
    bool sourceVerified = true,
  }) async {
    final response = await apiService.post(
      '/risk/earthquake',
      body: {
        'zone_id': zoneId,
        'magnitude': magnitude,
        'depth_km': depthKm,
        'distance_km': distanceKm,
        'data_age_minutes': dataAgeMinutes,
        'source_verified': sourceVerified,
      },
    );

    return RiskAssessment.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
Future<List<CountryRisk>> getDashboardRisks() async {
  final response = await apiService.get('/dashboard/risks');

  return (response as List)
      .map(
        (item) => CountryRisk.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList();
}

}
