import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elbabor/app/themes/app_colors.dart';
import 'package:elbabor/app/themes/app_text_styles.dart';
import 'package:elbabor/app/widgets/custom_button.dart';
import 'package:elbabor/app/widgets/custom_text_field.dart';
import 'package:elbabor/app/constants/assets.dart';
import '../viewmodels/signin_viewmodel.dart';

class SigninView extends GetView<SigninViewModel> {
  const SigninView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 10),
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(),

                // Form Section
                _buildFormSection(),

                // Action Buttons
                _buildActionButtons(),

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
              "sign_in".tr,
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
          "welcome_back".tr,
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
          // Email Field
          _buildEmailField(),
          const SizedBox(height: 20),

          // Password Field
          _buildPasswordField(),
          const SizedBox(height: 16),

          // Forgot Password
          _buildForgotPassword(),
          const SizedBox(height: 32),

          // Sign In Button
          _buildSigninButton(),
        ],
      ),
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
          onChanged: (value) => controller.clearEmailError(),
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
          hintText: "enter_your_password".tr,
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
          onChanged: (value) => controller.clearPasswordError(),
        )),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: controller.onForgotPassword,
        child: Text(
          "forgot_password".tr,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSigninButton() {
    return Obx(() => CustomButton(
      text: "sign_in".tr,
      onPressed: controller.isLoading.value ? null : controller.onLoginPressed,
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
            "sign_in".tr,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
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
            "continue_as_guest".tr,
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
            "or".tr,
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

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "dont_have_account".tr,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: controller.onSignUp,
            child: Text(
              "create_account".tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}