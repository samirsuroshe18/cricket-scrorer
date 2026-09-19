import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Matches / Runs / Wickets for the signed-in user, shown under Home's
/// greeting. Pure presentation: the caller decides whether to show it at all
/// (hidden when the user has no linked Player).
class HomeStatChips extends StatelessWidget {
  const HomeStatChips({required this.stats, super.key});

  final MyCareerStatsRes stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            value: stats.matchesPlayed,
            label: TranslationKeys.statMatches.tr,
          ),
        ),
        10.w,
        Expanded(
          child: _StatChip(
            value: stats.runs,
            label: TranslationKeys.statRuns.tr,
          ),
        ),
        10.w,
        Expanded(
          child: _StatChip(
            value: stats.wickets,
            label: TranslationKeys.statWickets.tr,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: 12.radius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CricketText(
            text: '$value',
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
          2.h,
          CricketText(
            text: label,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
