import 'package:flutter/material.dart';

/// Palet warna utama aplikasi Santriku.
///
/// Menggunakan kombinasi warna teal/hijau pesantren
/// dengan aksen gold/amber untuk elemen interaktif.
class AppColors {
  AppColors._();

  // ── Primary (Teal/Green) ──────────────────────────────
  static const Color primary      = Color(0xFF1A6B5A);
  static const Color primaryDark  = Color(0xFF0D4A3E);
  static const Color primaryDarker = Color(0xFF083329);
  static const Color primaryLight = Color(0xFF2A8B72);

  // ── Accent (Gold/Amber) ───────────────────────────────
  static const Color accent      = Color(0xFFE8A838);
  static const Color accentLight = Color(0xFFF0C060);
  static const Color accentDark  = Color(0xFFD49520);

  // ── Background Gradient ───────────────────────────────
  static const Color gradientTop    = Color(0xFF0F3D32);
  static const Color gradientMiddle = Color(0xFF1A6B5A);
  static const Color gradientBottom = Color(0xFF145A4A);

  // ── Surface ───────────────────────────────────────────
  static const Color surface      = Color(0xFF1E7A66);
  static const Color surfaceLight = Color(0x33FFFFFF);
  static const Color surfaceDark  = Color(0x1AFFFFFF);

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70 %
  static const Color textHint     = Color(0x80FFFFFF);  // 50 %
  static const Color textDark     = Color(0xFF1A1A1A);

  // ── Input Field ───────────────────────────────────────
  static const Color inputBackground   = Color(0x1AFFFFFF);
  static const Color inputBorder       = Color(0x33FFFFFF);
  static const Color inputBorderFocused = Color(0xFFE8A838);

  // ── Status ────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error   = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);
  static const Color info    = Color(0xFF29B6F6);

  // ── Gradient Preset ───────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientMiddle, gradientBottom],
    stops: [0.0, 0.4, 1.0],
  );
}
