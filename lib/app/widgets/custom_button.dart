import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

// Button Type Enum
enum ButtonType {
  primary,
  secondary,
  outlined,
  danger,
  success,
}

// Button Size Enum
enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isFullWidth;
  final double? height;
  final double? width;
  final double borderRadius;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final bool hasShadow;
  final IconData? icon;
  final double? iconSize;
  final bool iconBeforeText;
  final double gapBetweenIconAndText;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isFullWidth = true,
    this.height,
    this.width,
    this.borderRadius = 12,
    this.child,
    this.padding,
    this.hasShadow = false,
    this.icon,
    this.iconSize = 20,
    this.iconBeforeText = true,
    this.gapBetweenIconAndText = 8,
  });

  // Constructor for backward compatibility
  const CustomButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.textColor,
    this.borderColor,
    this.isFullWidth = true,
    this.height,
    this.width,
    this.borderRadius = 12,
    this.child,
    this.padding,
    this.hasShadow = false,
    this.icon,
    this.iconSize = 20,
    this.iconBeforeText = true,
    this.gapBetweenIconAndText = 8,
  })  : type = ButtonType.outlined,
        backgroundColor = null;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    // Use child if provided, otherwise use text with optional icon
    final buttonChild = child ?? _buildDefaultChild();

    final button = ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(disabled),
        foregroundColor: _getForegroundColor(disabled),
        side: _getBorderSide(disabled),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: hasShadow ? 4 : 0,
        shadowColor: hasShadow ? Colors.black.withOpacity(0.1) : null,
        padding: padding ?? _getPadding(),
        textStyle: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: _getFontSize(),
        ),
        minimumSize: Size.zero,
      ),
      child: buttonChild,
    );

    // Wrap in SizedBox if custom dimensions are provided
    if (height != null || width != null || isFullWidth) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: height ?? _getHeight(),
        child: button,
      );
    }

    return button;
  }

  Widget _buildDefaultChild() {
    if (isLoading) {
      return SizedBox(
        height: _getLoaderSize(),
        width: _getLoaderSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressIndicatorColor(),
          ),
        ),
      );
    }

    // Build content with optional icon
    final textWidget = Text(
      text,
      style: AppTextStyles.body.copyWith(
        color: _getTextColor(),
        fontWeight: FontWeight.w600,
        fontSize: _getFontSize(),
      ),
      textAlign: TextAlign.center,
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(
      icon,
      size: iconSize ?? _getIconSize(),
      color: _getTextColor(),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconBeforeText
          ? [
        iconWidget,
        SizedBox(width: gapBetweenIconAndText),
        textWidget,
      ]
          : [
        textWidget,
        SizedBox(width: gapBetweenIconAndText),
        iconWidget,
      ],
    );
  }

  // Helper methods for button type styling
  Color? _getBackgroundColor(bool disabled) {
    if (disabled) {
      return Colors.grey.shade300;
    }

    if (backgroundColor != null) return backgroundColor;

    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outlined:
        return Colors.transparent;
      case ButtonType.danger:
        return AppColors.error;
      case ButtonType.success:
        return AppColors.success;
    }
  }

  Color _getForegroundColor(bool disabled) {
    if (disabled) {
      return Colors.grey.shade500;
    }

    if (textColor != null) return textColor!;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.outlined:
        return AppColors.primary;
    }
  }

  BorderSide? _getBorderSide(bool disabled) {
    if (type == ButtonType.outlined) {
      return BorderSide(
        color: disabled ? Colors.grey.shade400 : (borderColor ?? AppColors.primary),
        width: 1.5,
      );
    }

    // For danger outlined style
    if (type == ButtonType.danger && borderColor != null) {
      return BorderSide(
        color: disabled ? Colors.grey.shade400 : borderColor!,
        width: 1.5,
      );
    }

    return BorderSide.none;
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.outlined:
        return AppColors.primary;
    }
  }

  Color _getProgressIndicatorColor() {
    if (textColor != null) return textColor!;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.outlined:
        return AppColors.primary;
    }
  }

  // Helper methods for button size
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getLoaderSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}