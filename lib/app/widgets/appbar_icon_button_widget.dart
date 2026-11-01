import 'package:flutter/material.dart';

class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? iconSize;
  final double? buttonSize;
  final EdgeInsetsGeometry? margin;

  const AppBarIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.iconSize = 24,
    this.buttonSize = 48,
    this.margin = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero, // Remove default padding
        constraints: BoxConstraints(
          minWidth: buttonSize!,
          minHeight: buttonSize!,
        ),
      ),
    );
  }
}