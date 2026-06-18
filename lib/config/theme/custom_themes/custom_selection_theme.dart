import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomSelectionTheme {
  CustomSelectionTheme._();

  // --- Light Selectors ---
  static ChipThemeData lightChipTheme = ChipThemeData(
    backgroundColor: AppColor.lightBackground,
    disabledColor: AppColor.lightBorder.withValues(alpha: 0.5),
    selectedColor: AppColor.lightBlueLight,
    secondarySelectedColor: AppColor.lightBlueLight,
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.lightTextPrimary),
    secondaryLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.lightTeamBlue),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    side: const BorderSide(color: AppColor.lightBorder, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColor.lightTeamBlue : Colors.transparent),
    side: const BorderSide(color: AppColor.lightTextSecondary, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  static RadioThemeData lightRadioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColor.lightTeamBlue : AppColor.lightTextSecondary),
  );

  static SwitchThemeData lightSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : AppColor.lightTextSecondary),
    trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColor.lightTeamBlue : AppColor.lightBorder),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );

  static const SliderThemeData lightSliderTheme = SliderThemeData(
    activeTrackColor: AppColor.lightTeamBlue,
    inactiveTrackColor: AppColor.lightBorder,
    thumbColor: AppColor.lightTeamBlue,
    overlayColor: AppColor.lightBlueOverlay,
    valueIndicatorColor: AppColor.navy,
    valueIndicatorTextStyle: TextStyle(color: Colors.white, fontSize: 12),
  );

  // --- Dark Selectors ---
  static ChipThemeData darkChipTheme = ChipThemeData(
    backgroundColor: AppColor.darkChipBg,
    disabledColor: AppColor.darkBorder.withValues(alpha: 0.3),
    selectedColor: AppColor.darkBlueTint,
    secondarySelectedColor: AppColor.darkBlueTint,
    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.darkTextPrimary),
    secondaryLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.darkBlue),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    side: const BorderSide(color: AppColor.darkBorder, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColor.darkBlue : Colors.transparent),
    side: const BorderSide(color: AppColor.darkTextMuted, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  static RadioThemeData darkRadioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColor.darkBlue : AppColor.darkTextMuted),
  );

  static SwitchThemeData darkSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : AppColor.darkTextMuted),
    trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColor.darkBlue : AppColor.darkBorder),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );

  static const SliderThemeData darkSliderTheme = SliderThemeData(
    activeTrackColor: AppColor.darkBlue,
    inactiveTrackColor: AppColor.darkBorder,
    thumbColor: AppColor.darkBlue,
    overlayColor: AppColor.darkBlueOverlay,
    valueIndicatorColor: AppColor.darkNavyMid,
    valueIndicatorTextStyle: TextStyle(color: Colors.white, fontSize: 12),
  );
}