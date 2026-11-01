import 'package:elbabor/app/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/widgets/custom_button.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthView extends GetView<AuthViewModel> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 20),

                // Logo Section with Animation
                _buildLogoSection(),

                // Content Section
                Expanded(
                  child: _buildContentSection(),
                ),

                // Bottom Links
                _buildBottomLinks(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Animated Logo Container
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.08),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Hero(
            tag: 'appLogo',
            child: Image.asset(
              Assets.appLogo,
              height: 80,
              width: 80,
              color: AppColors.primary,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContentSection() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Text Section
          _buildWelcomeText(),
      
          const SizedBox(height: 48),
      
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        // Main Title
        Text(
          'welcome_to_elbabor'.tr,
          style: AppTextStyles.heading.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Subtitle
        Text(
          'join_community_description'.tr,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Features List
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildFeatureItem(Icons.people_alt_outlined, 'connect_drivers_passengers'.tr),
        const SizedBox(height: 12),
        _buildFeatureItem(Icons.directions_car_filled_outlined, 'multiple_vehicle_options'.tr),
        const SizedBox(height: 12),
        _buildFeatureItem(Icons.savings_outlined, 'save_money_travel_smart'.tr),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Sign In Button
        CustomButton(
          text: 'sign_in'.tr,
          onPressed: controller.onSignIn,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          height: 56,
          borderRadius: 16,
          hasShadow: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'sign_in'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sign Up Button
        CustomButton(
          text: 'create_account'.tr,
          onPressed: controller.onSignUp,
          type: ButtonType.outlined,
          height: 56,
          borderRadius: 16,
          borderColor: AppColors.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'create_account'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Or Divider
        _buildOrDivider(),

        const SizedBox(height: 24),

        // Continue as Guest
        TextButton(
          onPressed: controller.onContinueAsGuest,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'continue_as_guest'.tr,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.divider.withOpacity(0.5),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or'.tr,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.divider.withOpacity(0.5),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLinks() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          _buildLinkButton('privacy_policy'.tr, controller.onPrivacyPolicy),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          _buildLinkButton('terms_of_service'.tr, controller.onTermsOfService),
        ],
      ),
    );
  }

  Widget _buildLinkButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}