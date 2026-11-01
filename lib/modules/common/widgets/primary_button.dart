import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.elevation,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        disabledBackgroundColor: disabledBackgroundColor ?? AppColors.disabled,
        foregroundColor: textColor ?? AppColors.textWhite,
        minimumSize: const Size(double.infinity, 48),
        elevation: elevation ?? 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        // Optional: Add shadow that matches your theme
        shadowColor: AppColors.shadow,
      ),
      child: loading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? AppColors.textWhite,
          ),
        ),
      )
          : Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textWhite,
        ),
      ),
    );
  }
}