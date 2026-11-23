import 'package:flutter_test/flutter_test.dart';
import 'package:weatherly/models/weather_model.dart';

void main() {
  test('WeatherModel.fromJson membaca data current dari Open-Meteo', () {
    final weather = WeatherModel.fromJson({
      'current': {
        'time': '2026-11-23T09:41',
        'temperature_2m': 31.6,
        'relative_humidity_2m': 68,
        'precipitation': 0.0,
        'wind_speed_10m': 14.2,
        'weather_code': 2,
      },
    });

    expect(weather.temperature, 31.6);
    expect(weather.humidity, 68);
    expect(weather.description, 'Berawan');
    expect(weather.formattedTime, '09:41');
  });

  test('WeatherModel.fromJson melempar FormatException bila data kosong', () {
    expect(
      () => WeatherModel.fromJson({'current': {}}),
      throwsFormatException,
    );
  });

  test('kode cuaca dipetakan ke deskripsi yang benar', () {
    expect(WeatherModel.categoryFromCode(0), WeatherCategory.clear);
    expect(WeatherModel.categoryFromCode(63), WeatherCategory.rain);
    expect(WeatherModel.categoryFromCode(82), WeatherCategory.heavyRain);
    expect(WeatherModel.categoryFromCode(96), WeatherCategory.thunderstorm);
  });
}