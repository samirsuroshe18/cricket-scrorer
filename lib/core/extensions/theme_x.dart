import 'package:cricket_scorer/core/extensions/app_custom_colors.dart';
import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  AppCustomColors get colors => theme.extension<AppCustomColors>()!;

  bool get isDark => theme.brightness == Brightness.dark;

  bool get isLight => !isDark;
}
