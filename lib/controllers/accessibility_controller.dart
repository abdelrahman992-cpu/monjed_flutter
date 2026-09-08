import '../core/network/api_service.dart';

class AccessibilityController {
  final ApiService api = ApiService();

  Future<dynamic> adapt(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/accessibility/adapt',
      body: body,
    );
  }
}
