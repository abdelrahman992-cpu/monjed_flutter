import '../models/volunteer.dart';
import '../services/api_service.dart';

class VolunteerRepository {
  final ApiService apiService;

  VolunteerRepository({required this.apiService});

  Future<VolunteerRecord> createVolunteer({
    required String zoneId,
    required String name,
    double? latitude,
    double? longitude,
    bool available = true,
    String responderLevel = 'volunteer',
    String? vehicleType,
    int capacity = 1,
    List<String>? skills,
  }) async {
    final response = await apiService.post(
      '/assistance/volunteers',
      body: {
        'zone_id': zoneId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'available': available,
        'responder_level': responderLevel,
        'vehicle_type': vehicleType,
        'capacity': capacity,
        'skills': skills,
      },
    );

    return VolunteerRecord.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
