import '../core/network/api_service.dart';

class RiskController {
  final ApiService api = ApiService();

  Future<dynamic> getRisk() async {
    return await api.get('/api/risk/');
  }

  Future<dynamic> getFloodRisk() async {
    return await api.get('/risk/flood');
  }

  Future<dynamic> getEarthquakeRisk() async {
    return await api.get('/risk/earthquake');
  }
}
