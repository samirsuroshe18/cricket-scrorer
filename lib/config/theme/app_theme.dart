import 'package:cricket_scorer/config/theme/custom_themes/custom_app_bar_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_button_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_container_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_icon_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_input_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_navigation_progress_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_selection_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_text_theme.dart';
import 'package:cricket_scorer/config/theme/palettes/app_custom_colors_palette.dart';
import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ===========================================================================
  // LIGHT THEME CONFIGURATION
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      extensions: const [
        AppCustomColorsPalette.light,
      ],
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor:
          CustomColorScheme.lightColorScheme.surfaceContainerLowest,
      canvasColor: CustomColorScheme.lightColorScheme.surfaceContainerLowest,
      cardColor: CustomColorScheme.lightColorScheme.surface,
      dividerColor: CustomColorScheme.lightColorScheme.outline,
      colorScheme: CustomColorScheme.lightColorScheme,
      appBarTheme: CustomAppBarTheme.lightAppBarTheme,
      textTheme: CustomTextTheme.lightTextTheme,
      primaryTextTheme: CustomTextTheme.lightTextTheme,
      elevatedButtonTheme: CustomButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: CustomButtonTheme.lightOutlinedButtonTheme,
      textButtonTheme: CustomButtonTheme.lightTextButtonTheme,
      iconButtonTheme: CustomButtonTheme.lightIconButtonTheme,
      inputDecorationTheme: CustomInputTheme.lightInputDecorationTheme,
      cardTheme: CustomContainerTheme.lightCardTheme,
      bottomSheetTheme: CustomContainerTheme.lightBottomSheetTheme,
      dialogTheme: CustomContainerTheme.lightDialogTheme,
      dividerTheme: CustomContainerTheme.lightDividerTheme,
      chipTheme: CustomSelectionTheme.lightChipTheme,
      checkboxTheme: CustomSelectionTheme.lightCheckboxTheme,
      radioTheme: CustomSelectionTheme.lightRadioTheme,
      switchTheme: CustomSelectionTheme.lightSwitchTheme,
      sliderTheme: CustomSelectionTheme.lightSliderTheme,
      bottomNavigationBarTheme:
          CustomNavigationProgressTheme.lightBottomNavigationBarTheme,
      progressIndicatorTheme:
          CustomNavigationProgressTheme.lightProgressIndicatorTheme,
      iconTheme: CustomIconTheme.lightIconTheme,
    );
  }

  // ===========================================================================
  // DARK THEME CONFIGURATION
  // ===========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      extensions: const [
        AppCustomColorsPalette.dark,
      ],
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor:
          CustomColorScheme.darkColorScheme.surfaceContainerLowest,
      canvasColor: CustomColorScheme.darkColorScheme.surfaceContainerLowest,
      cardColor: CustomColorScheme.darkColorScheme.surface,
      dividerColor: CustomColorScheme.darkColorScheme.outline,
      colorScheme: CustomColorScheme.darkColorScheme,
      appBarTheme: CustomAppBarTheme.darkAppBarTheme,
      textTheme: CustomTextTheme.darkTextTheme,
      primaryTextTheme: CustomTextTheme.darkTextTheme,
      elevatedButtonTheme: CustomButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: CustomButtonTheme.darkOutlinedButtonTheme,
      textButtonTheme: CustomButtonTheme.darkTextButtonTheme,
      iconButtonTheme: CustomButtonTheme.darkIconButtonTheme,
      inputDecorationTheme: CustomInputTheme.darkInputDecorationTheme,
      cardTheme: CustomContainerTheme.darkCardTheme,
      bottomSheetTheme: CustomContainerTheme.darkBottomSheetTheme,
      dialogTheme: CustomContainerTheme.darkDialogTheme,
      dividerTheme: CustomContainerTheme.darkDividerTheme,
      chipTheme: CustomSelectionTheme.darkChipTheme,
      checkboxTheme: CustomSelectionTheme.darkCheckboxTheme,
      radioTheme: CustomSelectionTheme.darkRadioTheme,
      switchTheme: CustomSelectionTheme.darkSwitchTheme,
      sliderTheme: CustomSelectionTheme.darkSliderTheme,
      bottomNavigationBarTheme:
          CustomNavigationProgressTheme.darkBottomNavigationBarTheme,
      progressIndicatorTheme:
          CustomNavigationProgressTheme.darkProgressIndicatorTheme,
      iconTheme: CustomIconTheme.darkIconTheme,
    );
  }
}
