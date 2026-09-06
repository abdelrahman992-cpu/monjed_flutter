
import '../models/zone.dart';
import '../services/zone_service.dart';

class ZonesController {
  final ZoneService zoneService;

  ZonesController({
    required this.zoneService,
  });

  // ==========================================================
  // LOAD COUNTRIES
  // ==========================================================

  Future<List<Map<String, dynamic>>> loadCountries() async {
    final countries =
        await zoneService.getCountries();

    print(
      'LOADED COUNTRIES: ${countries.length}',
    );

    return countries;
  }

  // ==========================================================
  // LOAD ZONES BY COUNTRY
  // ==========================================================

  Future<List<Zone>> loadZones(
    String countryCode,
  ) async {
    final zones =
        await zoneService.getZones(
      countryCode,
    );

    print(
      'LOADED ZONES [$countryCode]: ${zones.length}',
    );

    return zones;
  }
}


