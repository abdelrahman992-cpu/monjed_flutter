import '../models/assistance_request.dart';
import '../services/api_service.dart';

class AssistanceRepository {
  final ApiService apiService;

  AssistanceRepository({required this.apiService});

  Future<AssistanceRequest> createAssistanceRequest({
    required String zoneId,
    required String location,
    required String hazard,
    required String requestType,
    required String priority,
    required String description,
  }) async {
    final response = await apiService.post(
      '/assistance/requests',
      body: {
        'zone_id': zoneId,
        'location': location,
        'hazard': hazard,
        'request_type': requestType,
        'priority': priority,
        'description': description,
      },
    );

    return AssistanceRequest.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
