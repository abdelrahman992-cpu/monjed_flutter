import '../services/api_service.dart';
import '../models/zone.dart';

class ZonesController {
  final ApiService api = ApiService();

  Future<List<Zone>> getZones() async {
    final response = await api.get('/zones');

    if (response is! List) {
      throw Exception('Invalid zones response');
    }

    return response
        .map(
          (item) => Zone.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> loadCountries() async {
    final zones = await getZones();

    final Map<String, Map<String, dynamic>> countries = {};

    for (final zone in zones) {
      final code = zone.countryCode?.trim();
      final name = zone.country.trim();

      if (name.isEmpty) {
        continue;
      }

      final key = (code != null && code.isNotEmpty)
          ? code
          : name;

      countries[key] = {
        'country': name,
        'country_code': code,
      };
    }

    return countries.values.toList();
  }

  Future<List<Zone>> loadZones(String countryCode) async {
    final zones = await getZones();

    return zones.where((zone) {
      return zone.countryCode?.toLowerCase() ==
          countryCode.toLowerCase();
    }).toList();
  }

  Future<Zone> loadZone(String zoneId) async {
    final response = await api.get(
      '/dashboard/zones/$zoneId',
    );

    if (response is! Map) {
      throw Exception('Invalid zone response');
    }

    return Zone.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
