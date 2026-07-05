import 'package:cricket_scorer/core/extensions/app_custom_colors.dart';
import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  AppCustomColors get colors => Theme.of(this).extension<AppCustomColors>()!;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get isLight => !isDark;
}
