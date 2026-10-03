import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/themes/app_theme.dart';
import '../viewmodels/splash_viewmodel.dart';
import '../../../app/constants/assets.dart';

class SplashScreen extends GetView<SplashViewModel> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashViewModel>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Obx(() => Stack(
        children: [
          // Enhanced background with modern gradient
          _buildBackground(),

          // Main content with centered layout
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with premium animations
                _buildLogo(controller.logoAnimationValue.value),

                const SizedBox(height: 36),

                // App name with Plus Jakarta Sans
                _buildAppName(controller.appNameAnimationValue.value),

                const SizedBox(height: 20),

                // Tagline with Figtree for readability
                _buildTagline(controller.taglineAnimationValue.value),

                const SizedBox(height: 52),

                // Premium loading indicator
                _buildLoadingIndicator(controller.loadingAnimationValue.value),
              ],
            ),
          ),

          // Professional bottom section
          Visibility(
            visible: false,
              child: _buildBottomInfo(controller.bottomInfoAnimationValue.value)),
        ],
      )),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryVariant,
            AppColors.secondary.withOpacity(0.9),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _ModernBackgroundPainter(),
      ),
    );
  }

  Widget _buildLogo(double animationValue) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()
        ..scale(0.7 + (animationValue * 0.3)) // More dramatic scale
        ..translate(0.0, (1 - animationValue) * 20), // Enhanced float-up
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: animationValue,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 3,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Hero(
            tag: 'appLogo',
            child: Image.asset(
              Assets.appLogo,
              width: 110,
              height: 110,
              color: Colors.white,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppName(double animationValue) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: animationValue,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, (1 - animationValue) * 20, 0),
        child: Text(
          'app_name'.tr,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.8,
            height: 1.1,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagline(double animationValue) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: animationValue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Text(
          'travel_together_tagline'.tr,
          style: GoogleFonts.figtree(
            fontSize: 17,
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.9,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(double animationValue) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: animationValue,
      child: Column(
        children: [
          // Clear spinning loader
          Container(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.2),
              // Remove the value property to make it spin indefinitely
            ),
          ),

          const SizedBox(height: 20),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: animationValue,
            child: Text(
              'preparing_experience'.tr,
              style: GoogleFonts.figtree(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomInfo(double animationValue) {
    return Positioned(
      bottom: 48,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: animationValue,
        child: Column(
          children: [
            // Modern divider
            Container(
              width: 100,
              height: 2,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Company info with modern typography
            Text(
              'from'.tr,
              style: GoogleFonts.figtree(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'company_name'.tr,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            // Version with modern style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              child: Text(
                'v1.0.0',
                style: GoogleFonts.figtree(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.1),
          AppColors.secondary.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    // Modern geometric elements
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    // Modern geometric shapes - more dynamic
    final circle1 = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.12),
        radius: size.width * 0.15,
      ));

    final circle2 = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.8),
        radius: size.width * 0.1,
      ));

    // Draw background gradient
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), gradientPaint);

    // Draw subtle shadows
    canvas.drawPath(circle1, shadowPaint);
    canvas.drawPath(circle2, shadowPaint);

    // Draw geometric shapes
    canvas.drawPath(circle1, paint);
    canvas.drawPath(circle2, paint);

    // Add modern line patterns
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Diagonal lines for modern feel
    for (int i = 0; i < 8; i++) {
      final offset = i * 40.0;
      canvas.drawLine(
        Offset(-50 + offset, -50),
        Offset(size.width + 50, size.height + 50 - offset),
        linePaint,
      );
    }

    // Subtle grid pattern
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;

    for (int i = 0; i < size.width ~/ 40; i++) {
      final x = i * 40.0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (int i = 0; i < size.height ~/ 40; i++) {
      final y = i * 40.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}