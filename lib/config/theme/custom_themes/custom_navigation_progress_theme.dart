import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomNavigationProgressTheme {
  CustomNavigationProgressTheme._();

  // --- Light Variations ---
  static const BottomNavigationBarThemeData lightBottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: AppColor.lightCard,
    elevation: 8,
    selectedItemColor: AppColor.lightTeamBlue,
    unselectedItemColor: AppColor.lightTextSecondary,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    type: BottomNavigationBarType.fixed,
  );

  static const ProgressIndicatorThemeData lightProgressIndicatorTheme = ProgressIndicatorThemeData(
    color: AppColor.primaryRed,
    linearTrackColor: AppColor.lightBorder,
    refreshBackgroundColor: AppColor.primaryRed,
  );

  // --- Dark Variations ---
  static const BottomNavigationBarThemeData darkBottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: AppColor.darkCardBg,
    elevation: 8,
    selectedItemColor: AppColor.darkBlue,
    unselectedItemColor: AppColor.darkTextMuted,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    type: BottomNavigationBarType.fixed,
  );

  static const ProgressIndicatorThemeData darkProgressIndicatorTheme = ProgressIndicatorThemeData(
    color: AppColor.primaryRed,
    linearTrackColor: AppColor.darkBorder,
    refreshBackgroundColor: AppColor.primaryRed,
  );
}