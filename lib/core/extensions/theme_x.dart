import 'package:cricket_scorer/core/extensions/app_custom_colors.dart';
import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  AppCustomColors get colors => Theme.of(this).extension<AppCustomColors>()!;
}
