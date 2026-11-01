import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../app/themes/app_text_styles.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../../../../data/models/driver_model.dart';
import '../../viewmodels/edit_driver_profile_viewmodel.dart';

class EditDriverProfileView extends GetView<EditDriverProfileViewModel> {
  final DriverModel driver;

  const EditDriverProfileView({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    Get.put(EditDriverProfileViewModel());
    controller.initDriver(driver);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Enhanced Header Section
          _buildEnhancedHeaderSection(),

          // Content Section
          Expanded(
            child: _buildContentSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeaderSection() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Text(
                  'edit_profile'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Save Button
              Obx(() => _buildEnhancedSaveButton()),
            ],
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'update_your_profile_info'.tr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: controller.isSaving.value
          ? Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          color: controller.hasChanges.value
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.hasChanges.value
                ? Colors.white.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: controller.hasChanges.value ? () => controller.saveProfile() : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'save'.tr,
                style: TextStyle(
                  color: controller.hasChanges.value ? Colors.white : Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          // Profile Photo Section
          _buildProfilePhotoSection(),
          const SizedBox(height: 32),

          // Personal Information Section
          _buildPersonalInfoSection(),
          const SizedBox(height: 24),

          // Contact Information Section
          _buildContactInfoSection(),
          const SizedBox(height: 24),

          // Vehicle Information Section
          _buildVehicleInfoSection(),
          const SizedBox(height: 24),

          // Identification Information Section
          _buildIdentificationSection(),
          const SizedBox(height: 32),

          // Bottom Save Button
          _buildBottomSaveButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'profile_photo'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => _buildProfileImage()),
        const SizedBox(height: 12),
        Text(
          'tap_to_change_photo'.tr,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final hasSelectedImage = controller.selectedImage.value != null;
    final hasNetworkImage = controller.photoUrl.value != null;

    return GestureDetector(
      onTap: controller.pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildProfileImageContent(hasSelectedImage, hasNetworkImage),
            ),
          ),
          // Edit Icon Overlay
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.background,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageContent(bool hasSelectedImage, bool hasNetworkImage) {
    if (hasSelectedImage) {
      return Image.file(
        controller.selectedImage.value!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    } else if (hasNetworkImage) {
      return Image.network(
        controller.photoUrl.value!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person_rounded,
            size: 56,
            color: AppColors.primary.withOpacity(0.5),
          );
        },
      );
    } else {
      return Icon(
        Icons.person_rounded,
        size: 56,
        color: AppColors.primary.withOpacity(0.5),
      );
    }
  }

  Widget _buildPersonalInfoSection() {
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'personal_information'.tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name Field
          _buildNameField(),
          const SizedBox(height: 20),

          // License Number
          _buildLicenseField(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'full_name'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.nameCtrl,
          hintText: 'enter_full_name'.tr,
          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
          validator: controller.validateName,
          borderRadius: 12,
          onChanged: (_) => controller.checkChanges(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ],
    );
  }

  Widget _buildLicenseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'driving_license'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.licenseCtrl,
          hintText: 'enter_license_number'.tr,
          prefixIcon: const Icon(Icons.card_membership_outlined, color: AppColors.textSecondary),
          validator: controller.validateLicense,
          borderRadius: 12,
          onChanged: (_) => controller.checkChanges(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.contact_phone_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'contact_information'.tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone Field
          _buildPhoneField(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'phone_number'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.phoneCtrl,
          hintText: 'enter_phone_number'.tr,
          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
          keyboardType: TextInputType.phone,
          validator: controller.validatePhone,
          borderRadius: 12,
          onChanged: (_) => controller.checkChanges(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoSection() {
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'vehicle_information'.tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Vehicle Type
          _buildVehicleTypeField(),
          const SizedBox(height: 20),

          // Vehicle Plate Number
          _buildVehiclePlateField(),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'vehicle_type'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.vehicleTypeCtrl,
          hintText: 'enter_vehicle_type'.tr,
          prefixIcon: const Icon(Icons.directions_car_outlined, color: AppColors.textSecondary),
          borderRadius: 12,
          onChanged: (_) => controller.checkChanges(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ],
    );
  }

  Widget _buildVehiclePlateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'vehicle_plate'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.vehiclePlateCtrl,
          hintText: 'enter_vehicle_plate'.tr,
          prefixIcon: const Icon(Icons.confirmation_number_outlined, color: AppColors.textSecondary),
          validator: controller.validateVehiclePlate,
          borderRadius: 12,
          onChanged: (_) => controller.checkChanges(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ],
    );
  }

  Widget _buildIdentificationSection() {
    return Container(
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
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'identification'.tr,
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'safety_verification_info'.tr,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Passport Number
          _buildPassportField(),
        ],
      ),
    );
  }

  Widget _buildPassportField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'passport_number'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.passportCtrl,
          hintText: 'enter_passport_number'.tr,
          prefixIcon: const Icon(Icons.credit_card_outlined, color: AppColors.textSecondary),
          validator: controller.validatePassport,
          borderRadius: 12,
          onChanged: (_) => controller.checkChanges(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ],
    );
  }

  Widget _buildBottomSaveButton() {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: CustomButton(
        text: 'save_changes'.tr,
        onPressed: controller.hasChanges.value && !controller.isSaving.value
            ? controller.saveProfile
            : null,
        isLoading: controller.isSaving.value,
        backgroundColor: controller.hasChanges.value ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
        textColor: Colors.white,
        height: 56,
        borderRadius: 16,
        hasShadow: controller.hasChanges.value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'save_changes'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (controller.isSaving.value) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                ),
              ),
            ] else if (controller.hasChanges.value) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    ));
  }
}