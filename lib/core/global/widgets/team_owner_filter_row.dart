import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/team_owner_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "Your teams" / "Opponent" — narrows a team search to teams the scorer
/// created directly, or teams visible only through an organization they
/// belong to (a teammate's team). Deselecting the active chip clears the
/// filter back to "both". Shared by the create-match Teams banner's own
/// picker screen — filtering only makes sense while actually browsing.
class TeamOwnerFilterRow extends StatelessWidget {
  const TeamOwnerFilterRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Rxn<TeamOwnerFilter> selected;
  final ValueChanged<TeamOwnerFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: CricketText(text: TranslationKeys.filterYourTeams.tr),
            selected: selected.value == TeamOwnerFilter.mine,
            onSelected: (_) => onSelected(TeamOwnerFilter.mine),
          ),
          FilterChip(
            label: CricketText(text: TranslationKeys.filterOpponent.tr),
            selected: selected.value == TeamOwnerFilter.others,
            onSelected: (_) => onSelected(TeamOwnerFilter.others),
          ),
        ],
      ),
    );
  }
}
