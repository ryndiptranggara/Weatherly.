import 'package:flutter/material.dart';

import '../app_colors.dart';

class MainWeatherCard extends StatelessWidget {
  const MainWeatherCard({
    super.key,
    required this.locationName,
    required this.updatedLabel,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.onLocationTap,
  });

  final String locationName;
  final String updatedLabel;
  final double temperature;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -50,
            bottom: -70,
            child: _Circle(size: 220),
          ),
          const Positioned(
            left: -40,
            bottom: -90,
            child: _Circle(size: 180),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onLocationTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          locationName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  updatedLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${temperature.round()}°',
                              style: const TextStyle(
                                fontSize: 84,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(icon, size: 96, color: iconColor),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x14FFFFFF),
      ),
    );
  }
}
