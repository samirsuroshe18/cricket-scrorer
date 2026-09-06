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

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
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
