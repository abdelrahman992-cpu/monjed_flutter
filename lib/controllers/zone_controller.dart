import '../models/zone.dart';
import '../services/zone_service.dart';

class ZonesController {
  final ZoneService zoneService;

  ZonesController({
    required this.zoneService,
  });

  Future<List<Zone>> loadZones() async {
    final zones = await zoneService.getZones();

    print('LOADED ZONES: ${zones.length}');

    return zones;
  }
}
