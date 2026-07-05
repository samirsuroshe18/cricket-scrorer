import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/material.dart';

class CustomButtonTheme {
  CustomButtonTheme._();

  // ==========================================================
  // LIGHT BUTTON THEMES
  // ==========================================================
  static ElevatedButtonThemeData lightElevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColorScheme.lightColorScheme.primary,
          foregroundColor: CustomColorScheme.lightColorScheme.onPrimary,
          disabledBackgroundColor: CustomColorScheme.lightColorScheme.outline,
          disabledForegroundColor:
              CustomColorScheme.lightColorScheme.onSurfaceVariant,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static OutlinedButtonThemeData lightOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CustomColorScheme.lightColorScheme.onSurface,
          disabledForegroundColor:
              CustomColorScheme.lightColorScheme.onSurfaceVariant,
          side: BorderSide(
            color: CustomColorScheme.lightColorScheme.outline,
            width: 1.5,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static TextButtonThemeData lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: CustomColorScheme.lightColorScheme.secondary,
      disabledForegroundColor:
          CustomColorScheme.lightColorScheme.onSurfaceVariant,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static IconButtonThemeData lightIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: CustomColorScheme.lightColorScheme.onSurface,
      disabledForegroundColor:
          CustomColorScheme.lightColorScheme.onSurfaceVariant,
      padding: const EdgeInsets.all(8),
    ),
  );

  // ==========================================================
  // DARK BUTTON THEMES
  // ==========================================================
  static ElevatedButtonThemeData darkElevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColorScheme.darkColorScheme.primary,
          foregroundColor: CustomColorScheme.darkColorScheme.onPrimary,
          disabledBackgroundColor: CustomColorScheme.darkColorScheme.outline,
          disabledForegroundColor:
              CustomColorScheme.darkColorScheme.onSurfaceVariant,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static OutlinedButtonThemeData darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CustomColorScheme.darkColorScheme.onSurface,
          disabledForegroundColor:
              CustomColorScheme.darkColorScheme.onSurfaceVariant,
          side: BorderSide(
            color: CustomColorScheme.darkColorScheme.outline,
            width: 1.5,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static TextButtonThemeData darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: CustomColorScheme.darkColorScheme.secondary,
      disabledForegroundColor:
          CustomColorScheme.darkColorScheme.onSurfaceVariant,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static IconButtonThemeData darkIconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: CustomColorScheme.darkColorScheme.onSurface,
      disabledForegroundColor:
          CustomColorScheme.darkColorScheme.onSurfaceVariant,
      padding: const EdgeInsets.all(8),
    ),
  );
}
