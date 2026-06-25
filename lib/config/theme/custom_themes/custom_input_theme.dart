import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/material.dart';

class CustomInputTheme {
  CustomInputTheme._();

  // ==========================================================
  // LIGHT
  // ==========================================================
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: CustomColorScheme.lightColorScheme.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),

    hintStyle: TextStyle(
      color: CustomColorScheme.lightColorScheme.onSurfaceVariant,
      fontSize: 14,
    ),

    labelStyle: TextStyle(
      color: CustomColorScheme.lightColorScheme.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),

    errorStyle: const TextStyle(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),

    suffixIconColor: CustomColorScheme.lightColorScheme.onSurfaceVariant,

    prefixIconColor: CustomColorScheme.lightColorScheme.onSurfaceVariant,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: CustomColorScheme.lightColorScheme.outline,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: CustomColorScheme.lightColorScheme.outline,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: CustomColorScheme.lightColorScheme.secondary,
        width: 1.5,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
  );

  // ==========================================================
  // DARK
  // ==========================================================
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: CustomColorScheme.darkColorScheme.surface,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),

    hintStyle: TextStyle(
      color: CustomColorScheme.darkColorScheme.onSurfaceVariant,
      fontSize: 14,
    ),

    labelStyle: TextStyle(
      color: CustomColorScheme.darkColorScheme.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),

    errorStyle: const TextStyle(
      color: Colors.red,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),

    suffixIconColor: CustomColorScheme.darkColorScheme.onSurfaceVariant,

    prefixIconColor: CustomColorScheme.darkColorScheme.onSurfaceVariant,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: CustomColorScheme.darkColorScheme.outline,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: CustomColorScheme.darkColorScheme.outline,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: CustomColorScheme.darkColorScheme.secondary,
        width: 1.5,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
  );
}
