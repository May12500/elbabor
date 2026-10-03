import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/widgets/custom_button.dart';
import '../../../app/constants/assets.dart';
import '../viewmodels/language_selection_viewmodel.dart';

class LanguageSelectionView extends GetView<LanguageSelectionViewModel> {
  const LanguageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(),

                // Language Selection Section
                _buildLanguageSection(),

                // Action Button
                _buildContinueButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const SizedBox(height: 40),

        // App Logo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.08),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Image.asset(
            Assets.appLogo,
            height: 80,
            width: 80,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 32),

        // Title
        Text(
          'select_language'.tr,
          style: AppTextStyles.heading.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Subtitle
        Text(
          'choose_preferred_language'.tr,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      children: [
        // English Option
        Obx(() => _buildLanguageCard(
          languageCode: 'en_US',
          languageName: 'English',
          nativeName: 'English',
          flag: '🇺🇸',
          isSelected: controller.selectedLanguage.value == 'en_US',
          onTap: () => controller.selectLanguage('en_US'),
        )),

        const SizedBox(height: 16),

        // French Option
        Obx(() => _buildLanguageCard(
          languageCode: 'fr_FR',
          languageName: 'French',
          nativeName: 'Français',
          flag: '🇫🇷',
          isSelected: controller.selectedLanguage.value == 'fr_FR',
          onTap: () => controller.selectLanguage('fr_FR'),
        )),

        const SizedBox(height: 16),

        // Arabic Option
        Obx(() => _buildLanguageCard(
          languageCode: 'ar_AR',
          languageName: 'Arabic',
          nativeName: 'العربية',
          flag: '🇸🇦',
          isSelected: controller.selectedLanguage.value == 'ar_AR',
          onTap: () {
            controller.selectLanguage('ar_AR');

          },
        )),
        // Language Preview
        // _buildLanguagePreview(),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Language Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nativeName,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check_rounded,
                size: 12,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePreview() {
    return Obx(() {
      final selectedLang = controller.selectedLanguage.value;
      final previewText = selectedLang == 'fr_FR'
          ? 'Bienvenue dans notre application de covoiturage'
          : 'Welcome to our ride-sharing application';

      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'language_preview'.tr,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              previewText,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Obx(() => CustomButton(
        text: 'continue'.tr,
        onPressed: controller.selectedLanguage.value.isNotEmpty
            ? controller.onContinue
            : null,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        height: 56,
        borderRadius: 16,
        hasShadow: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'continue'.tr,
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
      )),
    );
  }
}