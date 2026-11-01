import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary accent (New blue: #0694e3)
  static const Color primary = Color(0xFF0694E3);
  static const Color secondary = Color(0xFF0D7BC4);
  static const Color primaryVariant = Color(0xFF0580C9);
  static const Color info = Color(0xFF1E6BA8);

  // Background & surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = background;
  static const Color surface = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF); // Added ✅

  // Dividers & borders
  static const Color divider = Color(0xFFE6E6E6); // soft grey line
  static const Color border = Color(0xFFDDDDDD);

  // Text colors
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textHint = Color(0xFF8E8E93);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Icon color (usually same as secondary text)
  static const Color icon = textSecondary;

  // States
  static const Color success = Color(0xFF34C759); // iOS green
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF3B30);
  static const Color grey = Color(0xFF6C6464);
  static const Color darkGrey = Color(0xFF292222);

  // Disabled / muted
  static const Color disabled = Color(0xFFBDBDBD);

  // Subtle shadow
  static const Color shadow = Color.fromRGBO(0, 0, 0, 0.08);

  // MaterialColor / swatch (updated with new primary color #0694e3)
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF0694E3,
    <int, Color>{
      50: Color(0xFFE6F4FE),
      100: Color(0xFFC4E6FC),
      200: Color(0xFF9DD6FA),
      300: Color(0xFF70C4F8),
      400: Color(0xFF42B2F5),
      500: Color(0xFF0694E3), // Primary
      600: Color(0xFF0580C9),
      700: Color(0xFF0469A8),
      800: Color(0xFF035387),
      900: Color(0xFF023A5F),
    },
  );

  // Additional color variants for the new primary
  static const Color primaryLight = Color(0xFFE6F4FE);
  static const Color primaryDark = Color(0xFF035387);
  static const Color primaryContainer = Color(0xFFC4E6FC);
  static const Color onPrimary = Color(0xFFFFFFFF);
}