import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Kesalahan yang aman ditampilkan langsung ke pengguna.
class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Satu-satunya tempat yang memakai paket HTTP.
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  Future<LocationModel> fetchLocation(String city) async {
    final name = city.trim();
    if (name.isEmpty) {
      throw const WeatherException('Nama kota tidak boleh kosong.');
    }
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': name,
      'count': '1',
      'language': 'en',
      'format': 'json',
    });
    final json = await _getJson(uri);
    final results = json['results'];
    if (results is! List || results.isEmpty) {
      throw WeatherException('Kota "$name" tidak ditemukan.');
    }
    final first = results.first;
    if (first is! Map<String, dynamic>) {
      throw const WeatherException('Format data lokasi tidak valid.');
    }
    try {
      return LocationModel.fromJson(first);
    } on FormatException {
      throw const WeatherException('Data lokasi dari server tidak valid.');
    }
  }

  Future<WeatherModel> fetchWeather(LocationModel location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,weather_code',
      'timezone': 'auto',
    });
    final json = await _getJson(uri);
    try {
      return WeatherModel.fromJson(json);
    } on FormatException catch (e) {
      throw WeatherException(e.message);
    }
  }

  /// Geocoding lalu Forecast, dikembalikan sebagai satu paket model.
  Future<({LocationModel location, WeatherModel weather})> fetchWeatherForCity(
    String city,
  ) async {
    final location = await fetchLocation(city);
    final weather = await fetchWeather(location);
    return (location: location, weather: weather);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw WeatherException(
          'Server mengembalikan kesalahan (kode ${response.statusCode}).',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherException('Format respons server tidak valid.');
      }
      return decoded;
    } on WeatherException {
      rethrow;
    } on TimeoutException {
      throw const WeatherException(
        'Permintaan terlalu lama. Periksa koneksi internet Anda.',
      );
    } on SocketException {
      throw const WeatherException(
        'Periksa koneksi internet Anda atau coba lagi nanti.',
      );
    } on http.ClientException {
      throw const WeatherException(
        'Tidak dapat terhubung ke server. Coba lagi nanti.',
      );
    } on FormatException {
      throw const WeatherException('Respons server bukan JSON yang valid.');
    }
  }

  void dispose() => _client.close();
}
