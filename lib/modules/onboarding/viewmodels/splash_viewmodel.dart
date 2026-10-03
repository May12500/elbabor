import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';

class SplashViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage();

  final isLoading = true.obs;
  final statusMessage = ''.obs;

  // Animation values with smoother sequencing
  final logoAnimationValue = 0.0.obs;
  final appNameAnimationValue = 0.0.obs;
  final taglineAnimationValue = 0.0.obs;
  final loadingAnimationValue = 0.0.obs;
  final bottomInfoAnimationValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startProfessionalAnimations();
    _startSplashTimer();
  }

  void _startProfessionalAnimations() async {
    // Logo appears first with smooth fade and subtle scale
    await Future.delayed(const Duration(milliseconds: 200));
    logoAnimationValue.value = 1.0;

    // App name appears after logo is mostly visible
    await Future.delayed(const Duration(milliseconds: 600));
    appNameAnimationValue.value = 1.0;

    // Tagline appears shortly after app name
    await Future.delayed(const Duration(milliseconds: 400));
    taglineAnimationValue.value = 1.0;

    // Loading indicator appears when content is fully visible
    await Future.delayed(const Duration(milliseconds: 400));
    loadingAnimationValue.value = 1.0;

    // Bottom info appears last for a polished finish
    await Future.delayed(const Duration(milliseconds: 600));
    bottomInfoAnimationValue.value = 1.0;
  }

  /// Professional splash timing - total ~3 seconds
  Future<void> _startSplashTimer() async {
    statusMessage.value = 'initializing'.tr;

    // Wait for animations to complete plus additional time
    await Future.delayed(const Duration(milliseconds: 2200));
    statusMessage.value = 'checking_auth'.tr;

    await Future.delayed(const Duration(milliseconds: 800));
    await _checkAuthState();

    debugPrint('SplashViewModel: Professional splash sequence completed');
  }

  /// Check if user is logged in and redirect accordingly
  Future<void> _checkAuthState() async {
    try {
      statusMessage.value = 'loading_user_data'.tr;

      final user = _auth.currentUser;
      final isFirstLaunch = box.read('isFirstLaunch') ?? true;
      final languageSelected = box.read('language_selected') ?? false;

      // 0️⃣ Check if language is selected (NEW)
      if (!languageSelected) {
        await _handleLanguageSelection();
        return;
      }

      // 1️⃣ If user logged in → check Firestore role
      if (user != null) {
        await _handleAuthenticatedUser(user);
      }
      // // 2️⃣ First-time user → show onboarding
      else if (isFirstLaunch) {
        await _handleFirstLaunch();
      }
      // 3️⃣ Not logged in → go to Auth screen
      else {
        await _handleUnauthenticatedUser();
      }
    } catch (e) {
      debugPrint("SplashViewModel: Unexpected error → $e");
      statusMessage.value = 'error_occurred'.tr;
      // Fallback to auth screen after delay
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(Routes.AUTH);
    }
  }
// Add this new method to SplashViewModel
  Future<void> _handleLanguageSelection() async {
    statusMessage.value = 'language_selection'.tr;
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed(Routes.LANGUAGE_SELECTION);
  }

  Future<void> _handleAuthenticatedUser(User user) async {
    try {
      statusMessage.value = 'fetching_profile'.tr;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final role = doc['role'] ?? '';
        final name = doc['name'] ?? 'User';

        debugPrint("SplashViewModel: Logged in user → $name, role → $role");

        statusMessage.value = 'welcome_back'.trParams({'name': name});

        // Brief pause to show welcome message
        await Future.delayed(const Duration(milliseconds: 800));

        if (role == 'Driver') {
          Get.offAllNamed(Routes.DRIVER_HOME);
        } else if (role == 'Passenger') {
          Get.offAllNamed(Routes.PASSENGER_HOME);
        } else {
          debugPrint("SplashViewModel: Unknown role, redirecting to AUTH");
          Get.offAllNamed(Routes.AUTH);
        }
      } else {
        debugPrint("SplashViewModel: Firestore user doc not found");
        statusMessage.value = 'profile_not_found'.tr;
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.AUTH);
      }
    } catch (e) {
      debugPrint("SplashViewModel: Error while fetching user → $e");
      statusMessage.value = 'connection_error'.tr;
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(Routes.AUTH);
    }
  }

  Future<void> _handleFirstLaunch() async {
    statusMessage.value = 'welcome_new_user'.tr;
    box.write('isFirstLaunch', false);
    await Future.delayed(const Duration(milliseconds: 800));
    Get.offAllNamed(Routes.AUTH);
    // Get.offAllNamed(Routes.ONBOARDING);
  }

  Future<void> _handleUnauthenticatedUser() async {
    statusMessage.value = 'redirecting_to_login'.tr;
    await Future.delayed(const Duration(milliseconds: 800));
    Get.offAllNamed(Routes.AUTH);
  }
}