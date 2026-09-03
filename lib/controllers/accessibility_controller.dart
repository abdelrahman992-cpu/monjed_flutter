import '../models/accessibility.dart';
import '../repositories/accessibility_repository.dart';

class AccessibilityController {
  final AccessibilityRepository repository;

  AccessibilityController({required this.repository});

  Future<AccessibleActionPlan> adaptAction({
    required Map<String, dynamic> decision,
    required List<String> accessibilityNeeds,
  }) async {
    return await repository.adaptAction(
      decision: decision,
      accessibilityNeeds: accessibilityNeeds,
    );
  }
}
