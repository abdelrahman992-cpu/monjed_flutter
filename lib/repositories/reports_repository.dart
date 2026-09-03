import '../models/report.dart';
import '../services/api_service.dart';

class ReportsRepository {
  final ApiService apiService;

  ReportsRepository({required this.apiService});

  // =========================
  // Analyze Report
  // =========================

  Future<CommunityReportAnalysis> analyzeReport({
    required String reportText,
    required String zoneId,
    required String location,
    double? latitude,
    double? longitude,
    String? reporterId,
  }) async {
    final response = await apiService.post(
      '/api/community-reports/analyze',
      body: {
        'report_text': reportText,
        'zone_id': zoneId,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'reporter_id': reporterId,
      },
    );

    return CommunityReportAnalysis.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // =========================
  // Submit Report
  // =========================

  Future<CommunityReportRecord> submitReport({
    required String reportText,
    required String zoneId,
    required String location,
    double? latitude,
    double? longitude,
    String? reporterId,
  }) async {
    final response = await apiService.post(
      '/api/community-reports/submit',
      body: {
        'report_text': reportText,
        'zone_id': zoneId,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'reporter_id': reporterId,
      },
    );

    return CommunityReportRecord.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
