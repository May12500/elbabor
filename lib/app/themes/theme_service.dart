import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_theme.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  bool get isDarkMode => _loadThemeFromBox();

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  void switchTheme() {
    final isDark = !_loadThemeFromBox();
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToBox(isDark);
  }

  static ThemeData getLightTheme() => AppTheme.lightTheme;

  static ThemeData getDarkTheme() => ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(),
  );
}
