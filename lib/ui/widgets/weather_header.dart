import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

class WeatherHeader extends StatelessWidget {
  const WeatherHeader({
    super.key,
    required this.subtitle,
    required this.onMenuTap,
    this.title = 'Cuaca Hari Ini',
  });

  final String title;
  final String subtitle;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onMenuTap,
          tooltip: 'Menu',
          icon: const Icon(Icons.more_horiz_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.card,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet menu yang dibuka dari tombol menu pada header.
Future<void> showWeatherMenuSheet(
  BuildContext context, {
  required VoidCallback onChangeCity,
  required VoidCallback onShowSource,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      void run(VoidCallback action) {
        Navigator.of(sheetContext).pop();
        action();
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.wb_cloudy_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Tentang Weatherly',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Simple. Accurate. Always with you.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              _MenuTile(
                icon: Icons.location_city_rounded,
                label: 'Ganti Kota',
                onTap: () => run(onChangeCity),
              ),
              _MenuTile(
                icon: Icons.info_outline_rounded,
                label: 'Sumber Data',
                onTap: () => run(onShowSource),
              ),
              const Divider(color: AppColors.card),
              _MenuTile(
                icon: Icons.logout_rounded,
                label: 'Keluar Aplikasi',
                showChevron: false,
                onTap: () => run(() => SystemNavigator.pop()),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label),
      trailing: showChevron
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            )
          : null,
      onTap: onTap,
    );
  }
}
