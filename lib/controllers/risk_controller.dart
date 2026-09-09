import '../services/api_service.dart';
import '../models/Risk_Reports_Decision_Assistance_Models.dart';
class RiskController {
  final ApiService api = ApiService();

  Future<dynamic> assessFlood(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/risk/flood',
      body: body,
    );
  }

  Future<dynamic> assessEarthquake(
    Map<String, dynamic> body,
  ) async {
    return await api.post(
      '/risk/earthquake',
      body: body,
    );
  }
}
