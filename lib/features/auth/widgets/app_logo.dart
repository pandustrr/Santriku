import 'package:flutter/material.dart';
import 'package:santriku_app/core/constants/app_strings.dart';
import 'package:santriku_app/core/theme/app_colors.dart';

/// Logo branding aplikasi Santriku.
///
/// Menampilkan ikon + nama aplikasi + tagline.
/// [size] mengontrol skala keseluruhan logo.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ikon logo
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Transform.rotate(
            angle: -0.6, // Tilted crescent moon matching the design
            child: Icon(
              Icons.nightlight_round,
              color: AppColors.primaryDarker,
              size: size * 0.5,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Nama & tagline
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: size * 0.26,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
