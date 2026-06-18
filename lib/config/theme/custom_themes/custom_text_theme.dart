import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static TextTheme baseTheme = GoogleFonts.plusJakartaSansTextTheme();

  static TextTheme lightTextTheme = baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: AppColor.lightTextPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: baseTheme.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColor.lightTextPrimary,
    ),
    headlineMedium: baseTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColor.lightTextPrimary,
    ),
    titleLarge: baseTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColor.lightTextPrimary,
    ),
    titleMedium: baseTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColor.lightTextPrimary,
    ),
    titleSmall: baseTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColor.lightTextPrimary,
    ),
    bodyLarge: baseTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColor.lightTextPrimary,
    ),
    bodyMedium: baseTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColor.lightTextSecondary,
    ),
    bodySmall: baseTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColor.lightTextSecondary,
    ),
    labelLarge: baseTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColor.lightTextPrimary,
    ),
    labelSmall: baseTheme.labelLarge?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColor.lightTextSecondary,
    ),
  );

  static TextTheme darkTextTheme = baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: AppColor.darkTextPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: baseTheme.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColor.darkTextPrimary,
    ),
    headlineMedium: baseTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColor.darkTextPrimary,
    ),
    titleLarge: baseTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColor.darkTextPrimary,
    ),
    titleMedium: baseTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColor.darkTextPrimary,
    ),
    titleSmall: baseTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColor.darkTextPrimary,
    ),
    bodyLarge: baseTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColor.darkTextPrimary,
    ),
    bodyMedium: baseTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColor.darkTextMuted,
    ),
    bodySmall: baseTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColor.darkPlaceholder,
    ),
    labelLarge: baseTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColor.darkTextPrimary,
    ),
    labelSmall: baseTheme.labelLarge?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColor.darkTextMuted,
    ),
  );
}
