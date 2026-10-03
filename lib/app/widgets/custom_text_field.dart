import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? prefixText;
  final String? suffixText;
  final IconData? icon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool expands;
  final TextCapitalization textCapitalization;
  final String? counterText;
  final bool showCounter;
  final double borderRadius;
  final TextAlignVertical? textAlignVertical; // Added textAlignVertical parameter

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixText,
    this.suffixText,
    this.icon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding,
    this.fillColor,
    this.expands = false,
    this.textCapitalization = TextCapitalization.none,
    this.counterText,
    this.showCounter = false,
    this.borderRadius = 12.0,
    this.textAlignVertical, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      expands: expands,
      textCapitalization: textCapitalization,
      textAlignVertical: textAlignVertical, // Using textAlignVertical parameter
      style: AppTextStyles.body.copyWith(
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: fillColor ?? (enabled ? AppColors.surface : AppColors.surface.withOpacity(0.5)),
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        // Icon and prefix/suffix handling
        suffixIcon: suffixIcon,
        prefixIcon: _buildPrefix(),
        prefixText: prefixText,
        suffixText: suffixText,
        prefixStyle: AppTextStyles.body.copyWith(color: AppColors.primary),
        suffixStyle: AppTextStyles.body.copyWith(color: AppColors.primary),
        // Counter
        counterText: counterText,
        counterStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        // Error text styling
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        errorMaxLines: 2,
        // Floating label behavior
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        // Align label with content when focused
        alignLabelWithHint: maxLines != 1, // Align label with hint for multiline fields
      ),
    );
  }

  Widget? _buildPrefix() {
    if (prefixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: prefixIcon,
      );
    }
    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
      );
    }
    return null;
  }
}