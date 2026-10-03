import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    primarySwatch: AppColors.primarySwatch,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,

    // ✨ Enhanced App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      titleTextStyle: AppTextStyles.headingSmall.copyWith(
        color: AppColors.textPrimary,
        fontSize: 20,
      ),
    ),

    // 🎨 Enhanced Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: AppColors.textWhite,
      onSecondary: AppColors.textWhite,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      outline: AppColors.border,
    ),

    // 📝 Enhanced Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.heading,
      headlineMedium: AppTextStyles.headingSmall,
      headlineSmall: AppTextStyles.titleLarge,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // 🔘 Enhanced Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // 📱 Enhanced Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
      labelStyle: AppTextStyles.labelLarge,
    ),

    // 🎭 Enhanced Card Theme
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // ➗ Enhanced Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // 📌 Enhanced Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      elevation: 8,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
    ),

    // 🎀 Enhanced Visual Density
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}