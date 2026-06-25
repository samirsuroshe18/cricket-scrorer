import 'package:cricket_scorer/config/theme/palettes/app_custom_colors_palette.dart';
import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/material.dart';

class CustomSelectionTheme {
  CustomSelectionTheme._();

  // ==========================================================
  // LIGHT
  // ==========================================================
  static ChipThemeData lightChipTheme = ChipThemeData(
    backgroundColor: AppCustomColorsPalette.light.chipBackground,
    disabledColor: CustomColorScheme.lightColorScheme.outline.withValues(
      alpha: 0.5,
    ),
    selectedColor: AppCustomColorsPalette.light.chipSelected,
    secondarySelectedColor: AppCustomColorsPalette.light.chipSelected,
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    secondaryLabelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.lightColorScheme.secondary,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    side: BorderSide(
      color: CustomColorScheme.lightColorScheme.outline,
      width: 1,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? CustomColorScheme.lightColorScheme.secondary
          : Colors.transparent,
    ),
    side: BorderSide(
      color: CustomColorScheme.lightColorScheme.onSurfaceVariant,
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );

  static RadioThemeData lightRadioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? CustomColorScheme.lightColorScheme.secondary
          : CustomColorScheme.lightColorScheme.onSurfaceVariant,
    ),
  );

  static SwitchThemeData lightSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.white
          : CustomColorScheme.lightColorScheme.onSurfaceVariant,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? CustomColorScheme.lightColorScheme.secondary
          : CustomColorScheme.lightColorScheme.outline,
    ),
    trackOutlineColor: const WidgetStatePropertyAll(
      Colors.transparent,
    ),
  );

  static SliderThemeData lightSliderTheme = SliderThemeData(
    activeTrackColor: CustomColorScheme.lightColorScheme.secondary,
    inactiveTrackColor: CustomColorScheme.lightColorScheme.outline,
    thumbColor: CustomColorScheme.lightColorScheme.secondary,
    overlayColor: AppCustomColorsPalette.light.sliderOverlay,
    valueIndicatorColor: AppCustomColorsPalette.light.valueIndicator,
    valueIndicatorTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  );

  // ==========================================================
  // DARK
  // ==========================================================
  static ChipThemeData darkChipTheme = ChipThemeData(
    backgroundColor: AppCustomColorsPalette.dark.chipBackground,
    disabledColor: CustomColorScheme.darkColorScheme.outline.withValues(
      alpha: 0.3,
    ),
    selectedColor: AppCustomColorsPalette.dark.chipSelected,
    secondarySelectedColor: AppCustomColorsPalette.dark.chipSelected,
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    secondaryLabelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: CustomColorScheme.darkColorScheme.secondary,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    side: BorderSide(
      color: CustomColorScheme.darkColorScheme.outline,
      width: 1,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? CustomColorScheme.darkColorScheme.secondary
          : Colors.transparent,
    ),
    side: BorderSide(
      color: CustomColorScheme.darkColorScheme.onSurfaceVariant,
      width: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );

  static RadioThemeData darkRadioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? CustomColorScheme.darkColorScheme.secondary
          : CustomColorScheme.darkColorScheme.onSurfaceVariant,
    ),
  );

  static SwitchThemeData darkSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.white
          : CustomColorScheme.darkColorScheme.onSurfaceVariant,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? CustomColorScheme.darkColorScheme.secondary
          : CustomColorScheme.darkColorScheme.outline,
    ),
    trackOutlineColor: const WidgetStatePropertyAll(
      Colors.transparent,
    ),
  );

  static SliderThemeData darkSliderTheme = SliderThemeData(
    activeTrackColor: CustomColorScheme.darkColorScheme.secondary,
    inactiveTrackColor: CustomColorScheme.darkColorScheme.outline,
    thumbColor: CustomColorScheme.darkColorScheme.secondary,
    overlayColor: AppCustomColorsPalette.dark.sliderOverlay,
    valueIndicatorColor: AppCustomColorsPalette.dark.valueIndicator,
    valueIndicatorTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  );
}
