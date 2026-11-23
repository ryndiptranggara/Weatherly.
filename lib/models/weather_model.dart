/// Kategori kondisi cuaca yang diturunkan dari `weather_code` Open-Meteo.
enum WeatherCategory {
  clear,
  cloudy,
  fog,
  drizzle,
  rain,
  heavyRain,
  snow,
  snowShower,
  thunderstorm,
  unknown,
}

double? _asDouble(Object? value) => value is num ? value.toDouble() : null;

/// Cuaca saat ini hasil Forecast API Open-Meteo.
class WeatherModel {
  const WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
    required this.observedAt,
  });

  final double temperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;
  final DateTime observedAt;

  /// Membuat model dari respons lengkap Forecast API (memakai blok `current`).
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('Data cuaca saat ini tidak tersedia.');
    }
    final temperature = _asDouble(current['temperature_2m']);
    final humidity = _asDouble(current['relative_humidity_2m']);
    final windSpeed = _asDouble(current['wind_speed_10m']);
    final weatherCode = _asDouble(current['weather_code']);
    if (temperature == null ||
        humidity == null ||
        windSpeed == null ||
        weatherCode == null) {
      throw const FormatException('Data cuaca dari server tidak lengkap.');
    }
    final time = current['time'];
    return WeatherModel(
      temperature: temperature,
      humidity: humidity.round(),
      precipitation: _asDouble(current['precipitation']) ?? 0,
      windSpeed: windSpeed,
      weatherCode: weatherCode.round(),
      observedAt:
          (time is String ? DateTime.tryParse(time) : null) ?? DateTime.now(),
    );
  }

  static WeatherCategory categoryFromCode(int code) {
    if (code == 0) return WeatherCategory.clear;
    if (code >= 1 && code <= 3) return WeatherCategory.cloudy;
    if (code == 45 || code == 48) return WeatherCategory.fog;
    if (code >= 51 && code <= 57) return WeatherCategory.drizzle;
    if (code >= 61 && code <= 67) return WeatherCategory.rain;
    if (code >= 71 && code <= 77) return WeatherCategory.snow;
    if (code >= 80 && code <= 82) return WeatherCategory.heavyRain;
    if (code >= 85 && code <= 86) return WeatherCategory.snowShower;
    if (code >= 95 && code <= 99) return WeatherCategory.thunderstorm;
    return WeatherCategory.unknown;
  }

  WeatherCategory get category => categoryFromCode(weatherCode);

  String get description {
    switch (category) {
      case WeatherCategory.clear:
        return 'Cerah';
      case WeatherCategory.cloudy:
        return 'Berawan';
      case WeatherCategory.fog:
        return 'Berkabut';
      case WeatherCategory.drizzle:
        return 'Gerimis';
      case WeatherCategory.rain:
        return 'Hujan';
      case WeatherCategory.heavyRain:
        return 'Hujan deras';
      case WeatherCategory.snow:
        return 'Salju';
      case WeatherCategory.snowShower:
        return 'Hujan salju';
      case WeatherCategory.thunderstorm:
        return 'Badai petir';
      case WeatherCategory.unknown:
        return 'Tidak diketahui';
    }
  }

  /// True bila sedang atau kemungkinan besar ada presipitasi.
  bool get isWet {
    if (precipitation > 0) return true;
    switch (category) {
      case WeatherCategory.drizzle:
      case WeatherCategory.rain:
      case WeatherCategory.heavyRain:
      case WeatherCategory.snowShower:
      case WeatherCategory.thunderstorm:
        return true;
      default:
        return false;
    }
  }

  bool get isWindy => windSpeed >= 30;

  /// Saran singkat berdasarkan data aktual.
  String get advice {
    if (isWet) return 'Jangan lupa bawa payung ya!';
    if (isWindy) return 'Angin cukup kencang, berhati-hatilah saat di luar.';
    return 'Cuaca cukup nyaman untuk beraktivitas luar.';
  }

  /// Jam observasi dengan format HH:mm (waktu setempat lokasi).
  String get formattedTime {
    final hour = observedAt.hour.toString().padLeft(2, '0');
    final minute = observedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
