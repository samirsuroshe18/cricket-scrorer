import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension SpaceExtension on num {
  /// Fixed Height
  SizedBox get h => SizedBox(
    height: toDouble(),
  );

  /// Fixed Width
  SizedBox get w => SizedBox(
    width: toDouble(),
  );

  /// Responsive Height (% of screen height)
  SizedBox get rh => SizedBox(
    height: Get.height * (toDouble() / 100),
  );

  /// Responsive Width (% of screen width)
  SizedBox get rw => SizedBox(
    width: Get.width * (toDouble() / 100),
  );

  /// Vertical Padding
  EdgeInsets get pv => EdgeInsets.symmetric(
    vertical: toDouble(),
  );

  /// Horizontal Padding
  EdgeInsets get ph => EdgeInsets.symmetric(
    horizontal: toDouble(),
  );

  /// All Side Padding
  EdgeInsets get p => EdgeInsets.all(
    toDouble(),
  );

  /// Circular Radius
  BorderRadius get radius => BorderRadius.circular(
    toDouble(),
  );
}
