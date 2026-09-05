import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Tap-a-name team enrollment — mirrors `showAssignScorerSheet`'s pattern
/// exactly: list the eligible candidates, tapping one acts immediately and
/// closes the sheet.
Future<void> showEnrollTeamSheet({
  required TournamentDetailController controller,
}) async {
  final eligible = controller.eligibleTeams;
  if (eligible.isEmpty) {
    CricketSnackbar.showErrorMessage(TranslationKeys.noEligibleTeams.tr);
    return;
  }

  final enrolled = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.enrollTeam.tr,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final team in eligible)
            _EligibleTeamRow(
              team: team,
              onTap: () async {
                final success = await controller.enrollTeam(team.id);
                if (success) Get.back<bool>(result: true);
              },
            ),
        ],
      ),
    ),
  );

  if (enrolled == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.teamEnrolled.tr);
  }
}

class _EligibleTeamRow extends StatelessWidget {
  const _EligibleTeamRow({required this.team, required this.onTap});

  final OrganizationTeamRef team;
  final VoidCallback onTap;

  /// `shortName` if the team has one, else initials of `name` — the same
  /// derivation `TeamProfileScreen`'s own `_TeamHeader._monogram()` uses,
  /// so a team reads the same way here as it does on its own profile.
  String _monogram() {
    final short = team.shortName?.trim();
    if (short != null && short.isNotEmpty) {
      return short.substring(0, short.length.clamp(0, 3)).toUpperCase();
    }
    final words = team.name.trim().split(RegExp(r'\s+'));
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
                  text: team.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              if (team.shortName != null)
                CricketText(
                  text: team.shortName!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
