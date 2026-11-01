import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../app/widgets/custom_button.dart';
import '../../../app/widgets/custom_role_card.dart';
import '../viewmodels/role_selection_viewmodel.dart';

class RoleSelectionScreen extends GetView<RoleSelectionViewModel> {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'select_role'.tr,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // --- Split role selection ---
              Expanded(
                child: Obx(() => Row(
                  children: [
                    CustomRoleCard(
                      icon: Icons.directions_car_rounded,
                      title: 'driver'.tr,
                      isSelected:
                      controller.selectedRole.value == UserRole.driver,
                      onTap: () =>
                          controller.selectRole(UserRole.driver),
                    ),
                    const SizedBox(width: 16),
                    CustomRoleCard(
                      icon: Icons.person_rounded,
                      title: 'passenger'.tr,
                      isSelected: controller.selectedRole.value ==
                          UserRole.passenger,
                      onTap: () =>
                          controller.selectRole(UserRole.passenger),
                    ),
                  ],
                )),
              ),

              // --- Continue button ---
              Obx(() => CustomButton(
                text: 'continue'.tr,
                onPressed: controller.selectedRole.value == null
                    ? null
                    : controller.continueNext,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
