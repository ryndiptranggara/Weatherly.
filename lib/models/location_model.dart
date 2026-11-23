/// Lokasi hasil pencarian Geocoding API Open-Meteo.
class LocationModel {
  const LocationModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;

  /// Membuat model dari satu elemen `results` pada respons Geocoding API.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    if (latitude is! num || longitude is! num) {
      throw const FormatException('Koordinat lokasi tidak ditemukan.');
    }
    final name = json['name'];
    final country = json['country'];
    return LocationModel(
      name: name is String && name.isNotEmpty ? name : 'Lokasi tidak dikenal',
      country: country is String ? country : '',
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }
}
