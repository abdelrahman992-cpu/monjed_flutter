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

  // =========================
  // Get Reports
  // =========================

  Future<List<CommunityReportRecord>> getReports({
    String? zoneId,
    bool? verified,
    bool? resolved,
  }) async {
    String endpoint = '/api/community-reports';

    final queryParameters = <String, String>{};

    if (zoneId != null) {
      queryParameters['zone_id'] = zoneId;
    }

    if (verified != null) {
      queryParameters['verified'] = verified.toString();
    }

    if (resolved != null) {
      queryParameters['resolved'] = resolved.toString();
    }

    if (queryParameters.isNotEmpty) {
      endpoint +=
          '?' +
          Uri(queryParameters: queryParameters).query;
    }

    final response = await apiService.get(endpoint);

    return (response as List)
        .map(
          (item) => CommunityReportRecord.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================
  // Verify Report
  // =========================

  Future<CommunityReportRecord> verifyReport({
    required String reportId,
  }) async {
    final response = await apiService.patch(
      '/api/community-reports/$reportId/verify',
    );

    return CommunityReportRecord.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // =========================
  // Resolve Report
  // =========================

  Future<CommunityReportRecord> resolveReport({
    required String reportId,
  }) async {
    final response = await apiService.patch(
      '/api/community-reports/$reportId/resolve',
    );

    return CommunityReportRecord.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // =========================
  // Get Recent Reports
  // =========================

  Future<List<CommunityReportRecord>> getRecentReports({
    required String zoneId,
  }) async {
    final response = await apiService.get(
      '/api/community-reports/recent/$zoneId',
    );

    return (response as List)
        .map(
          (item) => CommunityReportRecord.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
