import '../models/risk_snapshot.dart';
import 'api_service.dart';

class RiskService {
  static final ApiService _api = ApiService();

  static Future<List<RiskSnapshot>> getRiskSnapshots() async {
    final data = await _api.get('/api/risk/');

    if (data is! List) {
      throw Exception('Invalid risk API response');
    }

    return data
        .map(
          (item) => RiskSnapshot.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
