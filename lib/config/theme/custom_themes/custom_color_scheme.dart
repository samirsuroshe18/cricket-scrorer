import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomColorScheme {
  CustomColorScheme._();

  static ColorScheme lightColorScheme = const ColorScheme.light(
    primary: AppColor.primaryRed,
    onPrimary: Colors.white,
    secondary: AppColor.lightTeamBlue,
    onSecondary: Colors.white,
    surface: AppColor.lightCard,
    onSurface: AppColor.lightTextPrimary,
    error: AppColor.lightRedDark,
    onError: Colors.white,
    outline: AppColor.lightBorder,
  );

  static ColorScheme darkColorScheme = const ColorScheme.dark(
    primary: AppColor.primaryRed,
    onPrimary: Colors.white,
    secondary: AppColor.darkBlue,
    onSecondary: Colors.white,
    surface: AppColor.darkCardBg,
    onSurface: AppColor.darkTextPrimary,
    error: AppColor.darkError,
    onError: Colors.white,
    outline: AppColor.darkBorder,
  );
}