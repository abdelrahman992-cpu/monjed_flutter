import '../models/zone.dart';
import 'api_service.dart';

class ZoneService {
  final ApiService api;

  ZoneService({
    ApiService? api,
  }) : api = api ?? ApiService();

  // =========================
  // GET COUNTRIES
  // =========================

  Future<List<Map<String, dynamic>>> getCountries() async {
    final data = await api.get('/dashboard/countries');

    if (data is! List) {
      throw Exception('Invalid countries response');
    }

    return data
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  // =========================
  // GET ZONES BY COUNTRY
  // =========================

  Future<List<Zone>> getZones(
    String countryCode,
  ) async {
    final data = await api.get(
      '/dashboard/zones?country_code=${Uri.encodeQueryComponent(countryCode)}',
    );

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
