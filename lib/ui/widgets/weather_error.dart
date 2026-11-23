import 'package:flutter/material.dart';

import '../app_colors.dart';

class WeatherError extends StatelessWidget {
  const WeatherError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.cloud_rounded,
                    size: 104,
                    color: AppColors.textSecondary,
                  ),
                  Positioned(
                    right: -6,
                    bottom: 4,
                    child: Icon(
                      Icons.error_rounded,
                      size: 40,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size(200, 52),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppColors.radius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
