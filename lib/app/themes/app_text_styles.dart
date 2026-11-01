// lib/app/themes/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // 🎯 Display & Headings (Using Plus Jakarta Sans - Modern & Bold)
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.2,
  );

  // 🚀 Headings (Plus Jakarta Sans)
  static TextStyle get heading => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static TextStyle get headingSmall => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // 📝 Title Styles (Plus Jakarta Sans)
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // 📖 Body Text (Using Figtree - Excellent Readability)
  static TextStyle get bodyLarge => GoogleFonts.figtree(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: -0.1,
  );

  static TextStyle get body => GoogleFonts.figtree(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: -0.1,
  );

  static TextStyle get bodyMedium => GoogleFonts.figtree(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: -0.1,
  );

  static TextStyle get bodySmall => GoogleFonts.figtree(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // 🏷️ Label & Caption (Figtree)
  static TextStyle get labelLarge => GoogleFonts.figtree(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.figtree(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle get labelSmall => GoogleFonts.figtree(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textHint,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static TextStyle get caption => GoogleFonts.figtree(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // 🔘 Button Styles (Plus Jakarta Sans - Bold & Confident)
  static TextStyle get buttonLarge => GoogleFonts.plusJakartaSans(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.2,
    letterSpacing: 0.3,
  );

  static TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    height: 1.2,
    letterSpacing: 0.1,
  );

  // ✨ Special Styles (Figtree)
  static TextStyle get overline => GoogleFonts.figtree(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textHint,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // 🔥 Premium Styles for Driver App
  static TextStyle get priceLarge => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle get etaBold => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
    height: 1.2,
  );

  static TextStyle get addressText => GoogleFonts.figtree(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get driverName => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get rideType => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.3,
  );

  static TextStyle get distanceText => GoogleFonts.figtree(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // 🎪 Fun & Attractive Styles
  static TextStyle get promotional => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle get highlight => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.3,
  );

  // Legacy compatibility
  static TextStyle get subheading => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get buttonTStyle => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.2,
  );
}