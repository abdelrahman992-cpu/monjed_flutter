import '../models/report.dart';
import '../repositories/reports_repository.dart';

class ReportsController {
  final ReportsRepository repository;

  ReportsController({required this.repository});

  Future<CommunityReportAnalysis> analyzeReport({
    required String reportText,
    required String zoneId,
    required String location,
    double? latitude,
    double? longitude,
    String? reporterId,
  }) async {
    return await repository.analyzeReport(
      reportText: reportText,
      zoneId: zoneId,
      location: location,
      latitude: latitude,
      longitude: longitude,
      reporterId: reporterId,
    );
  }
}
