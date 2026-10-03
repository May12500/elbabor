import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';

class AuthViewModel extends GetxController {
  final GetStorage _storage = GetStorage();
  final isLoading = false.obs;

  void onSignIn() {
    Get.toNamed(Routes.SIGNIN);
  }

  void onSignUp() {
    Get.toNamed(Routes.SIGNUP);
  }

  void onContinueAsGuest() {
    isLoading.value = true;

    // Simulate some processing
    Future.delayed(const Duration(milliseconds: 500), () {
      isLoading.value = false;
      _storage.write('is_guest', true);
      Get.offAllNamed(Routes.PASSENGER_HOME);
    });
  }

  void onPrivacyPolicy() {
    // TODO: Implement privacy policy navigation
    // Get.toNamed(Routes.PRIVACY_POLICY);
    // Or open webview
    Get.snackbar(
      'privacy_policy'.tr,
      'opening_privacy_policy'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onTermsOfService() {
    // TODO: Implement terms of service navigation
    // Get.toNamed(Routes.TERMS_OF_SERVICE);
    // Or open webview
    Get.snackbar(
      'terms_of_service'.tr,
      'opening_terms_service'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _checkIfGuest();
  }

  void _checkIfGuest() {
    final isGuest = _storage.read('is_guest') ?? false;
    if (isGuest) {
      // Optionally redirect guest users
      // Get.offAllNamed(Routes.PASSENGER_HOME);
    }
  }
}