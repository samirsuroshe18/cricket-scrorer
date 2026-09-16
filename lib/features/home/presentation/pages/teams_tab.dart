import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_state_placeholders.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organizations_list_screen.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Teams tab: everywhere a team/organization identity lives, in one place —
/// "My Teams" (every team the caller has ever played for or created, ad-hoc
/// or org-owned — `GetMyTeamsUseCase`, wired to a destination for the first
/// time via [MyTeamsController]) above "Organizations" (unchanged logic
/// from the standalone [OrganizationsListScreen], reused here rather than
/// duplicated). Search moves here too: `GET /v1/search` only ever returned
/// organizations and tournaments, so a search icon on Home was always
/// slightly misplaced — it belongs with the things it actually searches.
class TeamsTab extends StatelessWidget {
  const TeamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final myTeams = Get.find<MyTeamsController>();
    final orgs = Get.find<OrganizationsListController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.navTeams.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed<dynamic>(AppRoutes.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateOrganizationSheet(orgs),
        icon: const Icon(Icons.add),
        label: CricketText(text: TranslationKeys.createOrganization.tr),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Future.wait([
            myTeams.loadMyTeams(),
            orgs.loadOrganizations(),
          ]),
          child: ListView(
            padding: 16.p,
            children: [
              DashboardSectionHeader(title: TranslationKeys.myTeams.tr),
              12.h,
              Obx(() {
                if (myTeams.isLoading.value && myTeams.teams.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (myTeams.teams.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CricketText(
                      text: TranslationKeys.myTeamsEmptyHint.tr,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: myTeams.teams.length,
                    separatorBuilder: (_, _) => 10.w,
                    itemBuilder: (context, index) =>
                        _TeamChip(team: myTeams.teams[index]),
                  ),
                );
              }),

              28.h,

              Obx(
                () => DashboardSectionHeader(
                  title: TranslationKeys.organizations.tr,
                  // Full management (leave/delete an organization) stays on
                  // the dedicated screen — this is a capped, read-only
                  // preview, same "See all" pattern as Home's dashboard
                  // sections.
                  onSeeAll: orgs.organizations.length > 3
                      ? () => Get.toNamed<dynamic>(AppRoutes.organizations)
                      : null,
                ),
              ),
              12.h,
              Obx(() {
                if (orgs.isLoading.value && orgs.organizations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final error = orgs.loadError.value;
                if (error != null && orgs.organizations.isEmpty) {
                  return OrganizationMessageState(
                    icon: Icons.error_outline,
                    message: error,
                  );
                }
                if (orgs.organizations.isEmpty) {
                  return OrganizationMessageState(
                    icon: Icons.groups_outlined,
                    message: TranslationKeys.noOrganizationsYet.tr,
                  );
                }
                return Column(
                  children: orgs.organizations
                      .take(3)
                      .map(
                        (org) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrganizationCard(org: org),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  const _TeamChip({required this.team});

  final TeamSummary team;

  String _monogram() {
    final words = team.name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: 12.radius,
      onTap: () => Get.toNamed<dynamic>(AppRoutes.teamProfilePath(team.id)),
      child: Container(
        width: 84,
        padding: 8.p,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: 12.radius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: context.colors.chipBackground,
              child: CricketText(
                text: _monogram(),
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            6.h,
            CricketText(
              text: team.shortName ?? team.name,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
