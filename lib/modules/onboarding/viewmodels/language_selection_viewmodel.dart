import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/translations/language_service.dart';
import '../../../app/routes/app_routes.dart';

class LanguageSelectionViewModel extends GetxController {
  final selectedLanguage = ''.obs;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final savedLanguage = _storage.read('selected_language');
    if (savedLanguage != null) {
      selectedLanguage.value = savedLanguage;
    } else {
      // Default to device locale or English
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null) {
        if (deviceLocale.languageCode == 'fr') {
          selectedLanguage.value = 'fr_FR';
        } else {
          selectedLanguage.value = 'en_US';
        }
      } else {
        selectedLanguage.value = 'en_US';
      }
    }
  }

  void selectLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    LanguageService().changeLocale(languageCode);

  }

  Future<void> onContinue() async {
    if (selectedLanguage.value.isEmpty) return;

    try {
      // Save language preference
      await _storage.write('selected_language', selectedLanguage.value);

      // Apply the selected language
      LanguageService().changeLocale(selectedLanguage.value);

      // Mark language selection as completed
      await _storage.write('language_selected', true);

      // Navigate to next screen (onboarding or auth)
      final isFirstLaunch = _storage.read('isFirstLaunch') ?? true;

      if (isFirstLaunch) {
        _storage.write('isFirstLaunch', false);
        // Get.offAllNamed(Routes.ONBOARDING);
        Get.offAllNamed(Routes.AUTH);
      } else {

        Get.offAllNamed(Routes.AUTH);
      }

    } catch (e) {
      Get.snackbar(
        "error".tr,
        "failed_to_set_language".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Language selection error: $e');
    }
  }

  String getCurrentLanguageName() {
    switch (selectedLanguage.value) {
      case 'en_US':
        return 'English';
      case 'fr_FR':
        return 'Français';
      default:
        return 'English';
    }
  }
}