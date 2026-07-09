import 'package:flutter/material.dart';
import 'package:skinoura/database/preferences_handler.dart';

class ThemeColor {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static void init() {
    isDarkMode.value = PreferencesHandler.isDarkMode;
  }

  static Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    await PreferencesHandler.setDarkMode(value);
  }

  static Color get primaryColor {
    return const Color(0xFF7C9A92); // Keep green as primary color
  }
}
