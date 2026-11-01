import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/widgets/custom_button.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class OnBoardingView extends GetView<OnboardingViewModel> {
  OnBoardingView({super.key});

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() => Column(
          children: [
            // Skip Button - Top Right
            _buildSkipButton(),

            // Expanded PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => controller.currentPageIndex.value = index,
                children: [
                  _buildOnboardingPage(0),
                  _buildOnboardingPage(1),
                  _buildOnboardingPage(2),
                ],
              ),
            ),

            // Bottom Section with Indicator and Button
            _buildBottomSection(),
          ],
        )),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 16),
        child: TextButton(
          onPressed: controller.skipOnboarding,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'skip'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(int pageIndex) {
    final slide = controller.onboardingSlides[pageIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Image Container
          _buildAnimatedImage(slide['image']!, pageIndex),

          const SizedBox(height: 48),

          // Title with fade animation
          _buildAnimatedTitle(slide['title']!, pageIndex),

          const SizedBox(height: 16),

          // Subtitle with fade animation
          _buildAnimatedSubtitle(slide['subtitle']!, pageIndex),
        ],
      ),
    );
  }

  Widget _buildAnimatedImage(String imagePath, int pageIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()
        ..scale(controller.currentPageIndex.value == pageIndex ? 1.0 : 0.8)
        ..translate(0.0, controller.currentPageIndex.value == pageIndex ? 0.0 : 20.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: controller.currentPageIndex.value == pageIndex ? 1.0 : 0.3,
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle(String title, int pageIndex) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: controller.currentPageIndex.value == pageIndex ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        transform: Matrix4.translationValues(
            0.0,
            controller.currentPageIndex.value == pageIndex ? 0.0 : 30.0,
            0.0
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle(String subtitle, int pageIndex) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: controller.currentPageIndex.value == pageIndex ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        transform: Matrix4.translationValues(
            0.0,
            controller.currentPageIndex.value == pageIndex ? 0.0 : 40.0,
            0.0
        ),
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          // Page Indicator
          _buildPageIndicator(),

          const SizedBox(height: 32),

          // Continue/Get Started Button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.onboardingSlides.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: controller.currentPageIndex.value == index ? 32 : 12,
          decoration: BoxDecoration(
            color: controller.currentPageIndex.value == index
                ? AppColors.primary
                : AppColors.divider.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: controller.currentPageIndex.value == index ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isLastPage = controller.currentPageIndex.value == controller.onboardingSlides.length - 1;

    return CustomButton(
      text: isLastPage ? 'get_started'.tr : 'continue'.tr,
      onPressed: () {
        if (isLastPage) {
          controller.completeOnboarding();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      height: 56,
      borderRadius: 16,
      hasShadow: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isLastPage ? 'get_started'.tr : 'continue'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (!isLastPage) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}