import 'package:flutter/material.dart';

/// Matches the web portal's branding (see AshrafBack.Members.Web/wwwroot/css/site.css:
/// --brand-green / --brand-gold), so the mobile app looks like the same product.
class AppColors {
  static const green = Color(0xFF1A5C34);
  static const greenDark = Color(0xFF0F3D22);
  static const greenLight = Color(0xFFE6F0E9);
  static const gold = Color(0xFFC9A227);
  static const goldDark = Color(0xFFA5821C);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.green,
    primary: AppColors.green,
    secondary: AppColors.gold,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.green,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: AppColors.greenLight.withValues(alpha: 0.35),
    ),
  );
}
