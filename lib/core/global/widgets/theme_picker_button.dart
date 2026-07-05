import 'dart:async';

import 'package:cricket_scorer/core/extensions/string_extension.dart';
import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemePickerButton extends StatelessWidget {
  const ThemePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(() {
      final icon = switch (themeService.themeMode) {
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
        ThemeMode.system => Icons.settings_suggest,
      };

      return IconButton(
        icon: Icon(icon),
        tooltip: 'Theme'.translation(),
        onPressed: () => unawaited(themeService.selectTheme()),
      );
    });
  }
}