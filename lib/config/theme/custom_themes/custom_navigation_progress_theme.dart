import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomNavigationProgressTheme {
  CustomNavigationProgressTheme._();

  // LIGHT
  static BottomNavigationBarThemeData lightBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: CustomColorScheme.lightColorScheme.surface,
        elevation: 8,
        selectedItemColor: CustomColorScheme.lightColorScheme.secondary,
        unselectedItemColor:
            CustomColorScheme.lightColorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
      );

  static ProgressIndicatorThemeData lightProgressIndicatorTheme =
      ProgressIndicatorThemeData(
        color: AppColor.primaryRed,
        linearTrackColor: CustomColorScheme.lightColorScheme.outline,
        refreshBackgroundColor: AppColor.primaryRed,
      );

  // DARK
  static BottomNavigationBarThemeData darkBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: CustomColorScheme.darkColorScheme.surface,
        elevation: 8,
        selectedItemColor: CustomColorScheme.darkColorScheme.secondary,
        unselectedItemColor: CustomColorScheme.darkColorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
      );

  static ProgressIndicatorThemeData darkProgressIndicatorTheme =
      ProgressIndicatorThemeData(
        color: AppColor.primaryRed,
        linearTrackColor: CustomColorScheme.darkColorScheme.outline,
        refreshBackgroundColor: AppColor.primaryRed,
      );
}
