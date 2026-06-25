import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomColorScheme {
  CustomColorScheme._();

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Brand
    primary: AppColor.primaryRed,
    onPrimary: Colors.white,

    secondary: Color(0xff1F78E6),
    onSecondary: Colors.white,

    // Background & Surface
    surface: Colors.white,
    onSurface: Color(0xff1A1F2E),

    surfaceContainerLowest: Color(0xffF7F7FA),

    // Error
    error: Color(0xffA60A0A),
    onError: Colors.white,

    // Border
    outline: Color(0xffE6E6EB),

    tertiary: Color(0xff2EB86B),
    onTertiary: Colors.white,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Brand
    primary: AppColor.primaryRed,
    onPrimary: Colors.white,

    secondary: Color(0xff4D99FF),
    onSecondary: Colors.white,

    // Background & Surface
    surface: Color(0xff1C243D),
    onSurface: Color(0xffF0F2F7),

    surfaceContainerLowest: Color(0xff121729),

    // Error
    error: Color(0xffFF5959),
    onError: Colors.white,

    // Border
    outline: Color(0xff333D61),

    tertiary: Color(0xff38D980),
    onTertiary: Colors.white,
  );
}
