import 'dart:developer';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service for managing persistent key-value storage using
/// [SharedPreferences], integrated with GetX's [GetxService].
///
/// This service provides simple methods to read, write, and clear
/// data in persistent storage. It supports the following types:
/// `bool`, `int`, `double`, `String`, and `List<String>`.
///
/// ### Usage:
/// ```dart
/// // Register the service
/// final prefs = Get.put(SharedPreferenceService());
///
/// // Initialize it before use
/// await prefs.init();
///
/// // Store values
/// await prefs.set("isLoggedIn", true);
/// await prefs.set("username", "john_doe");
///
/// // Retrieve values
/// final loggedIn = prefs.get("isLoggedIn") as bool?;
/// final username = prefs.get("username") as String?;
///
/// // Get all keys
/// final keys = prefs.getKeys();
///
/// // Clear all data
/// await prefs.clear();
/// ```
class SharedPreferenceService extends GetxService {
  SharedPreferences? _sharedPreferences;

  static SharedPreferenceService get sharedPrefService =>
      Get.find<SharedPreferenceService>();

  /// Initializes the [SharedPreferences] instance.
  ///
  /// Must be called before accessing or modifying data.
  Future<SharedPreferenceService> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  /// Ensures that the [SharedPreferences] instance has been initialized.
  ///
  /// Throws an [Exception] if [init] has not been called.
  void _instanceChecker() {
    if (_sharedPreferences == null) {
      log(
        name: 'SharedPreferenceService',
        '🚚 SharedPreferenceService is not initialized !',
      );
      throw Exception('🚚 SharedPreferenceService is not initialized !');
    }
  }

  /// Retrieves a value for the given [key].
  ///
  /// Returns `null` if the key does not exist or the service
  /// is not initialized.
  dynamic get(String key) {
    _instanceChecker();
    return _sharedPreferences?.get(key);
  }

  /// Stores a [value] for the given [key].
  ///
  /// Supported types: [bool], [int], [double], [String], [List<String>].
  ///
  /// Returns `true` if the operation succeeds, otherwise `false`.
  /// Throws an error if the type is not supported.
  Future<bool?> set(String key, dynamic value) async {
    _instanceChecker();

    if (value is bool) {
      return await _sharedPreferences?.setBool(key, value);
    } else if (value is double) {
      return await _sharedPreferences?.setDouble(key, value);
    } else if (value is int) {
      return await _sharedPreferences?.setInt(key, value);
    } else if (value is String) {
      return await _sharedPreferences?.setString(key, value);
    } else if (value is List<String>) {
      return await _sharedPreferences?.setStringList(key, value);
    } else {
      log(
        name: 'SharedPreferenceService',
        '🛑 DataType error, the value must be: bool, int, double, String, List<String>',
      );
      return Future.error(
        '🛑 Unsupported type. Allowed: bool, int, double, String, List<String>',
      );
    }
  }

  /// Returns all keys currently stored in [SharedPreferences].
  Set<String>? getKeys() {
    _instanceChecker();
    return _sharedPreferences?.getKeys();
  }

  /// Clears all data from [SharedPreferences].
  ///
  /// Returns `true` if the operation succeeds, otherwise `false`.
  Future<bool?> clear() async {
    _instanceChecker();
    return await _sharedPreferences?.clear();
  }

  Future<void> clearForLogout() async {
    _instanceChecker();
    await _sharedPreferences?.remove(SharedPrefKey.accessToken);
    await _sharedPreferences?.remove(SharedPrefKey.refreshToken);
    await _sharedPreferences?.remove(SharedPrefKey.isRegistrationCompleted);
    await _sharedPreferences?.remove(SharedPrefKey.userDetails);
    await _sharedPreferences?.remove(SharedPrefKey.isChartered);
    await _sharedPreferences?.remove(SharedPrefKey.userType);
    await _sharedPreferences?.remove(SharedPrefKey.onboardingCompleted);
    await _sharedPreferences?.remove(SharedPrefKey.savedLangVersion);
  }
}
