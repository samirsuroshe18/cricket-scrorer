import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A team's record and recent form, from `TeamProfileRes.stats`. Renders
/// nothing for a team that has not completed a match — a row of zeros says
/// nothing a new team's empty roster and match list do not already say.
class TeamStatsStrip extends StatelessWidget {
  const TeamStatsStrip({required this.stats, super.key});

  final TeamStatsRes stats;

  /// `58.3%`, but `100%` rather than `100.0%` for a whole number.
  String get _winPercentage {
    final value = stats.winPercentage;
    final text = value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
    return '$text%';
  }

  @override
  Widget build(BuildContext context) {
    if (stats.played == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.chipBackground,
        borderRadius: 12.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A Wrap, not a Row: six cells with long localized labels or a
          // large text scale would otherwise overflow a narrow phone.
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 16,
            runSpacing: 12,
            children: [
              _StatCell(
                value: '${stats.played}',
                label: TranslationKeys.playedShort,
              ),
              _StatCell(value: '${stats.won}', label: TranslationKeys.wonShort),
              _StatCell(
                value: '${stats.lost}',
                label: TranslationKeys.lostShort,
              ),
              if (stats.tied > 0)
                _StatCell(
                  value: '${stats.tied}',
                  label: TranslationKeys.tiedShort,
                ),
              if (stats.noResult > 0)
                _StatCell(
                  value: '${stats.noResult}',
                  label: TranslationKeys.noResultShort,
                ),
              _StatCell(
                value: _winPercentage,
                label: TranslationKeys.winPercentage,
              ),
            ],
          ),
          if (stats.form.isNotEmpty) ...[
            12.h,
            Row(
              children: [
                CricketText(
                  text: TranslationKeys.recentForm.tr,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                8.w,
                for (final code in stats.form) ...[
                  _FormDot(code: code),
                  4.w,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CricketText(
          text: value,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        2.h,
        CricketText(
          text: label.tr,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// One of the last five results. Colour is not the only signal: the dot
/// carries the short letter and a spoken label.
class _FormDot extends StatelessWidget {
  const _FormDot({required this.code});

  final String code;

  (String, String, Color) _outcome(BuildContext context) => switch (code) {
    'W' => (
      TranslationKeys.wonShort,
      TranslationKeys.formWon,
      context.colors.statusSuccess,
    ),
    'L' => (
      TranslationKeys.lostShort,
      TranslationKeys.formLost,
      context.colors.statusDanger,
    ),
    'T' => (
      TranslationKeys.tiedShort,
      TranslationKeys.formTied,
      context.colors.statusWarning,
    ),
    _ => (
      TranslationKeys.noResultShort,
      TranslationKeys.formNoResult,
      context.colorScheme.onSurfaceVariant,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (short, spoken, color) = _outcome(context);
    return Semantics(
      label: spoken.tr,
      excludeSemantics: true,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color),
        ),
        child: CricketText(
          text: short.tr,
          style: context.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
