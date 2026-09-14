import '../services/api_service.dart';
class AssistanceController {
  final ApiService api = ApiService();

  Future<dynamic> createDistress(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/assistance/distress',
      body: body,
    );
  }

  Future<dynamic> registerVolunteer(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/assistance/volunteers',
      body: body,
    );
  }

  Future<dynamic> getVolunteers() async {
    return await api.get(
      '/assistance/volunteers',
    );
  }

  Future<dynamic> updateVolunteerAvailability(
    String volunteerId,
    Map<String, dynamic> body,
  ) async {
    return await api.patch(
      '/assistance/volunteers/$volunteerId',
      body: body,
    );
  }

  Future<dynamic> getVolunteerRequests(
    String volunteerId,
  ) async {
    return await api.get(
      '/assistance/volunteers/$volunteerId/requests',
    );
  }

  Future<dynamic> createRequest(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/assistance/requests',
      body: body,
    );
  }

  Future<dynamic> getRequests() async {
    return await api.get(
      '/assistance/requests',
    );
  }

  Future<dynamic> getPendingRequests() async {
    return await api.get(
      '/assistance/requests/pending',
    );
  }

  Future<dynamic> getRequest(
    String requestId,
  ) async {
    return await api.get(
      '/assistance/requests/$requestId',
    );
  }

  Future<dynamic> matchRequest(
    String requestId,
  ) async {
    return await api.post(
      '/assistance/requests/$requestId/match',
    );
  }

  Future<dynamic> startRequest(
    String requestId,
  ) async {
    return await api.post(
      '/assistance/requests/$requestId/start',
    );
  }

  Future<dynamic> resolveRequest(
    String requestId,
  ) async {
    return await api.post(
      '/assistance/requests/$requestId/resolve',
    );
  }
}
