import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static TextTheme baseTheme = GoogleFonts.plusJakartaSansTextTheme();

  static TextTheme lightTextTheme = baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.lightColorScheme.onSurface,
      letterSpacing: -0.5,
    ),
    headlineLarge: baseTheme.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    headlineMedium: baseTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    titleLarge: baseTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    titleMedium: baseTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    titleSmall: baseTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    bodyLarge: baseTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    bodyMedium: baseTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: CustomColorScheme.lightColorScheme.onSurfaceVariant,
    ),
    bodySmall: baseTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: CustomColorScheme.lightColorScheme.onSurfaceVariant,
    ),
    labelLarge: baseTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    labelSmall: baseTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: CustomColorScheme.lightColorScheme.onSurfaceVariant,
    ),
  );

  static TextTheme darkTextTheme = baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.darkColorScheme.onSurface,
      letterSpacing: -0.5,
    ),
    headlineLarge: baseTheme.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    headlineMedium: baseTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    titleLarge: baseTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    titleMedium: baseTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    titleSmall: baseTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    bodyLarge: baseTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    bodyMedium: baseTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: CustomColorScheme.darkColorScheme.onSurfaceVariant,
    ),
    bodySmall: baseTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: CustomColorScheme.darkColorScheme.onSurfaceVariant,
    ),
    labelLarge: baseTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    labelSmall: baseTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: CustomColorScheme.darkColorScheme.onSurfaceVariant,
    ),
  );
}
