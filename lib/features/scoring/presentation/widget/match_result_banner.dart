import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Composed client-side from [MatchResultInfo.winner]/`marginType`/`margin` —
/// the server sends no description sentence on purpose, see docs/api.md's
/// note on why. `winner`/`marginType` are the only server-decided facts here;
/// everything else is display.
///
/// Shared between the scorer's own result screen and the spectator screen so
/// the two can never word the same match differently — [nameFor] is the only
/// thing that varies: the scorer's screen resolves side labels off
/// `ScorecardRes`, the spectator's off `PublicMatchInfo`, and neither carries
/// the other's shape.
class MatchResultBanner extends StatelessWidget {
  const MatchResultBanner({super.key, required this.result, required this.nameFor});

  final MatchResultInfo result;
  final String Function(String sideLabel) nameFor;

  @override
  Widget build(BuildContext context) {
    final text = result.isTie
        ? TranslationKeys.matchTied.tr
        : '${nameFor(result.winner)} ${TranslationKeys.wonBy.tr} '
              '${result.margin} '
              '${result.marginType == 'wickets' ? TranslationKeys.wickets.tr.toLowerCase() : TranslationKeys.runsWord.tr}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.statusSuccess.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CricketText(
        text: text,
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colors.statusSuccess,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
