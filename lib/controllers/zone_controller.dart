
import '../services/api_service.dart';
import '../models/zone.dart';

class ZonesController {
  final ApiService api = ApiService();

  // ==========================================================
  // GET ALL ZONES
  // ==========================================================

  Future<List<Zone>> getZones() async {
    final response = await api.get('/zones');

    if (response is! List) {
      throw Exception('Invalid /zones response');
    }

    return response
        .map(
          (json) => Zone.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ==========================================================
  // LOAD COUNTRIES
  // ==========================================================
  //
  // The signup screen expects:
  // List<Map<String, dynamic>>
  //
  // We keep countryCode because the screen passes it to
  // loadZones(countryCode).

  Future<List<Map<String, dynamic>>> loadCountries() async {
    final zones = await getZones();

    final Map<String, Map<String, dynamic>> uniqueCountries = {};

    for (final zone in zones) {
      final code = zone.countryCode ?? zone.country;

      if (code.isEmpty) {
        continue;
      }

      uniqueCountries[code] = {
        'country': zone.country,
        'country_code': zone.countryCode,
      };
    }

    final countries = uniqueCountries.values.toList();

    countries.sort(
      (a, b) => (a['country'] ?? '')
          .toString()
          .compareTo(
            (b['country'] ?? '').toString(),
          ),
    );

    return countries;
  }

  // ==========================================================
  // LOAD ZONES FOR COUNTRY
  // ==========================================================
  //
  // signup_screen_volunteer.dart passes countryCode here.
  //
  // Since the API currently exposes GET /zones,
  // filtering is done locally.

  Future<List<Zone>> loadZones(String countryCode) async {
    final zones = await getZones();

    return zones.where((zone) {
      if (zone.countryCode != null &&
          zone.countryCode!.isNotEmpty) {
        return zone.countryCode == countryCode;
      }

      // Fallback if backend doesn't provide country_code.
      return zone.country == countryCode;
    }).toList();
  }
}

