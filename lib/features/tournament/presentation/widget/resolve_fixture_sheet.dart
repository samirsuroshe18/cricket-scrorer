import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Manually resolving an `unresolved` fixture (tie/no-result/abandoned) —
/// exactly two candidates, so this mirrors `showEnrollTeamSheet`'s
/// tap-a-name shape rather than needing a full picker.
Future<void> showResolveFixtureSheet({
  required TournamentDetailController controller,
  required FixtureRes fixture,
}) async {
  final teamB = fixture.teamB;
  if (teamB == null) return; // A bye fixture is never 'unresolved'.

  final resolved = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.declareWinner.tr,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CandidateRow(
            name: fixture.teamA.name,
            shortName: fixture.teamA.shortName,
            onTap: () async {
              final errorMessage = await controller.resolveFixture(
                fixture.id,
                fixture.teamA.id,
              );
              if (errorMessage == null) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(errorMessage);
              }
            },
          ),
          _CandidateRow(
            name: teamB.name,
            shortName: teamB.shortName,
            onTap: () async {
              final errorMessage = await controller.resolveFixture(
                fixture.id,
                teamB.id,
              );
              if (errorMessage == null) {
                Get.back<bool>(result: true);
              } else {
                CricketSnackbar.showErrorMessage(errorMessage);
              }
            },
          ),
        ],
      ),
    ),
  );

  if (resolved == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.fixtureResolved.tr);
  }
}

// A monogram avatar, not a trophy — this app's own "pick a name" sheets
// (assign_scorer_sheet, enroll_team_sheet) already lead with initials, and
// an identical trophy icon on both rows here didn't distinguish the two
// choices any better than the sheet's own "Declare winner" headline
// already does.
class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.name, this.shortName, required this.onTap});

  final String name;
  final String? shortName;
  final VoidCallback onTap;

  /// Same derivation as `enroll_team_sheet.dart`'s `_EligibleTeamRow`, so a
  /// team reads identically wherever this app asks "pick a team."
  String _monogram() {
    final short = shortName?.trim();
    if (short != null && short.isNotEmpty) {
      return short.substring(0, short.length.clamp(0, 3)).toUpperCase();
    }
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.chipBackground,
                child: CricketText(
                  text: _monogram(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              12.w,
              Expanded(
                child: CricketText(
                  text: name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
