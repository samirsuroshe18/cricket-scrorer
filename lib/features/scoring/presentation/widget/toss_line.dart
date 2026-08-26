import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "Team A won the toss, elected to bat" — or nothing at all when the toss
/// was skipped, which is the common case for a quick match. Shared between
/// the scorer's console and the spectator screen so the sentence can never
/// be worded differently in one than the other.
class TossLine extends StatelessWidget {
  const TossLine({
    super.key,
    required this.tossWinner,
    required this.tossDecision,
    required this.nameFor,
  });

  /// `teamA` / `teamB`, or null when the toss was skipped.
  final String? tossWinner;

  /// `bat` / `bowl`. Null exactly when [tossWinner] is null.
  final String? tossDecision;

  final String Function(String sideLabel) nameFor;

  @override
  Widget build(BuildContext context) {
    final winner = tossWinner;
    final decision = tossDecision;
    if (winner == null || decision == null) return const SizedBox.shrink();

    final decisionLabel = decision == 'bat'
        ? TranslationKeys.bat.tr
        : TranslationKeys.bowl.tr;

    return CricketText(
      text:
          '${nameFor(winner)} ${TranslationKeys.wonTheToss.tr}, '
          '${TranslationKeys.electedTo.tr} ${decisionLabel.toLowerCase()}',
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}
