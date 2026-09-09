import '../services/api_service.dart';
import '../models/Risk_Reports_Decision_Assistance_Models.dart';
class DecisionController {
  final ApiService api = ApiService();

  Future<dynamic> evaluate(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/decision/evaluate',
      body: body,
    );
  }

  Future<dynamic> evaluateFromRisk(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/decision/from-risk',
      body: body,
    );
  }
}
