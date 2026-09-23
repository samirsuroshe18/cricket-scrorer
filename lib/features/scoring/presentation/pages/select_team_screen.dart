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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: CricketTextField(
                controller: controller.queryController,
                hintText: TranslationKeys.searchOrAddTeam.tr,
                prefixIcon: const Icon(Icons.search),
                onChanged: controller.onQueryChanged,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
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
            Expanded(
              child: Obx(() {
                final loading = controller.isLoading.value;
                final hasSearched = controller.hasSearched.value;
                final results = controller.results;
                final hasQuery = controller.query.value.trim().isNotEmpty;

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
                            style: context.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: 16.p,
                  children: [
                    if (results.isEmpty && hasQuery)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CricketText(
                          text: TranslationKeys.teamSearchNoMatch.tr,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    for (final team in results) ...[
                      _TeamResultRow(
                        team: team,
                        onTap: () => controller.selectTeam(team),
                      ),
                      8.h,
                    ],
                    if (hasQuery)
                      _UseAsNewTeamRow(
                        query: controller.query.value.trim(),
                        onTap: controller.useAsNewTeam,
                      ),
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

class _TeamResultRow extends StatelessWidget {
  const _TeamResultRow({required this.team, required this.onTap});

  final TeamSummary team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: onTap,
        child: Padding(
          padding: 12.p,
          child: Row(
            children: [
              CricketEntityAvatar(
                name: team.name,
                logoUrl: team.logoUrl,
                size: 36,
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
                    if (team.organization != null)
                      CricketText(
                        text: team.organization!.name,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UseAsNewTeamRow extends StatelessWidget {
  const _UseAsNewTeamRow({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: onTap,
        child: Container(
          padding: 12.p,
          decoration: BoxDecoration(
            borderRadius: 12.radius,
            border: Border.all(color: context.colorScheme.secondary),
          ),
          child: Row(
            children: [
              Icon(Icons.add, color: context.colorScheme.secondary),
              12.w,
              Expanded(
                child: CricketText(
                  text: TranslationKeys.useAsNewTeam.trParams({'name': query}),
                  style: context.textTheme.titleSmall?.copyWith(
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
