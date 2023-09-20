import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPUtil {
  factory SPUtil() => instance;
  static late final SharedPreferences _preferences;
  SPUtil._();
  static final SPUtil instance = SPUtil._();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _preferences = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<bool> remove(String key) => _preferences.remove(key);

  Future<bool> call(final String key, final Object value) => set(key, value);

  Future<bool> set(final String key, final Object value) async {
    if (key.isEmpty) {
      return false;
    }
    if (value is int) {
      return _preferences.setInt(key, value);
    } else if (value is double) {
      return _preferences.setDouble(key, value);
    } else if (value is bool) {
      return _preferences.setBool(key, value);
    } else if (value is String) {
      return _preferences.setString(key, value);
    } else if (value is List<String>) {
      return _preferences.setStringList(key, value);
    }
    throw Exception('Invalid value type!');
  }

  Future<bool> clear() => _preferences.clear();
  Future<bool> setLoggedIn(bool val) => set("loggedIn", val);
  Future<bool> setCurrentLanguage(String val) => set("currentLanguage", val);

  bool get loggedIn => getBool("loggedIn") ?? false;
  String get currentLanguage => getString("currentLanguage") ?? "";

  String? getString(final String key) => _preferences.getString(key);
  int? getInt(final String key) => _preferences.getInt(key);
  bool? getBool(final String key) => _preferences.getBool(key);
  List<String>? getList(final String key) => _preferences.getStringList(key);
}
