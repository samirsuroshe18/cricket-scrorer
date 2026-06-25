import 'package:flutter/material.dart';

import 'app_custom_colors.dart';

extension ThemeDataExtensions on ThemeData {
  AppCustomColors get colors => extension<AppCustomColors>()!;
}
