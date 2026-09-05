class Zone {
  final String zoneId;
  final String name;
  final String country;
  final double? latitude;
  final double? longitude;

  const Zone({
    required this.zoneId,
    required this.name,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];

    double? longitude;
    double? latitude;

    if (coordinates is List && coordinates.length >= 2) {
      longitude = (coordinates[0] as num).toDouble();
      latitude = (coordinates[1] as num).toDouble();
    }

    return Zone(
      zoneId: json['zone_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }
}
