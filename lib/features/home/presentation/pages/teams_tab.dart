import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_grouped_card.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_empty_card.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_list_skeleton.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_section_header.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/team_row.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organizations_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Teams tab: everywhere a team/organization identity lives, in one place —
/// "My teams" (every team the caller has ever played for or created, ad-hoc
/// or org-owned — `GetMyTeamsUseCase`, wired to a destination for the first
/// time via [MyTeamsController]) above "Organizations" (unchanged logic
/// from the standalone [OrganizationsListScreen], reused here rather than
/// duplicated). Search sits in the header: `GET /v1/search` only ever
/// returned organizations and tournaments, so it belongs with the things it
/// actually searches.
///
/// Each section is one grouped list. "My teams" shows the first few teams and
/// expands in place; "Organizations" is a capped preview whose "See all" opens
/// the full screen. Creating an organization is the "+" in its header rather
/// than a floating button, so the docked "Start Match" stays the only primary
/// action on screen.
class TeamsTab extends StatefulWidget {
  const TeamsTab({super.key});

  @override
  State<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab> {
  /// Teams shown before "See all" expands the list in place.
  static const _collapsedTeamCount = 4;

  /// Organizations shown before "See all" opens the full screen.
  static const _organizationPreviewCount = 3;

  late final MyTeamsController myTeams = Get.find<MyTeamsController>();
  late final OrganizationsListController orgs =
      Get.find<OrganizationsListController>();

  bool _showAllTeams = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: CricketText(
                        text: TranslationKeys.navTeams.tr,
                        style: context.homeText(22, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: TranslationKeys.search.tr,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onPressed: () => Get.toNamed<dynamic>(AppRoutes.search),
                    icon: Icon(
                      Icons.search_rounded,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.wait([
                  myTeams.loadMyTeams(),
                  orgs.loadOrganizations(),
                ]),
                child: ListView(
                  // Always scrollable, so pull-to-refresh also works while
                  // an empty or failed section leaves the list short.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 44),
                  children: [
                    _buildMyTeams(context),
                    20.h,
                    _buildOrganizations(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTeams(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final total = myTeams.teams.length;
          return HomeSectionHeader(
            title: TranslationKeys.myTeams.tr,
            count: total == 0 ? null : total,
            onSeeAll: !_showAllTeams && total > _collapsedTeamCount
                ? () => setState(() => _showAllTeams = true)
                : null,
          );
        }),
        4.h,
        Obx(() {
          final teams = myTeams.teams;
          if (myTeams.isLoading.value && teams.isEmpty) {
            return const HomeListSkeleton();
          }

          final failed = myTeams.loadError.value != null;
          final visible = _showAllTeams
              ? teams.toList()
              : teams.take(_collapsedTeamCount).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failed) ...[
                _refreshFailedStrip(myTeams.loadMyTeams),
                if (teams.isNotEmpty) 12.h,
              ],
              if (teams.isNotEmpty)
                CricketGroupedCard(
                  children: [for (final team in visible) TeamRow(team: team)],
                )
              else if (!failed)
                HomeEmptyCard(
                  icon: Icons.groups_outlined,
                  message: TranslationKeys.myTeamsEmptyHint.tr,
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildOrganizations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => HomeSectionHeader(
            title: TranslationKeys.organizations.tr,
            // Full management (leave/delete an organization) stays on the
            // dedicated screen — this is a capped, read-only preview.
            onSeeAll: orgs.organizations.length > _organizationPreviewCount
                ? () => Get.toNamed<dynamic>(AppRoutes.organizations)
                : null,
            trailing: IconButton(
              tooltip: TranslationKeys.createOrganization.tr,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => showCreateOrganizationSheet(orgs),
              icon: Icon(
                Icons.add_rounded,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        4.h,
        Obx(() {
          final organizations = orgs.organizations;
          if (orgs.isLoading.value && organizations.isEmpty) {
            return const HomeListSkeleton(rows: 2);
          }

          final failed = orgs.loadError.value != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failed) ...[
                _refreshFailedStrip(orgs.loadOrganizations),
                if (organizations.isNotEmpty) 12.h,
              ],
              if (organizations.isNotEmpty)
                CricketGroupedCard(
                  children: [
                    for (final org in organizations.take(
                      _organizationPreviewCount,
                    ))
                      OrganizationRow(org: org),
                  ],
                )
              else if (!failed)
                HomeEmptyCard(
                  icon: Icons.groups_outlined,
                  message: TranslationKeys.noOrganizationsYet.tr,
                  action: CricketButton(
                    buttonText: TranslationKeys.createOrganization.tr,
                    onPressed: () => showCreateOrganizationSheet(orgs),
                    width: 220,
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _refreshFailedStrip(Future<void> Function() reload) {
    return HomeStatusStrip(
      tone: HomeStripTone.neutral,
      icon: Icons.refresh_rounded,
      message: TranslationKeys.homeRefreshFailed.tr,
      actionLabel: TranslationKeys.retry.tr,
      onTap: () => unawaited(reload()),
    );
  }
}
