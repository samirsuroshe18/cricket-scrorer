import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBarTheme {
  CustomAppBarTheme._();

  static AppBarTheme lightAppBarTheme = const AppBarTheme(
    backgroundColor: AppColor.lightBackground,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColor.lightTextPrimary, size: 24),
    actionsIconTheme: IconThemeData(color: AppColor.lightTextPrimary, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColor.lightTextPrimary,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  static AppBarTheme darkAppBarTheme = const AppBarTheme(
    backgroundColor: AppColor.darkPageBg,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColor.darkTextPrimary, size: 24),
    actionsIconTheme: IconThemeData(color: AppColor.darkTextPrimary, size: 24),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColor.darkTextPrimary,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
}
