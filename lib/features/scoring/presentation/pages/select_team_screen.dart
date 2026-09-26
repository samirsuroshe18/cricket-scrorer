import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_entity_avatar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/team_owner_filter_row.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/select_team_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reached by tapping either half of the create-match Teams banner — a
/// full-screen search + filter + pick, replacing what used to be an inline
/// autocomplete dropdown so there's real room to browse. Pops back with
/// either a [TeamSummary] (an existing team was picked) or a [String] (the
/// typed name, to be created fresh) — see [SelectTeamController] for the
/// exact `Get.back(result: ...)` contract.
class SelectTeamScreen extends GetView<SelectTeamController> {
  const SelectTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: controller.title),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: CricketTextField(
                controller: controller.queryController,
                // A label, not a hint: the field's decoration always carries
                // a (floating) label, and Material hides a hint while an
                // unfocused field has one — which left the field blank.
                labelText: TranslationKeys.searchOrAddTeam.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(
                  () => controller.query.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: TranslationKeys.clearSearch.tr,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            controller.queryController.clear();
                            controller.onQueryChanged('');
                          },
                        ),
                ),
                onChanged: controller.onQueryChanged,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                hideCounter: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TeamOwnerFilterRow(
                  selected: controller.owner,
                  onSelected: controller.setOwnerFilter,
                ),
              ),
            ),
            8.h,
            // Reserves its height so the list doesn't jump when a refetch
            // starts; only the first load uses the full-screen spinner below.
            SizedBox(
              height: 2,
              child: Obx(
                () => controller.isLoading.value && controller.hasSearched.value
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: Obx(() {
                final loading = controller.isLoading.value;
                final hasSearched = controller.hasSearched.value;
                final results = controller.results;
                final query = controller.query.value.trim();
                final hasQuery = query.isNotEmpty;

                if (loading && !hasSearched) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (results.isEmpty && !hasQuery) {
                  return Center(
                    child: Padding(
                      padding: 24.p,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_cricket_outlined,
                            size: 56,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          16.h,
                          CricketText(
                            text: TranslationKeys.searchOrAddTeam.tr,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    if (hasQuery && !controller.queryIsOtherSide) ...[
                      _UseAsNewTeamRow(
                        query: query,
                        onTap: controller.useAsNewTeam,
                      ),
                      12.h,
                    ],
                    if (results.isEmpty)
                      CricketText(
                        text: TranslationKeys.teamSearchNoMatch.tr,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      )
                    else ...[
                      _SectionLabel(
                        text: hasQuery
                            ? '${TranslationKeys.matchingTeams.tr} · '
                                  '${results.length}'
                            : TranslationKeys.recentTeams.tr,
                      ),
                      for (final team in results)
                        _TeamResultRow(
                          team: team,
                          unavailable: controller.isOtherSide(team),
                          onTap: () => controller.selectTeam(team),
                        ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Semantics(
        header: true,
        child: CricketText(
          text: text,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TeamResultRow extends StatelessWidget {
  const _TeamResultRow({
    required this.team,
    required this.onTap,
    this.unavailable = false,
  });

  final TeamSummary team;
  final VoidCallback onTap;

  /// Already chosen for the other side: shown but not tappable, with the
  /// reason where the organization would be.
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final org = team.organization;
    final row = InkWell(
      onTap: unavailable ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            CricketEntityAvatar(
              name: team.name,
              logoUrl: team.logoUrl,
              size: 40,
            ),
            12.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CricketText(
                    text: team.name,
                    style: context.textTheme.titleSmall,
                  ),
                  if (unavailable)
                    CricketText(
                      text: TranslationKeys.teamAlreadyPicked.tr,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else if (org != null)
                    CricketText(
                      text: org.name,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return unavailable ? Opacity(opacity: 0.5, child: row) : row;
  }
}

class _UseAsNewTeamRow extends StatelessWidget {
  const _UseAsNewTeamRow({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Blue outline and icon carry the "action" cue; the label stays in
    // onSurface because the light theme's secondary blue is 4.3:1 on white,
    // just under the 4.5:1 normal-text bar.
    return Material(
      color: Colors.transparent,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: 12.radius,
            border: Border.all(color: context.colorScheme.secondary),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: context.colorScheme.secondary,
              ),
              12.w,
              Expanded(
                child: CricketText(
                  text: TranslationKeys.useAsNewTeam.trParams({'name': query}),
                  style: context.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
