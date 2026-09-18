import 'package:flutter/material.dart';

/// CreatingWings — shared design tokens.
/// Mirrors the HTML template (clean & minimal, light-blue + white, wavy texture).
class AppColors {
  static const accent = Color(0xFF4A97CF); // primary light blue
  static const bg = Color(0xFFEEF3F7); // app canvas
  static const surface = Color(0xFFFFFFFF);
  static const botBubble = Color(0xFFF4F8FB);
  static const botBubbleBorder = Color(0xFFE6EEF4);
  static const inkStrong = Color(0xFF243A48);
  static const ink = Color(0xFF2C4453);
  static const inkMuted = Color(0xFF6B7D8A);
  static const inputBorder = Color(0xFFD8E6F0);
  static const waveLight = Color(0xFFEAF4FB);
  static const waveDeep = Color(0xFFDCEDF9);
  static const danger = Color(0xFFD64545);
  static const dangerText = Color(0xFFFF4747);
  static const exclamationBg = Color(0xFFE7EBEE);
  static const exclamationInk = Color(0xFF8A8F96);
}

class AppText {
  static const String fontFamily = 'Manrope';

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.45,
    color: AppColors.ink,
  );
  static const TextStyle bubbleUser = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.45,
    color: Colors.white,
  );
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.inkStrong,
  );
}

/// Reusable brand accent, so you can theme the whole app in one place.
ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: AppText.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
    ),
  );
}
