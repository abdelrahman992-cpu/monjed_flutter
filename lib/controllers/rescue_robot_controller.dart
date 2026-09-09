import '../services/api_service.dart';
import '../models/Accessibility_Volunteer_RescueRobot_Models.dart';
class RescueRobotController {
  final ApiService api = ApiService();

  Future<dynamic> health() async {
    return await api.get(
      '/rescue-robot/health',
    );
  }

  Future<dynamic> getMissions() async {
    return await api.get(
      '/rescue-robot/missions',
    );
  }

  Future<dynamic> createMission(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/rescue-robot/missions',
      body: body,
    );
  }

  Future<dynamic> getMission(
    String missionId,
  ) async {
    return await api.get(
      '/rescue-robot/missions/$missionId',
    );
  }

  Future<dynamic> postTelemetry(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/rescue-robot/telemetry',
      body: body,
    );
  }

  Future<dynamic> getLatestTelemetry() async {
    return await api.get(
      '/rescue-robot/telemetry/latest',
    );
  }

  Future<dynamic> getEvents() async {
    return await api.get(
      '/rescue-robot/events',
    );
  }
}
