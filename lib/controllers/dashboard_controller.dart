import '../services/api_service.dart';
class DashboardController {
  final ApiService api = ApiService();

  Future<dynamic> getOverview() async {
    return await api.get(
      '/dashboard/overview',
    );
  }

  Future<dynamic> getRisks() async {
    return await api.get(
      '/dashboard/risks',
    );
  }

  Future<dynamic> getDecisions() async {
    return await api.get(
      '/dashboard/decisions',
    );
  }

  Future<dynamic> getAlerts() async {
    return await api.get(
      '/dashboard/alerts',
    );
  }

  Future<dynamic> getZone(
    String zoneId,
  ) async {
    return await api.get(
      '/dashboard/zones/$zoneId',
    );
  }

  Future<dynamic> getRecipientsCount() async {
    return await api.get(
      '/dashboard/recipients/count',
    );
  }
}
