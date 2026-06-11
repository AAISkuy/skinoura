import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHandler {
  static late SharedPreferences _prefs;
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyIsLogin = "isLogin";
  static const _keyNama = "nama";
  static const _keyEmail = "email";
  static const _keyPassword = "password";
  static const _keySkinType = "skinType";
  static const _keyIngredients = "recommendedIngredients";

  static Future<void> setLogin(bool isLogin) async {
    await _prefs.setBool(_keyIsLogin, isLogin);
  }

  static bool get isLogin {
    return _prefs.getBool(_keyIsLogin) ?? false;
  }

  static Future<void> saveUser({
    required String nama,
    required String email,
    required String password,
  }) async {
    await _prefs.setString(_keyNama, nama);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyPassword, password);
  }

  static String get nama {
    return _prefs.getString(_keyNama) ?? "";
  }

  static String get email {
    return _prefs.getString(_keyEmail) ?? "";
  }

  static String get password {
    return _prefs.getString(_keyPassword) ?? "";
  }

  static Future<void> saveSkinType(String skinType) async {
    await _prefs.setString(_keySkinType, skinType);
  }

  static String get skinType {
    return _prefs.getString(_keySkinType) ?? "";
  }

  static Future<void> saveRecommendedIngredients(
    List<String> ingredients,
  ) async {
    String jsonString = jsonEncode(ingredients);
    await _prefs.setString(_keyIngredients, jsonString);
  }

  static List<String> get recommendedIngredients {
    String? jsonString = _prefs.getString(_keyIngredients);
    if (jsonString != null) {
      return List<String>.from(jsonDecode(jsonString));
    }
    return [];
  }

  static Future<void> logOut() async {
    await _prefs.remove(_keyIsLogin);
    await _prefs.remove(_keySkinType);
    await _prefs.remove(_keyIngredients);
  }

  static Future<void> saveStepStatus(String key, bool isDone) async {
    await _prefs.setBool(key, isDone);
  }

  static bool getStepStatus(String key) {
    return _prefs.getBool(key) ?? false;
  }
}
