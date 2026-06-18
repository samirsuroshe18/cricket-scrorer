import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';

class CustomContainerTheme {
  CustomContainerTheme._();

  // --- Light Containers ---
  static CardThemeData lightCardTheme = CardThemeData(
    color: AppColor.lightCard,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColor.lightBorder, width: 1),
    ),
  );

  static const BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColor.lightCard,
    elevation: 0,
    showDragHandle: true,
    dragHandleColor: AppColor.lightBorder,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  );

  static DialogThemeData lightDialogTheme = DialogThemeData(
    backgroundColor: AppColor.lightCard,
    elevation: 6,
    alignment: Alignment.center,
    titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.lightTextPrimary),
    contentTextStyle: const TextStyle(fontSize: 14, color: AppColor.lightTextSecondary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static const DividerThemeData lightDividerTheme = DividerThemeData(
    color: AppColor.lightBorder,
    thickness: 1,
    space: 1,
  );

  // --- Dark Containers ---
  static CardThemeData darkCardTheme = CardThemeData(
    color: AppColor.darkCardBg,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColor.darkBorder, width: 1),
    ),
  );

  static const BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColor.darkCardBg,
    elevation: 0,
    showDragHandle: true,
    dragHandleColor: AppColor.darkBorder,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  );

  static DialogThemeData darkDialogTheme = DialogThemeData(
    backgroundColor: AppColor.darkCardBg,
    elevation: 6,
    alignment: Alignment.center,
    titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.darkTextPrimary),
    contentTextStyle: const TextStyle(fontSize: 14, color: AppColor.darkTextMuted),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static const DividerThemeData darkDividerTheme = DividerThemeData(
    color: AppColor.darkBorder,
    thickness: 1,
    space: 1,
  );
}