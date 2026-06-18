import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';

class CustomIconTheme {
  CustomIconTheme._();

  static IconThemeData lightIconTheme = const IconThemeData(
    color: AppColor.lightTextPrimary,
    size: 22,
  );

  static IconThemeData darkIconTheme = const IconThemeData(
    color: AppColor.darkTextPrimary,
    size: 22,
  );
}
