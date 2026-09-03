import '../models/accessibility.dart';
import '../services/api_service.dart';

class AccessibilityRepository {
  final ApiService apiService;

  AccessibilityRepository({required this.apiService});

  Future<AccessibleActionPlan> adaptAction({
    required Map<String, dynamic> decision,
    required List<String> accessibilityNeeds,
  }) async {
    final response = await apiService.post(
      '/accessibility/adapt',
      body: {
        'decision': decision,
        'profile': {
          'accessibility_needs': accessibilityNeeds,
        },
      },
    );

    return AccessibleActionPlan.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
