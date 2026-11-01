import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/constants/assets.dart';
import '../../../app/routes/app_routes.dart';

class OnboardingViewModel extends GetxController {
  final GetStorage _storage = GetStorage();
  final currentPageIndex = 0.obs;

  final List<Map<String, String>> onboardingSlides = [
    {
      'title': 'onboarding_welcome_to_elbabor'.tr,
      'subtitle': 'onboarding_welcome_subtitle'.tr,
      'image': Assets.onboard1,
    },
    {
      'title': 'onboarding_multiple_transport_options'.tr,
      'subtitle': 'onboarding_transport_options_subtitle'.tr,
      'image': Assets.onboard2,
    },
    {
      'title': 'onboarding_smart_ride_sharing'.tr,
      'subtitle': 'onboarding_ride_sharing_subtitle'.tr,
      'image': Assets.onboard3,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeOnboarding();
  }

  void _initializeOnboarding() {
    // Any initialization logic can go here
    debugPrint('OnboardingViewModel initialized');
  }

  void completeOnboarding() {
    // Mark onboarding as completed
    _storage.write('onboarding_completed', true);

    // Navigate to authentication screen
    Get.offAllNamed(Routes.AUTH);

    debugPrint('Onboarding completed, navigating to auth');
  }

  void skipOnboarding() {
    // Mark onboarding as completed even when skipped
    _storage.write('onboarding_completed', true);

    // Navigate directly to authentication screen
    Get.offAllNamed(Routes.AUTH);

    debugPrint('Onboarding skipped, navigating to auth');
  }

  void goToNextPage() {
    if (currentPageIndex.value < onboardingSlides.length - 1) {
      currentPageIndex.value++;
    } else {
      completeOnboarding();
    }
  }

  void goToPreviousPage() {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
    }
  }

  bool get isFirstPage => currentPageIndex.value == 0;
  bool get isLastPage => currentPageIndex.value == onboardingSlides.length - 1;
}