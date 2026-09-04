import '../models/volunteer.dart';
import '../repositories/volunteers_repository.dart';

class VolunteerController {
  final VolunteerRepository repository;

  VolunteerController({required this.repository});

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
    return await repository.createVolunteer(
      zoneId: zoneId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      available: available,
      responderLevel: responderLevel,
      vehicleType: vehicleType,
      capacity: capacity,
      skills: skills,
    );
  }
}

