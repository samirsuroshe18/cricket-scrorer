import 'package:cricket_scorer/config/theme/custom_themes/custom_app_bar_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_button_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_color_scheme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_container_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_icon_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_input_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_navigation_progress_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_selection_theme.dart';
import 'package:cricket_scorer/config/theme/custom_themes/custom_text_theme.dart';
import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ===========================================================================
  // LIGHT THEME CONFIGURATION
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColor.lightBackground,
      canvasColor: AppColor.lightBackground,
      cardColor: AppColor.lightCard,
      dividerColor: AppColor.lightBorder,
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
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.darkPageBg,
      canvasColor: AppColor.darkPageBg,
      cardColor: AppColor.darkCardBg,
      dividerColor: AppColor.darkBorder,
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
