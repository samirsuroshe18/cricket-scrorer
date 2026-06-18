import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomButtonTheme {
  CustomButtonTheme._();

  // --- Light Button Themes ---
  static ElevatedButtonThemeData lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.primaryRed,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColor.lightBorder,
      disabledForegroundColor: AppColor.lightTextSecondary,
      elevation: 0,
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static OutlinedButtonThemeData lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColor.lightTextPrimary,
      disabledForegroundColor: AppColor.lightTextSecondary,
      side: const BorderSide(color: AppColor.lightBorder, width: 1.5),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static TextButtonThemeData lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColor.lightTeamBlue,
      disabledForegroundColor: AppColor.lightTextSecondary,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static IconButtonThemeData lightIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColor.lightTextPrimary,
      disabledForegroundColor: AppColor.lightTextSecondary,
      padding: const EdgeInsets.all(8),
    ),
  );

  // --- Dark Button Themes ---
  static ElevatedButtonThemeData darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColor.primaryRed,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColor.darkBorder,
      disabledForegroundColor: AppColor.darkTextMuted,
      elevation: 0,
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static OutlinedButtonThemeData darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColor.darkTextPrimary,
      disabledForegroundColor: AppColor.darkTextMuted,
      side: const BorderSide(color: AppColor.darkBorder, width: 1.5),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static TextButtonThemeData darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColor.darkBlue,
      disabledForegroundColor: AppColor.darkTextMuted,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static IconButtonThemeData darkIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColor.darkTextPrimary,
      disabledForegroundColor: AppColor.darkTextMuted,
      padding: const EdgeInsets.all(8),
    ),
  );
}