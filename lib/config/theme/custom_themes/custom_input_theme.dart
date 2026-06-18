import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomInputTheme {
  CustomInputTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColor.lightCard,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(color: AppColor.lightTextSecondary, fontSize: 14),
    labelStyle: const TextStyle(color: AppColor.lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
    errorStyle: const TextStyle(color: AppColor.lightRedDark, fontSize: 12, fontWeight: FontWeight.w500),
    suffixIconColor: AppColor.lightTextSecondary,
    prefixIconColor: AppColor.lightTextSecondary,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.lightBorder, width: 1)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.lightBorder, width: 1)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.lightTeamBlue, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.lightRedDark, width: 1)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.lightRedDark, width: 2)),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColor.darkCardBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(color: AppColor.darkPlaceholder, fontSize: 14),
    labelStyle: const TextStyle(color: AppColor.darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
    errorStyle: const TextStyle(color: AppColor.darkError, fontSize: 12, fontWeight: FontWeight.w500),
    suffixIconColor: AppColor.darkTextMuted,
    prefixIconColor: AppColor.darkTextMuted,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.darkBorder, width: 1)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.darkBorder, width: 1)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.darkBlue, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.darkError, width: 1)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColor.darkError, width: 2)),
  );
}