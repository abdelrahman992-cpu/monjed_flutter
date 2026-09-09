import '../services/api_service.dart';
import '../models/Risk_Reports_Decision_Assistance_Models.dart';
import '../models/Accessibility_Volunteer_RescueRobot_Models.dart';
class PipelineController {
  final ApiService api = ApiService();

  Future<dynamic> flood(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/pipeline/flood',
      body: body,
    );
  }

  Future<dynamic> earthquake(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/pipeline/earthquake',
      body: body,
    );
  }
}
