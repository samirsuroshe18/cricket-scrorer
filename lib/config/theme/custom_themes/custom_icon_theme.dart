import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:flutter/cupertino.dart';

class CustomIconTheme {
  CustomIconTheme._();

  static IconThemeData lightIconTheme = IconThemeData(
    color: CustomColorScheme.lightColorScheme.onSurface,
    size: 22,
  );

  static IconThemeData darkIconTheme = IconThemeData(
    color: CustomColorScheme.darkColorScheme.onSurface,
    size: 22,
  );
}
