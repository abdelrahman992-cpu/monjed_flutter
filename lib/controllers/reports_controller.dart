import '../services/api_service.dart';
class ReportsController {
  final ApiService api = ApiService();

  Future<dynamic> getReports() async {
    return await api.get('/api/community-reports');
  }

  Future<dynamic> getRecentReports(String zoneId) async {
    return await api.get(
      '/api/community-reports/recent/$zoneId',
    );
  }

  Future<dynamic> analyzeReport(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/api/community-reports/analyze',
      body: body,
    );
  }

  Future<dynamic> submitReport(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/api/community-reports/submit',
      body: body,
    );
  }

  Future<dynamic> verifyReport(
    String reportId,
  ) async {
    return await api.post(
      '/api/community-reports/$reportId/verify',
    );
  }

  Future<dynamic> resolveReport(
    String reportId,
  ) async {
    return await api.post(
      '/api/community-reports/$reportId/resolve',
    );
  }
}
