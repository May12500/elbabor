import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elbabor/app/themes/app_colors.dart';
import 'package:elbabor/app/themes/app_text_styles.dart';
import 'package:elbabor/app/widgets/custom_button.dart';
import 'package:elbabor/app/widgets/custom_text_field.dart';
import '../viewmodels/signup_viewmodel.dart';

class SignupView extends GetView<SignupViewModel> {
  const SignupView({super.key});

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

                // Bottom Section
                _buildBottomSection(),

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back Button
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
            Text(
              "create_account".tr,
              style: AppTextStyles.heading.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Welcome Text
        Text(
          "join_our_community".tr,
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
          // Full Name Field
          _buildNameField(),
          const SizedBox(height: 20),

          // Email Field
          _buildEmailField(),
          const SizedBox(height: 20),

          // Password Field
          _buildPasswordField(),
          const SizedBox(height: 32),

          // Role Selection
          _buildRoleSelection(),
          const SizedBox(height: 32),

          // Terms Agreement
          _buildTermsAgreement(),
          const SizedBox(height: 32),

          // Sign Up Button
          _buildSignupButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "full_name".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.nameController,
          hintText: "enter_your_full_name".tr,
          prefixIcon: Icon(Icons.person_outline_rounded),
          keyboardType: TextInputType.name,
          validator: controller.validateName,
          borderRadius: 12,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "email_address".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.emailController,
          hintText: "enter_your_email".tr,
          prefixIcon: Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
          borderRadius: 12,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "password".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => CustomTextField(
          controller: controller.passwordController,
          hintText: "create_secure_password".tr,
          prefixIcon: Icon(Icons.lock_outline_rounded),
          obscureText: controller.isPasswordHidden.value,
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordHidden.value
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          validator: controller.validatePassword,
          borderRadius: 12,
        )),
        const SizedBox(height: 8),
        Text(
          "password_requirement".tr,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "select_your_role".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                icon: Icons.local_taxi_rounded,
                title: "driver".tr,
                description: "offer_rides_earn_money".tr,
                isSelected: controller.selectedRole.value == "Driver",
                onTap: () => controller.selectRole("Driver"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRoleCard(
                icon: Icons.person_rounded,
                title: "passenger".tr,
                description: "book_rides_travel".tr,
                isSelected: controller.selectedRole.value == "Passenger",
                onTap: () => controller.selectRole("Passenger"),
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                height: 1.3,
                fontSize: 10
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return Obx(() => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: controller.toggleTermsAgreement,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              color: controller.agreeToTerms.value
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: controller.agreeToTerms.value
                    ? AppColors.primary
                    : AppColors.border,
                width: 2,
              ),
            ),
            child: controller.agreeToTerms.value
                ? const Icon(
              Icons.check_rounded,
              size: 14,
              color: Colors.white,
            )
                : null,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                TextSpan(text: "i_agree_to_the".tr),
                TextSpan(
                  text: " ${"terms_of_service".tr} ",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: controller.termsTapRecognizer,
                ),
                TextSpan(text: "and".tr),
                TextSpan(
                  text: " ${"privacy_policy".tr}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: controller.privacyTapRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildSignupButton() {
    return Obx(() => CustomButton(
      text: "create_account".tr,
      onPressed: controller.agreeToTerms.value && !controller.isLoading.value
          ? controller.onSignupPressed
          : null,
      isLoading: controller.isLoading.value,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      borderRadius: 16,
      hasShadow: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "create_account".tr,
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
              Icons.arrow_forward_rounded,
              size: 20,
              color: Colors.white,
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use Row for wider screens, Column for narrow screens
          if (constraints.maxWidth > 400) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    "already_have_account".tr,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: controller.onSignIn,
                  child: Text(
                    "sign_in_now".tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "already_have_account".tr,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: controller.onSignIn,
                  child: Text(
                    "sign_in_now".tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }}