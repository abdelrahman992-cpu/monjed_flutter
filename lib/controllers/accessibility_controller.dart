import '../services/api_service.dart';
import '../models/accessibility_response.dart';
import '../models/Accessibility_Volunteer_RescueRobot_Models.dart';
class AccessibilityController {
  final ApiService api = ApiService();

  Future<AccessibilityResponse> adapt(
    Map<String, dynamic> body,
  ) async {
    final response = await api.post(
      '/accessibility/adapt',
      body: body,
    );

    return AccessibilityResponse.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
