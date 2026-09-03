import '../models/dashboard.dart';
import '../services/api_service.dart';

class DashboardRepository {
  final ApiService apiService;

  DashboardRepository({required this.apiService});

  Future<dynamic> getOverview() async {
    final response = await apiService.get(
      '/dashboard/overview',
    );

    return response;
  }

  Future<dynamic> getRisks() async {
    final response = await apiService.get(
      '/dashboard/risks',
    );

    return response;
  }

  Future<dynamic> getDecisions() async {
    final response = await apiService.get(
      '/dashboard/decisions',
    );

    return response;
  }

  Future<dynamic> getAlerts() async {
    final response = await apiService.get(
      '/dashboard/alerts',
    );

    return response;
  }

  Future<dynamic> getZone({
    required String zoneId,
  }) async {
    final response = await apiService.get(
      '/dashboard/zones/$zoneId',
    );

    return response;
  }

  Future<dynamic> getRecipientsCount() async {
    final response = await apiService.get(
      '/dashboard/recipients/count',
    );

    return response;
  }
}
