import '../repositories/dashboard_repository.dart';

class DashboardController {
  final DashboardRepository repository;

  DashboardController({required this.repository});

  Future<dynamic> getOverview() async {
    return await repository.getOverview();
  }

  Future<dynamic> getRisks() async {
    return await repository.getRisks();
  }

  Future<dynamic> getDecisions() async {
    return await repository.getDecisions();
  }

  Future<dynamic> getAlerts() async {
    return await repository.getAlerts();
  }

  Future<dynamic> getZone({
    required String zoneId,
  }) async {
    return await repository.getZone(
      zoneId: zoneId,
    );
  }

  Future<dynamic> getRecipientsCount() async {
    return await repository.getRecipientsCount();
  }
}
