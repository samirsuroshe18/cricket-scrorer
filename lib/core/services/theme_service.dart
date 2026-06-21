import 'dart:async';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class ThemeService extends GetxService {
  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    _themeMode.value = await _loadTheme();
  }

  Future<ThemeMode> _loadTheme() async {
    final String? saved =
        await SharedPreferenceService.sharedPrefService.get(
              SharedPrefKey.themeMode,
            )
            as String?;

    if (saved == null) {
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }

    return switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);

    final String value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };

    unawaited(
      SharedPreferenceService.sharedPrefService.set(
        SharedPrefKey.themeMode,
        value,
      ),
    );
  }
}
