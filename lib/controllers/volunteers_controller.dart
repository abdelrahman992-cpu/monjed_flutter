import '../core/network/api_service.dart';

class VolunteersController {
  final ApiService api = ApiService();

  Future<dynamic> getVolunteers() async {
    return await api.get('/assistance/volunteers');
  }

  Future<dynamic> getVolunteer(String volunteerId) async {
    return await api.get(
      '/assistance/volunteers/$volunteerId',
    );
  }

  Future<dynamic> getVolunteerRequests(
    String volunteerId,
  ) async {
    return await api.get(
      '/assistance/volunteers/$volunteerId/requests',
    );
  }
}
