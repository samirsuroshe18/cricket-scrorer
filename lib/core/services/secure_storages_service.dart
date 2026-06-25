import 'dart:developer';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// A service for managing **encrypted key-value storage** using
/// [FlutterSecureStorage], integrated with GetX's [GetxService].
///
/// Unlike SharedPreferences, all values are securely encrypted.
/// Supported value type is `String`.
///
/// ### Usage:
/// ```dart
/// // Register the service
/// final secure = Get.put(SecureStorageService());
///
/// // Initialize it before use
/// await secure.init();
///
/// // Store values
/// await secure.set("token", "abcd1234");
///
/// // Retrieve values
/// final token = await secure.get("token");
///
/// // Get all keys
/// final keys = await secure.getKeys();
///
/// // Clear all data
/// await secure.clear();
/// ```
class SecureStorageService extends GetxService {
  FlutterSecureStorage? _secureStorage;

  static SecureStorageService get secure => Get.find<SecureStorageService>();

  /// Initializes the [FlutterSecureStorage] instance.
  ///
  /// Must be called before accessing or modifying data.
  Future<SecureStorageService> init() async {
    _secureStorage = const FlutterSecureStorage();
    return this;
  }

  /// Ensures that the [FlutterSecureStorage] instance has been initialized.
  void _instanceChecker() {
    if (_secureStorage == null) {
      log(
        name: 'SecureStorageService',
        '🔒 SecureStorageService is not initialized!',
      );
      throw Exception('🔒 SecureStorageService is not initialized!');
    }
  }

  /// Retrieves a securely stored value for the given [key].
  ///
  /// Returns `null` if the key does not exist or the service is not initialized.
  Future<String?> get(String key) async {
    _instanceChecker();
    return await _secureStorage?.read(key: key);
  }

  /// Stores a securely encrypted [value] for the given [key].
  ///
  /// Only [String] values are supported.
  Future<void> set(String key, String value) async {
    _instanceChecker();
    await _secureStorage?.write(key: key, value: value);
  }

  /// Deletes the value associated with the given [key].
  Future<void> remove(String key) async {
    _instanceChecker();
    await _secureStorage?.delete(key: key);
  }

  /// Returns all keys currently stored in [FlutterSecureStorage].
  Future<Set<String>> getKeys() async {
    _instanceChecker();
    final all = await _secureStorage?.readAll();
    return all?.keys.toSet() ?? {};
  }

  /// Clears all data from [FlutterSecureStorage].
  Future<void> clear() async {
    _instanceChecker();
    await _secureStorage?.deleteAll();
  }

  Future<bool> authTokenExists() async {
    String? token = await get(SharedPrefKey.accessToken);
    if (token != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> clearForLogout() async {
    _instanceChecker();
    await _secureStorage?.delete(key: SharedPrefKey.accessToken);
    await _secureStorage?.delete(key: SharedPrefKey.refreshToken);
  }
}
