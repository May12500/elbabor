import 'package:flutter/material.dart';

class ResponsiveWidgets {
  // Simple responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return const EdgeInsets.all(24);
    if (width >= 600) return const EdgeInsets.all(20);
    return const EdgeInsets.all(16);
  }

  // Simple responsive font size
  static double getResponsiveFontSize(BuildContext context, {required double baseSize}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return baseSize * 1.2;
    if (width >= 600) return baseSize * 1.1;
    return baseSize;
  }

  // Simple responsive layout detection
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
}

// Simple Card Widget without complex constraints
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Simple Section Header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}