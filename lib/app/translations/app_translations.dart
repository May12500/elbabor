import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static Map<String, Map<String, String>> translations = {};

  static Future<void> load() async {
    final enData = await rootBundle.loadString('lib/app/translations/en_US.json');
    final frData = await rootBundle.loadString('lib/app/translations/fr_FR.json');

    translations['en_US'] = Map<String, String>.from(jsonDecode(enData));
    translations['fr_FR'] = Map<String, String>.from(jsonDecode(frData));
  }

  @override
  Map<String, Map<String, String>> get keys => translations;
}
