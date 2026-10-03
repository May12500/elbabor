import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elbabor/app/themes/app_colors.dart';
import 'package:elbabor/app/themes/app_text_styles.dart';
import 'package:elbabor/app/widgets/custom_button.dart';
import 'package:elbabor/app/widgets/custom_text_field.dart';
import 'package:elbabor/app/constants/assets.dart';
import '../viewmodels/driver_details_viewmodel.dart';

class DriverDetailsView extends GetView<DriverDetailsViewModel> {
  const DriverDetailsView({super.key});

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

                // Form Section
                _buildFormSection(),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 20),
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
        const SizedBox(height: 20),

        // Back Button and Title
        Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.all(12),
              ),
            ),
            const Spacer(),
            Text(
              "driver_profile".tr,
              style: AppTextStyles.heading.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 48), // For balance
          ],
        ),

        const SizedBox(height: 8),

        // Welcome Text
        Text(
          "complete_driver_profile".tr,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFormSection() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Photo Section
          _buildProfilePhotoSection(),
          const SizedBox(height: 32),

          // Vehicle Registration Plate Field
          _buildVehiclePlateField(),
          const SizedBox(height: 20),

          // Passport Number Field
          _buildPassportField(),
          const SizedBox(height: 20),

          // Phone Number Field
          _buildPhoneField(),
          const SizedBox(height: 20),

          // License Number Field
          _buildLicenseField(),
          const SizedBox(height: 8),

          // Information Text
          _buildInfoText(),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        Text(
          "profile_photo".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => _buildProfileImage()),
        const SizedBox(height: 12),
        Text(
          "tap_to_change_photo".tr,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final image = controller.selectedImage.value;
    final hasImage = image != null;

    return GestureDetector(
      onTap: controller.pickImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.file(
                File(image.path),
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              )
                  : Icon(
                Icons.person_rounded,
                size: 50,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
          // Camera Icon Overlay
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              child: Icon(
                hasImage ? Icons.edit_rounded : Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclePlateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "vehicle_plate".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.vehiclePlateController,
          hintText: "enter_vehicle_plate".tr,
          prefixIcon: Icon(Icons.directions_car_outlined),
          validator: controller.validateVehiclePlate,
          borderRadius: 12,
        ),
      ],
    );
  }

  Widget _buildPassportField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "passport_number".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.passportController,
          hintText: "enter_passport_number".tr,
          prefixIcon: Icon(Icons.credit_card_outlined),
          validator: controller.validatePassport,
          borderRadius: 12,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "phone_number".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.phoneController,
          hintText: "enter_phone_number".tr,
          prefixIcon: Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          validator: controller.validatePhone,
          borderRadius: 12,
        ),
      ],
    );
  }

  Widget _buildLicenseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "driving_license".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.licenseController,
          hintText: "enter_license_number".tr,
          prefixIcon: Icon(Icons.card_membership_outlined),
          validator: controller.validateLicense,
          borderRadius: 12,
        ),
      ],
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "safety_verification_info".tr, // Updated text for safety reassurance
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 20),
      child: Column(
        children: [
          // Submit Button
          Obx(() => CustomButton(
            text: "save_profile".tr,
            onPressed: controller.isLoading.value ? null : controller.onSubmitPressed,
            isLoading: controller.isLoading.value,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            height: 56,
            borderRadius: 16,
            hasShadow: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "save_profile".tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (controller.isLoading.value) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          )),

          const SizedBox(height: 16),

          // Skip Button
          TextButton(
            onPressed: controller.onSkipPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "complete_later".tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}