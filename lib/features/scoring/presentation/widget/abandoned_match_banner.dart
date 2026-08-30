import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The [MatchResultInfo]-less counterpart to `MatchResultBanner` — an
/// abandoned match has no winner, so this never reads a result the server
/// never sent. Neutral/grey rather than the win banner's green, on purpose:
/// nothing was decided here.
class AbandonedMatchBanner extends StatelessWidget {
  const AbandonedMatchBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CricketText(
        text: TranslationKeys.statusAbandoned.tr,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
