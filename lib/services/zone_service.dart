import '../models/zone.dart';
import 'api_service.dart';

class ZoneService {
  final ApiService api;

  ZoneService({
    ApiService? api,
  }) : api = api ?? ApiService();

  Future<List<Zone>> getZones() async {
    final data = await api.get('/dashboard/zones');

    if (data is! List) {
      throw Exception('Invalid zones response');
    }

    return data
        .map(
          (item) => Zone.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}
