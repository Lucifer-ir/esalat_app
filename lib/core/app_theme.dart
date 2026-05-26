// lib/core/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // آبی تیره متوسط (بدون گرادیانت)
  static const Color primary = Color(0xFF1A3C5A); 
  static const Color background = Color(0xFF0F1F2E);
  static const Color surface = Color(0xFF1E3044);
  static const Color accent = Color(0xFF2E86DE);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color skeletonBase = Color(0xFF2A3F52);
  static const Color skeletonHighlight = Color(0xFF3A5568);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Peyda',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(
            fontFamily: 'Peyda',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}