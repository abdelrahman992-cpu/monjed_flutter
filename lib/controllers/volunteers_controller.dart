import '../services/api_service.dart';
import '../models/Accessibility_Volunteer_RescueRobot_Models.dart';
class VolunteersController {
  final ApiService api = ApiService();

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

  Future<dynamic> updateAvailability(
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
}
