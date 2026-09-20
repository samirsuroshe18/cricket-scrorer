import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Matches / Runs / Wickets for the signed-in user — the "Your season"
/// strip on Home. Pure presentation: the caller decides whether to show it at all
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
        8.w,
        Expanded(
          child: _StatChip(
            value: stats.runs,
            label: TranslationKeys.statRuns.tr,
          ),
        ),
        8.w,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: context.homeCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CricketText(
            text: '$value',
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            style: context.homeText(
              20,
              weight: FontWeight.w600,
              tabular: true,
            ),
          ),
          CricketText(
            text: label,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            style: context.homeText(11, color: context.homeMuted),
          ),
        ],
      ),
    );
  }
}
