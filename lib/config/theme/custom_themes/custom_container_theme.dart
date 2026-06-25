import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/material.dart';

class CustomContainerTheme {
  CustomContainerTheme._();

  // ==========================================================
  // LIGHT
  // ==========================================================
  static CardThemeData lightCardTheme = CardThemeData(
    color: CustomColorScheme.lightColorScheme.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: CustomColorScheme.lightColorScheme.outline,
      ),
    ),
  );

  static BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: CustomColorScheme.lightColorScheme.surface,
    elevation: 0,
    showDragHandle: true,
    dragHandleColor: CustomColorScheme.lightColorScheme.outline,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
  );

  static DialogThemeData lightDialogTheme = DialogThemeData(
    backgroundColor: CustomColorScheme.lightColorScheme.surface,
    elevation: 6,
    alignment: Alignment.center,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      color: CustomColorScheme.lightColorScheme.onSurfaceVariant,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  static DividerThemeData lightDividerTheme = DividerThemeData(
    color: CustomColorScheme.lightColorScheme.outline,
    thickness: 1,
    space: 1,
  );

  // ==========================================================
  // DARK
  // ==========================================================
  static CardThemeData darkCardTheme = CardThemeData(
    color: CustomColorScheme.darkColorScheme.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: CustomColorScheme.darkColorScheme.outline,
      ),
    ),
  );

  static BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: CustomColorScheme.darkColorScheme.surface,
    elevation: 0,
    showDragHandle: true,
    dragHandleColor: CustomColorScheme.darkColorScheme.outline,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
  );

  static DialogThemeData darkDialogTheme = DialogThemeData(
    backgroundColor: CustomColorScheme.darkColorScheme.surface,
    elevation: 6,
    alignment: Alignment.center,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      color: CustomColorScheme.darkColorScheme.onSurfaceVariant,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  static DividerThemeData darkDividerTheme = DividerThemeData(
    color: CustomColorScheme.darkColorScheme.outline,
    thickness: 1,
    space: 1,
  );
}
