import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// `scheduled` reuses no existing label (fixtures are the only thing with
/// this exact status); `completed` reuses the same English word every other
/// completed-thing label in this app already uses
/// (`TranslationKeys.statusCompleted`) rather than a redundant fixture-only
/// key for an identical string.
String fixtureStatusLabel(String status) => switch (status) {
  'scheduled' => TranslationKeys.fixtureStatusScheduled.tr,
  'bye' => TranslationKeys.byeLabel.tr,
  'completed' => TranslationKeys.statusCompleted.tr,
  'unresolved' => TranslationKeys.fixtureStatusUnresolved.tr,
  _ => status,
};

/// `unresolved` draws on `statusDanger` — the one fixture state that needs
/// the owner's attention (a tie, no-result, or abandonment nothing else in
/// this app resolves automatically). `bye` gets no color of its own; it's
/// informational, not a state anyone acts on.
Color fixtureStatusColor(BuildContext context, String status) =>
    switch (status) {
      'scheduled' => context.colors.statusInfo,
      'completed' => context.colors.statusSuccess,
      'unresolved' => context.colors.statusDanger,
      _ => context.colorScheme.onSurfaceVariant,
    };
