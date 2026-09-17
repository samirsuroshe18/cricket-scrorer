import 'dart:developer';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
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
  ///
  /// `unlocked_this_device` keeps iOS Keychain items out of encrypted
  /// backups entirely, so they can never resurface on a different device
  /// via a backup restore — the default `unlocked` accessibility allows
  /// exactly that. This narrows, but doesn't by itself solve, the wider
  /// "Keychain survives uninstall" gap: see [reconcileWithInstall].
  Future<SecureStorageService> init() async {
    _secureStorage = const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
      ),
    );
    return this;
  }

  /// Reconciles the Keychain against a fresh install.
  ///
  /// Uninstalling an iOS app wipes [SharedPreferences] but **not** the
  /// Keychain — tokens written before the uninstall are still there after
  /// a reinstall, unlike on Android where both are wiped together. A
  /// marker written to [SharedPreferences] (via [prefs]) doubles as a
  /// "has this device's app data actually survived since last launch?"
  /// check: if it's missing, the Keychain is stale (either a genuine first
  /// launch with nothing to clear, or a reinstall with leftover tokens)
  /// and gets cleared before anything reads it.
  ///
  /// [SharedPrefKey.userDetails] is the guard against a false positive on
  /// the update that ships this check: it's written in the same breath as
  /// the Keychain tokens ([LoginController]), so on an existing install its
  /// presence means this device's [SharedPreferences] predates the marker
  /// rather than having just been wiped — the marker gets back-filled
  /// without touching a real, still-valid session.
  Future<void> reconcileWithInstall(SharedPreferenceService prefs) async {
    _instanceChecker();
    final hasLaunchedBefore =
        prefs.get(SharedPrefKey.installMarker) as bool? ?? false;
    if (hasLaunchedBefore) return;

    final hasExistingSession = prefs.get(SharedPrefKey.userDetails) != null;
    if (!hasExistingSession) {
      await clear();
    }
    await prefs.set(SharedPrefKey.installMarker, true);
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
