import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:elbabor/app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../data/models/user_model.dart';

class SignupViewModel extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final selectedRole = ''.obs;
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final agreeToTerms = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final TapGestureRecognizer termsTapRecognizer;
  late final TapGestureRecognizer privacyTapRecognizer;

  @override
  void onInit() {
    super.onInit();
    termsTapRecognizer = TapGestureRecognizer()..onTap = onTermsOfService;
    privacyTapRecognizer = TapGestureRecognizer()..onTap = onPrivacyPolicy;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    termsTapRecognizer.dispose();
    privacyTapRecognizer.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleTermsAgreement() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  void selectRole(String role) {
    selectedRole.value = role;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_your_name".tr;
    }
    if (value.trim().length < 2) {
      return "name_too_short".tr;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "please_enter_email".tr;
    }
    if (!GetUtils.isEmail(value.trim())) {
      return "enter_valid_email".tr;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "please_enter_password".tr;
    }
    if (value.length < 6) {
      return "password_min_length".tr;
    }
    return null;
  }

  Future<void> onSignupPressed() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "validation_error".tr,
        "please_fix_errors".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        "select_role".tr,
        "please_select_role".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (!agreeToTerms.value) {
      Get.snackbar(
        "terms_required".tr,
        "agree_to_terms".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final name = nameController.text.trim();
      final role = selectedRole.value;

      // Check if email already exists for this role
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: role)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        Get.snackbar(
          "email_exists".tr,
          "email_already_registered".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
        return;
      }

      // Create Firebase Auth account
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      // Store user info in Firestore
      final user = UserModel(
        uid: userCred.user!.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
        profileCompleted: false,
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      // Success - navigate based on role
      Get.snackbar(
        "success".tr,
        "account_created_success".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );

      if (role == 'Driver') {
        Get.offAllNamed(Routes.DRIVER_DETAILS);
      } else {
        Get.offAllNamed(Routes.PASSENGER_HOME);
      }

    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseError(e.code);
      Get.snackbar(
        "signup_failed".tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      Get.snackbar(
        "error_occurred".tr,
        "try_again_later".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      debugPrint('Signup Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "email_already_used".tr;
      case 'invalid-email':
        return "invalid_email_format".tr;
      case 'weak-password':
        return "weak_password_requirement".tr;
      case 'network-request-failed':
        return "network_error".tr;
      case 'too-many-requests':
        return "too_many_attempts".tr;
      default:
        return "unexpected_error".tr;
    }
  }

  void onSignIn() => Get.offAllNamed(Routes.SIGNIN);

  void onTermsOfService() {
    // TODO: Navigate to terms of service
    Get.snackbar(
      "terms_of_service".tr,
      "opening_terms".tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onPrivacyPolicy() {
    // TODO: Navigate to privacy policy
    Get.snackbar(
      "privacy_policy".tr,
      "opening_privacy".tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}