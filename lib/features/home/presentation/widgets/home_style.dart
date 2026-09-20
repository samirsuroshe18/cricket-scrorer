import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The Home dashboard's small visual vocabulary, resolved from the app theme
/// so light and dark both come out right without a second set of hex values.
/// Kept out of the theme files on purpose: nothing outside Home draws these
/// combinations, and a token nobody else reads is just noise in the palette.
extension HomeStyle on BuildContext {
  /// Raised surface — cards, pills, stat tiles.
  Color get homeCard => colorScheme.surface;

  /// The hairline around a card.
  Color get homeLine => colorScheme.outline;

  Color get homeMuted => colorScheme.onSurfaceVariant;

  /// Red for text and icons that sit on a dark card: the brand red itself is
  /// too dim there, so dark mode uses the lighter tint.
  Color get homeLiveText => isDark ? AppColor.softRed : colorScheme.primary;

  /// Body text at an exact size, so the dashboard can match its spec rather
  /// than snap to the nearest text-theme slot. Derives from the theme's body
  /// style so the family and locale-aware fallbacks come along.
  TextStyle homeText(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    bool tabular = false,
  }) {
    return (textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: size,
      fontWeight: weight,
      color: color ?? colorScheme.onSurface,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  /// A card's fill and outline. Dark mode gets the quiet borderless tile the
  /// design calls for; light mode needs the hairline to lift white off the
  /// off-white page.
  BoxDecoration homeCardDecoration({
    double radius = 12,
    bool alwaysBordered = false,
  }) {
    return BoxDecoration(
      color: homeCard,
      borderRadius: BorderRadius.circular(radius),
      border: (alwaysBordered || !isDark) ? Border.all(color: homeLine) : null,
    );
  }
}
