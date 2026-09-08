import '../core/network/api_service.dart';

class AssistanceController {
  final ApiService api = ApiService();

  Future<dynamic> getRequests() async {
    return await api.get('/assistance/requests');
  }

  Future<dynamic> getPendingRequests() async {
    return await api.get('/assistance/requests/pending');
  }

  Future<dynamic> getRequest(String requestId) async {
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
