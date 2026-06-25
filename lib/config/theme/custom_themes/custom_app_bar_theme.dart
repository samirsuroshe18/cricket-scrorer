import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBarTheme {
  CustomAppBarTheme._();

  static AppBarTheme lightAppBarTheme = AppBarTheme(
    backgroundColor: CustomColorScheme.lightColorScheme.surfaceContainerLowest,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(
      color: CustomColorScheme.lightColorScheme.onSurface,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: CustomColorScheme.lightColorScheme.onSurface,
      size: 24,
    ),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.lightColorScheme.onSurface,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  static AppBarTheme darkAppBarTheme = AppBarTheme(
    backgroundColor: CustomColorScheme.darkColorScheme.surfaceContainerLowest,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(
      color: CustomColorScheme.darkColorScheme.onSurface,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: CustomColorScheme.darkColorScheme.onSurface,
      size: 24,
    ),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: CustomColorScheme.darkColorScheme.onSurface,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
}
