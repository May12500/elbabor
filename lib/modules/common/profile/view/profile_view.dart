import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../data/services/currency_service.dart';
import '../../../driver/views/profile/edit_driver_profile_view.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../widgets/profile_card.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('profile'.tr, style: AppTextStyles.heading.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Obx(() {
        final user = controller.user.value;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return CustomScrollView(
          slivers: [
            // Profile Header Card
            SliverToBoxAdapter(
              child: ProfileCard(user: user),
            ),

            // Quick Stats (for drivers)
            if (user['role'] == 'Driver')
              SliverToBoxAdapter(
                child: _buildDriverStats(user),
              ),

            // Settings Section
            SliverToBoxAdapter(
              child: _buildSettingsSection(controller, user),
            ),

            // Support Section
            SliverToBoxAdapter(
              child: _buildSupportSection(),
            ),

            // Logout Button
            SliverToBoxAdapter(
              child: _buildLogoutButton(controller),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDriverStats(Map<String, dynamic> user) {
    return Obx(() {
      if (controller.isLoadingStats.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                "loading_stats".tr,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        );
      }

      final totalTrips = controller.totalTrips;
      final completedTrips = controller.completedTrips;
      final activeTrips = controller.activeTrips;
      final rating = controller.rating;
      final successRate = controller.formattedSuccessRate;
      final cancelledTrips = controller.cancelledTrips;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and refresh button
            Row(
              children: [
                Icon(Icons.analytics_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'driver_stats'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, size: 16),
                  onPressed: () => controller.refreshDriverStats(),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(24, 24)),
                  tooltip: 'refresh_stats'.tr,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Compact stats grid - 2 rows of 3 items
            Row(
              children: [
                Expanded(
                  child: _buildCompactStatItem(
                    value: totalTrips.toString(),
                    label: 'total'.tr,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.grey.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildCompactStatItem(
                    value: completedTrips.toString(),
                    label: 'completed'.tr,
                    color: Colors.green,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.grey.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildCompactStatItem(
                    value: rating.toStringAsFixed(1),
                    label: 'rating'.tr,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompactStatItem(
                    value: activeTrips.toString(),
                    label: 'active'.tr,
                    color: AppColors.info,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.grey.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildCompactStatItem(
                    value: successRate,
                    label: 'success'.tr,
                    color: AppColors.success,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.grey.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildCompactStatItem(
                    value: cancelledTrips.toString(),
                    label: 'cancelled'.tr,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),

            // Success rate bar (optional - remove if too much)
            if (totalTrips > 0) ...[
              const SizedBox(height: 12),
              _buildSuccessRateBar(controller.successRate),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCompactStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessRateBar(double successRate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'success_rate'.tr,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${successRate.toStringAsFixed(1)}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              Expanded(
                flex: successRate.round(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                flex: 100 - successRate.round(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(ProfileViewModel controller, Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings'.tr,
            style: AppTextStyles.heading.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),

          // Edit Profile (Only for drivers)
          if (user['role'] == 'Driver')
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'edit_profile'.tr,
              subtitle: 'update_your_profile'.tr,
              trailing: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: AppColors.primary, size: 18),
                ),
                onPressed: () async {
                  final driver = controller.toDriverModel(user);
                  final updatedDriver = await Get.to(() => EditDriverProfileView(driver: driver));
                  if (updatedDriver != null) {
                    controller.refreshUser(updatedDriver.toMap());
                  }
                },
              ),
            ),

          // Theme Toggle
          // _buildSettingsItem(
          //   icon: Icons.dark_mode_outlined,
          //   title: 'dark_mode'.tr,
          //   subtitle: 'toggle_dark_light'.tr,
          //   trailing: Obx(() => Switch(
          //     value: controller.isDarkMode.value,
          //     activeColor: AppColors.primary,
          //     onChanged: (v) => controller.toggleTheme(),
          //   )),
          // ),

          // Language Selector
          // _buildSettingsItem(
          //   icon: Icons.language_outlined,
          //   title: 'language'.tr,
          //   subtitle: 'change_app_language'.tr,
          //   trailing: Obx(() => DropdownButton<String>(
          //     value: controller.currentLanguage.value,
          //     underline: const SizedBox(),
          //     icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          //     items: const [
          //       DropdownMenuItem(
          //         value: 'en_US',
          //         child: Row(
          //           children: [
          //             Icon(Icons.flag, color: Colors.blue),
          //             SizedBox(width: 8),
          //             Text('English'),
          //           ],
          //         ),
          //       ),
          //       DropdownMenuItem(
          //         value: 'fr_FR',
          //         child: Row(
          //           children: [
          //             Icon(Icons.flag, color: Colors.red),
          //             SizedBox(width: 8),
          //             Text('Français'),
          //           ],
          //         ),
          //       ),
          //     ],
          //     onChanged: (lang) {
          //       if (lang != null) controller.changeLanguage(lang);
          //     },
          //   )),
          // ),
          
          // Language Selector
          _buildLanguageSelector(),
          // Notifications
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'notifications'.tr,
            subtitle: 'manage_notifications'.tr,
            trailing: Switch(
              value: true,
              activeColor: AppColors.primary,
              onChanged: (v) {},
            ),
          ),
          // Currency Selection
          _buildCurrencySelector()
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return GetBuilder<CurrencyService>(
      builder: (currencyService) {
        return _buildSettingsItem(
          icon: Icons.currency_exchange_outlined,
          title: 'currency'.tr,
          subtitle: currencyService.isLoadingRates.value
              ? 'updating_rates'.tr
              : currencyService.areRatesStale
              ? 'rates_may_be_outdated'.tr
              : 'select_display_currency'.tr,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currencyService.isLoadingRates.value)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (currencyService.areRatesStale)
                IconButton(
                  icon: Icon(Icons.refresh, size: 20),
                  onPressed: () => currencyService.refreshRates(),
                  tooltip: 'refresh_rates'.tr,
                ),
              SizedBox(width: 8),
              DropdownButton<String>(
                value: currencyService.selectedCurrency.value,
                onChanged: (currency) {
                  if (currency != null) {
                    currencyService.setCurrency(currency);
                  }
                },
                items: currencyService.supportedCurrencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Row(
                      children: [
                        Text(currencyService.getCurrencySymbol(currency)),
                        SizedBox(width: 8),
                        Text(currency),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildLanguageSelector() {
    return _buildSettingsItem(
      icon: Icons.language_rounded,
      title: 'language'.tr,
      subtitle: controller.getCurrentLanguageName(),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
      onTap: () => _showLanguageSelectionSheet(),
    );
  }

  void _showLanguageSelectionSheet() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.language_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'select_language'.tr,
                  style: AppTextStyles.subheading.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Language Options
            Obx(() => _buildLanguageOption(
              'English',
              'English',
              '🇺🇸',
              'en_US',
              controller.currentLanguage.value == 'en_US',
            )),

            const SizedBox(height: 16),

            Obx(() => _buildLanguageOption(
              'French',
              'Français',
              '🇫🇷',
              'fr_FR',
              controller.currentLanguage.value == 'fr_FR',
            )),
            const SizedBox(height: 16),

            Obx(() => _buildLanguageOption(
              'Arabic',
              'العربية',
              '🇸🇦', //
              'ar_AR',
              controller.currentLanguage.value == 'ar_AR',
            )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String nativeName, String flag, String code, bool isSelected) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
        ),
        child: Center(
          child: Text(flag, style: const TextStyle(fontSize: 18)),
        ),
      ),
      title: Text(name, style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
      )),
      subtitle: Text(nativeName, style: AppTextStyles.caption),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        controller.changeLanguage(code);
        Get.back();
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'support'.tr,
            style: AppTextStyles.heading.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),

          _buildSupportItem(
            icon: Icons.help_outline,
            title: 'help_center'.tr,
            onTap: () => Get.snackbar('Help Center', 'Coming soon!'),
          ),
          _buildSupportItem(
            icon: Icons.contact_support_outlined,
            title: 'contact_support'.tr,
            onTap: () => Get.snackbar('Contact Support', 'Coming soon!'),
          ),
          _buildSupportItem(
            icon: Icons.security_outlined,
            title: 'privacy_policy'.tr,
            onTap: () => Get.snackbar('Privacy Policy', 'Coming soon!'),
          ),
          _buildSupportItem(
            icon: Icons.description_outlined,
            title: 'terms_of_service'.tr,
            onTap: () => Get.snackbar('Terms of Service', 'Coming soon!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyMedium,
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ProfileViewModel controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: CustomButton(
        text: 'logout'.tr,
        onPressed: () => _showLogoutConfirmation(controller),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        height: 56,
        borderRadius: 16,
        type: ButtonType.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'logout'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(ProfileViewModel controller) {
    Get.dialog(
      AlertDialog(
        title: Text('logout_confirmation'.tr),
        content: Text('logout_confirmation_message'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }
}