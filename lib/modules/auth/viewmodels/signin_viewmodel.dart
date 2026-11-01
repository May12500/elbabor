import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';

class SigninViewModel extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final emailError = RxString('');
  final passwordError = RxString('');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkRememberedUser();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _checkRememberedUser() {
    final rememberedEmail = _storage.read('remembered_email');
    if (rememberedEmail != null) {
      emailController.text = rememberedEmail;
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void clearEmailError() => emailError.value = '';
  void clearPasswordError() => passwordError.value = '';

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

  Future<void> onLoginPressed() async {
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
    passwordError.value = '';

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Sign in with Firebase Auth
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Remember email for next time
      _storage.write('remembered_email', email);

      // Fetch user details from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (!userDoc.exists) {
        Get.snackbar(
          "login_failed".tr,
          "user_not_found".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
        await _auth.signOut();
        return;
      }

      final userData = userDoc.data()!;
      final role = userData['role'] ?? '';
      final name = userData['name'] ?? 'User';
      final profileCompleted = userData['profileCompleted'] ?? false;

      // Show welcome message
      Get.snackbar(
        "welcome_back".tr,
        "welcome_message".tr + name,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );

      // Redirect based on user role and profile completion
      await Future.delayed(const Duration(milliseconds: 500));

      if (role == 'Driver') {
        if (profileCompleted == true) {
          Get.offAllNamed(Routes.DRIVER_HOME);
        } else {
          Get.offAllNamed(Routes.DRIVER_DETAILS);
        }
      } else if (role == 'Passenger') {
        Get.offAllNamed(Routes.PASSENGER_HOME);
      } else {
        Get.snackbar(
          "login_failed".tr,
          "invalid_role".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
      }

    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseError(e.code);
      emailError.value = message;

      Get.snackbar(
        "login_failed".tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      debugPrint("FirebaseAuthException: ${e.code} — ${e.message}");
    } catch (e) {
      Get.snackbar(
        "error_occurred".tr,
        "try_again_later".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      debugPrint("General Login Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _getFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return "no_user_found".tr;
      case 'wrong-password':
        return "incorrect_password".tr;
      case 'invalid-email':
        return "invalid_email_format".tr;
      case 'too-many-requests':
        return "too_many_attempts".tr;
      case 'invalid-credential':
        return "invalid_credentials".tr;
      case 'user-disabled':
        return "account_disabled".tr;
      case 'network-request-failed':
        return "network_error".tr;
      default:
        return "unexpected_error".tr;
    }
  }

  void onForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  void onContinueAsGuest() {
    // TODO: Implement forgot password flow
    Get.snackbar(
      "coming_soon".tr,'This Feature is not available yet',
      snackPosition: SnackPosition.BOTTOM,
    );
    // _storage.write('is_guest', true);
    // Get.offAllNamed(Routes.PASSENGER_HOME);
  }

  void onSignUp() => Get.offAllNamed(Routes.SIGNUP);
}