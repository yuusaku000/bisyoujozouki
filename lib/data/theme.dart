import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF1C1620);
  static const panel = Color(0xFF2A2230);
  static const panelAlt = Color(0xFF3A3042);
  static const accent = Color(0xFFF06E8E);
  static const coin = Color(0xFFF5C451);
  static const textPrimary = Color(0xFFF4EEF2);
  static const textMuted = Color(0xFFA89AAE);

  static const genki = Color(0xFF6BD98E);
  static const futsuu = Color(0xFFF5C451);
  static const fuchou = Color(0xFFE06A6A);
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.panel,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
  );
}
