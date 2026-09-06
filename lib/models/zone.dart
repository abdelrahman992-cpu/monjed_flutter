class Zone {
  final String zoneId;
  final String name;
  final String country;
  final String? countryCode;
  final String? region;
  final String? subregion;
  final List<double> coordinates;

  Zone({
    required this.zoneId,
    required this.name,
    required this.country,
    this.countryCode,
    this.region,
    this.subregion,
    required this.coordinates,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    final coordinatesRaw = json['coordinates'];

    if (coordinatesRaw is! List ||
        coordinatesRaw.length < 2) {
      throw Exception(
        'Invalid coordinates for zone: ${json['zone_id']}',
      );
    }

    return Zone(
      zoneId: json['zone_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      countryCode: json['country_code']?.toString(),
      region: json['region']?.toString(),
      subregion: json['subregion']?.toString(),
      coordinates: coordinatesRaw
          .map(
            (value) => (value as num).toDouble(),
          )
          .toList(),
    );
  }
}
