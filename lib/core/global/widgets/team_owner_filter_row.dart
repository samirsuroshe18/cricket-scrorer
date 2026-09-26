import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/team_owner_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "All" / "Your teams" / "Opponent" — narrows a team search to teams the
/// scorer created directly, or teams visible only through an organization
/// they belong to (a teammate's team). "All" is the no-filter state; picking
/// it clears whichever filter is active, the same as tapping the active
/// segment used to. Shared by the create-match Teams banner's own picker
/// screen — filtering only makes sense while actually browsing.
class TeamOwnerFilterRow extends StatelessWidget {
  const TeamOwnerFilterRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Rxn<TeamOwnerFilter> selected;
  final ValueChanged<TeamOwnerFilter> onSelected;

  void _onChanged(TeamOwnerFilter? next) {
    final current = selected.value;
    if (next == current) return;
    // The controller toggles: re-selecting the active filter clears it.
    onSelected(next ?? current!);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: SegmentedButton<TeamOwnerFilter?>(
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: 12.radius),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? context.colors.chipSelected
                  : Colors.transparent,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? scheme.onSurface
                  : scheme.onSurfaceVariant,
            ),
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.selected)
                    ? scheme.secondary
                    : scheme.outlineVariant,
                width: states.contains(WidgetState.selected) ? 2 : 1,
              ),
            ),
            textStyle: WidgetStateProperty.resolveWith(
              (states) => context.textTheme.labelLarge?.copyWith(
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
          segments: [
            ButtonSegment(
              value: null,
              label: CricketText(text: TranslationKeys.filterAll.tr),
            ),
            ButtonSegment(
              value: TeamOwnerFilter.mine,
              label: CricketText(text: TranslationKeys.filterYourTeams.tr),
            ),
            ButtonSegment(
              value: TeamOwnerFilter.others,
              label: CricketText(text: TranslationKeys.filterOpponent.tr),
            ),
          ],
          selected: {selected.value},
          onSelectionChanged: (set) => _onChanged(set.first),
        ),
      ),
    );
  }
}
