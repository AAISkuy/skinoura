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

  static Future<void> logOut() async {
    await _prefs.remove(_keyIsLogin);
  }
}
