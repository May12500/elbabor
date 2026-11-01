import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageService extends Translations {
  static final GetStorage _box = GetStorage();
  static const String _key = 'language';

  static Map<String, Map<String, String>> _translations = {};

  static Future<void> init() async {
    final enData = await rootBundle.loadString('lib/app/translations/en_US.json');
    final frData = await rootBundle.loadString('lib/app/translations/fr_FR.json');
    final arData = await rootBundle.loadString('lib/app/translations/ar_AR.json');

    _translations['en_US'] = Map<String, String>.from(jsonDecode(enData));
    _translations['fr_FR'] = Map<String, String>.from(jsonDecode(frData));
    _translations['ar_AR'] = Map<String, String>.from(jsonDecode(arData));
  }

  @override
  Map<String, Map<String, String>> get keys => _translations;

  static Locale getLocale() {
    String? langCode = _box.read(_key);
    if (langCode != null) {
      return Locale(langCode.split('_')[0], langCode.split('_')[1]);
    }
    return const Locale('en', 'US');
  }

  String getCurrentLang() {
    String? langCode = _box.read(_key);
    return langCode ?? 'en_US';
  }

  void changeLocale(String langCode) {
    final parts = langCode.split('_');
    final locale = Locale(parts[0], parts[1]);
    Get.updateLocale(locale);
    _box.write(_key, langCode);
  }
}
