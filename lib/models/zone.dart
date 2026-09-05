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
    return Zone(
      zoneId: json['zone_id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      countryCode: json['country_code'] as String?,
      region: json['region'] as String?,
      subregion: json['subregion'] as String?,
      coordinates: (json['coordinates'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
