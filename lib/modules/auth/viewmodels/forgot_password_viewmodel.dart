import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbabor/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';

class ForgotPasswordViewModel extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final emailError = RxString('');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void clearEmailError() => emailError.value = '';

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_email".tr;
    }
    if (!GetUtils.isEmail(value.trim())) {
      return "enter_valid_email".tr;
    }
    return null;
  }

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "validation_error".tr,
        "please_fix_errors".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    emailError.value = '';

    try {
      final email = emailController.text.trim();

      debugPrint("Attempting to send reset email to: $email");

      // Check if user exists in Firestore first
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // Show user not found dialog with signup option
        _showUserNotFoundDialog(email);
        return;
      }

      // User exists, send reset email
      await _auth.sendPasswordResetEmail(email: email);

      debugPrint("Password reset email sent successfully to: $email");

      // Show success dialog
      _showSuccessDialog();

    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseError(e.code);
      emailError.value = message;

      debugPrint("FirebaseAuthException: ${e.code} — ${e.message}");

      _showErrorDialog(
        title: "reset_failed".tr,
        message: message,
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
      );

    } catch (e) {
      debugPrint("Password Reset Error: $e");

      _showErrorDialog(
        title: "error_occurred".tr,
        message: "try_again_later".tr,
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showUserNotFoundDialog(String email) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 40,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              "account_not_found".tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              "no_account_associated_with_email".tr + email,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              "would_you_like_to_signup".tr,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "cancel".tr,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Sign Up Button
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close this dialog
              Get.back(); // Go back to login
              // Navigate to signup with pre-filled email
              Get.toNamed(Routes.SIGNUP, arguments: {'email': email});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "sign_up_now".tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              "reset_link_sent".tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "check_your_email".tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          emailController.text.trim(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "check_spam_folder".tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "back_to_login".tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "try_again".tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  String _getFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return "no_user_found_with_email".tr;
      case 'invalid-email':
        return "invalid_email_format".tr;
      case 'too-many-requests':
        return "too_many_attempts".tr;
      case 'network-request-failed':
        return "network_error".tr;
      case 'user-disabled':
        return "account_disabled".tr;
      case 'invalid-continue-uri':
        return "invalid_app_configuration".tr;
      case 'unauthorized-continue-uri':
        return "app_domain_not_authorized".tr;
      default:
        return "unexpected_error_try_again".tr;
    }
  }
}