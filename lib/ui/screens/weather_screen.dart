import 'package:flutter/material.dart';

import '../../models/location_model.dart';
import '../../models/weather_model.dart';
import '../../services/weather_service.dart';
import '../app_colors.dart';
import '../widgets/main_weather_card.dart';
import '../widgets/weather_error.dart';
import '../widgets/weather_header.dart';
import '../widgets/weather_info_banner.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/weather_loading.dart';

enum _ScreenStatus { loading, success, error }

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();

  _ScreenStatus _status = _ScreenStatus.loading;
  String _city = 'Makassar';
  String _errorMessage = '';
  bool _isFetching = false;
  LocationModel? _location;
  WeatherModel? _weather;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  /// Memuat data. Dengan [keepContent] data lama tetap tampil selama refresh.
  Future<void> _load({bool keepContent = false}) async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
      if (!keepContent || _weather == null) {
        _status = _ScreenStatus.loading;
      }
    });
    try {
      final result = await _service.fetchWeatherForCity(_city);
      if (!mounted) return;
      setState(() {
        _location = result.location;
        _weather = result.weather;
        _status = _ScreenStatus.success;
        _isFetching = false;
      });
    } on WeatherException catch (e) {
      _handleFailure(e.message, keepContent);
    } catch (_) {
      _handleFailure('Terjadi kesalahan tak terduga. Coba lagi nanti.', keepContent);
    }
  }

  void _handleFailure(String message, bool keepContent) {
    if (!mounted) return;
    final hasData = _weather != null && _location != null;
    setState(() {
      _isFetching = false;
      if (!(keepContent && hasData)) {
        _errorMessage = message;
        _status = _ScreenStatus.error;
      }
    });
    if (keepContent && hasData) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _promptCity() async {
    var input = _city;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Ganti Kota'),
        content: TextFormField(
          initialValue: _city,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(hintText: 'Nama kota'),
          onChanged: (value) => input = value,
          onFieldSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(input),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
    final city = result?.trim() ?? '';
    if (city.isEmpty) return;
    _city = city;
    _load();
  }

  void _showSourceInfo() {
    final weather = _weather;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sumber Data'),
        content: Text(
          'Data cuaca dan lokasi berasal dari Open-Meteo (open-meteo.com).'
          '${weather == null ? '' : '\n\nCurah hujan saat ini: ${weather.precipitation.toStringAsFixed(1)} mm.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _openMenu() {
    showWeatherMenuSheet(
      context,
      onChangeCity: _promptCity,
      onShowSource: _showSourceInfo,
    );
  }

  String get _subtitle {
    switch (_status) {
      case _ScreenStatus.loading:
        return 'Mengambil data cuaca...';
      case _ScreenStatus.error:
        return 'Ups, terjadi kesalahan';
      case _ScreenStatus.success:
        return (_weather?.isWet ?? false)
            ? 'Nikmati hari dengan tenang ✨'
            : 'Tetap siap, di segala cuaca ✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              WeatherHeader(subtitle: _subtitle, onMenuTap: _openMenu),
              const SizedBox(height: 20),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final location = _location;
    final weather = _weather;
    switch (_status) {
      case _ScreenStatus.loading:
        return const WeatherLoading();
      case _ScreenStatus.error:
        return WeatherError(message: _errorMessage, onRetry: () => _load());
      case _ScreenStatus.success:
        if (location == null || weather == null) return const WeatherLoading();
        return _buildContent(location, weather);
    }
  }

  Widget _buildContent(LocationModel location, WeatherModel weather) {
    final style = _CategoryStyle.of(weather.category);
    final bannerIcon = weather.isWet
        ? Icons.umbrella_rounded
        : (weather.isWindy ? Icons.air_rounded : Icons.info_rounded);
    final bannerColor = weather.isWet ? AppColors.secondary : AppColors.primary;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                MainWeatherCard(
                  locationName: location.name,
                  updatedLabel: 'Terakhir diperbarui ${weather.formattedTime}',
                  temperature: weather.temperature,
                  description: weather.description,
                  icon: style.icon,
                  iconColor: style.iconColor,
                  gradientColors: style.gradient,
                  onLocationTap: _promptCity,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: WeatherInfoCard(
                        icon: Icons.water_drop_rounded,
                        iconColor: style.accent,
                        label: 'Kelembapan',
                        value: '${weather.humidity}',
                        unit: '%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WeatherInfoCard(
                        icon: Icons.air_rounded,
                        iconColor: style.accent,
                        label: 'Angin',
                        value: '${weather.windSpeed.round()}',
                        unit: 'km/j',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WeatherInfoBanner(
                  message: weather.advice,
                  sourceLabel: 'Sumber data: Open-Meteo',
                  icon: bannerIcon,
                  iconColor: bannerColor,
                  onTap: _showSourceInfo,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isFetching ? null : () => _load(keepContent: true),
            icon: _isFetching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            label: Text(_isFetching ? 'Memperbarui...' : 'Perbarui Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: style.accent,
              foregroundColor: AppColors.textPrimary,
              disabledBackgroundColor: style.accent,
              disabledForegroundColor: AppColors.textPrimary,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gaya visual (ikon, gradien, aksen) untuk tiap kategori cuaca.
class _CategoryStyle {
  const _CategoryStyle({
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.accent,
  });

  final IconData icon;
  final Color iconColor;
  final List<Color> gradient;
  final Color accent;

  static const _blue = [Color(0xFF3B82F6), Color(0xFF1E3A8A)];
  static const _purple = [Color(0xFF8B7CF6), Color(0xFF3B2A6B)];
  static const _stormy = [Color(0xFF5B4B9A), Color(0xFF1E1B3A)];
  static const _misty = [Color(0xFF64748B), Color(0xFF1E293B)];
  static const _icy = [Color(0xFF60A5FA), Color(0xFF1E3A5F)];

  static _CategoryStyle of(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.clear:
        return const _CategoryStyle(
          icon: Icons.wb_sunny_rounded,
          iconColor: AppColors.accent,
          gradient: _blue,
          accent: AppColors.primary,
        );
      case WeatherCategory.cloudy:
      case WeatherCategory.unknown:
        return const _CategoryStyle(
          icon: Icons.cloud_rounded,
          iconColor: AppColors.textPrimary,
          gradient: _blue,
          accent: AppColors.primary,
        );
      case WeatherCategory.fog:
        return const _CategoryStyle(
          icon: Icons.foggy,
          iconColor: AppColors.textPrimary,
          gradient: _misty,
          accent: AppColors.primary,
        );
      case WeatherCategory.drizzle:
      case WeatherCategory.rain:
      case WeatherCategory.heavyRain:
        return const _CategoryStyle(
          icon: Icons.water_drop_rounded,
          iconColor: Color(0xFFBFDBFE),
          gradient: _purple,
          accent: AppColors.secondary,
        );
      case WeatherCategory.snow:
      case WeatherCategory.snowShower:
        return const _CategoryStyle(
          icon: Icons.ac_unit_rounded,
          iconColor: AppColors.textPrimary,
          gradient: _icy,
          accent: AppColors.primary,
        );
      case WeatherCategory.thunderstorm:
        return const _CategoryStyle(
          icon: Icons.thunderstorm_rounded,
          iconColor: AppColors.accent,
          gradient: _stormy,
          accent: AppColors.secondary,
        );
    }
  }
}
