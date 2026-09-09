import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// `sold`/`unsold` — the two resolved `AuctionLot` outcomes shared by the
/// squad view (unsold section) and the history list (per-entry outcome).
String auctionOutcomeLabel(String outcome) => switch (outcome) {
  'sold' => TranslationKeys.sold.tr,
  'unsold' => TranslationKeys.unsold.tr,
  _ => outcome,
};

/// `unsold` is a neutral outcome, not an error, so it draws on
/// `onSurfaceVariant` rather than `statusDanger` — nobody failed anything;
/// the player simply had no bid.
Color auctionOutcomeColor(BuildContext context, String outcome) =>
    switch (outcome) {
      'sold' => context.colors.statusSuccess,
      _ => context.colorScheme.onSurfaceVariant,
    };
