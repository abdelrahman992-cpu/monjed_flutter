import '../models/assistance_request.dart';
import '../repositories/assistance_repository.dart';

class AssistanceController {
  final AssistanceRepository repository;

  AssistanceController({required this.repository});

  Future<AssistanceRequest> createAssistanceRequest({
    required String zoneId,
    required String location,
    double? latitude,
    double? longitude,
    required String hazard,
    required String requestType,
    required String priority,
    required String description,
  }) async {
    return await repository.createAssistanceRequest(
      zoneId: zoneId,
      location: location,
      latitude: latitude,
      longitude: longitude,
      hazard: hazard,
      requestType: requestType,
      priority: priority,
      description: description,
    );
  }
}
