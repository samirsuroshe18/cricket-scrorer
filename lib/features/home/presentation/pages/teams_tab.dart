import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_grouped_card.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/create_team_sheet.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_empty_card.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_list_skeleton.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_search_empty_state.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_search_field.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_section_header.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/team_row.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organizations_list_screen.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Teams tab: everywhere a team/organization identity lives, in one place —
/// "My teams" (every team the caller has ever played for or created, ad-hoc
/// or org-owned — `GetMyTeamsUseCase`, wired to a destination for the first
/// time via [MyTeamsController]) above "Organizations" (unchanged logic
/// from the standalone [OrganizationsListScreen], reused here rather than
/// duplicated).
///
/// Each section is one grouped list. "My teams" shows the first few teams and
/// expands in place; "Organizations" is a capped preview whose "See all" opens
/// the full screen. Creating an organization is the "+" in its header rather
/// than a floating button, so the docked "Start Match" stays the only primary
/// action on screen.
///
/// The search icon turns the title into a search field that filters both
/// sections in place — by team or organization name for teams, by name for
/// organizations. It filters what is already loaded, so it is instant and
/// works offline; finding an organization or tournament the caller does not
/// belong to is the separate search screen, reached from Home.
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

  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode();

  bool _searching = false;
  bool _showAllTeams = false;

  /// What the lists are filtered by: lower-cased and trimmed, empty when no
  /// search is active. Closing the field clears it. Switching to another tab
  /// does not (the shell keeps this tab alive), so what was typed is still
  /// there on return.
  String get _query => _text.text.trim().toLowerCase();
  bool get _isFiltering => _query.isNotEmpty;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _open() => setState(() => _searching = true);

  void _close() {
    _text.clear();
    _focus.unfocus();
    setState(() => _searching = false);
  }

  void _clear() {
    _text.clear();
    _focus.requestFocus();
    setState(() {});
  }

  bool _teamMatches(TeamSummary team) =>
      team.name.toLowerCase().contains(_query) ||
      (team.organization?.name.toLowerCase().contains(_query) ?? false);

  bool _organizationMatches(OrganizationSummaryRes org) =>
      org.name.toLowerCase().contains(_query);

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
              child: _searching
                  ? HomeSearchField(
                      controller: _text,
                      focusNode: _focus,
                      hintText: TranslationKeys.searchTeamsHint.tr,
                      onChanged: (_) => setState(() {}),
                      onClear: _clear,
                      onClose: _close,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: CricketText(
                              text: TranslationKeys.navTeams.tr,
                              style: context.homeText(
                                22,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: TranslationKeys.search.tr,
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          onPressed: _open,
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 44),
                  children: [
                    _buildMyTeams(),
                    _buildOrganizations(),
                    _buildNoSearchResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTeams() {
    return Obx(() {
      final all = myTeams.teams;
      final loading = myTeams.isLoading.value && all.isEmpty;
      final failed = myTeams.loadError.value != null;
      final shown = _isFiltering
          ? all.where(_teamMatches).toList()
          : all.toList();

      // A search that matches no team drops the section rather than leaving
      // a header over an empty card.
      if (_isFiltering && !loading && !failed && shown.isEmpty) {
        return const SizedBox.shrink();
      }

      final visible = _isFiltering || _showAllTeams
          ? shown
          : shown.take(_collapsedTeamCount).toList();

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeSectionHeader(
              title: TranslationKeys.myTeams.tr,
              count: shown.isEmpty ? null : shown.length,
              onSeeAll:
                  !_isFiltering &&
                      !_showAllTeams &&
                      all.length > _collapsedTeamCount
                  ? () => setState(() => _showAllTeams = true)
                  : null,
              trailing: IconButton(
                tooltip: TranslationKeys.createTeam.tr,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onPressed: () =>
                    showCreateTeamSheet(teams: myTeams, orgs: orgs),
                icon: Icon(
                  Icons.add_rounded,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            4.h,
            if (loading)
              const HomeListSkeleton()
            else ...[
              if (failed) ...[
                _refreshFailedStrip(myTeams.loadMyTeams),
                if (shown.isNotEmpty) 12.h,
              ],
              if (shown.isNotEmpty)
                CricketGroupedCard(
                  children: [for (final team in visible) TeamRow(team: team)],
                )
              else if (!failed)
                HomeEmptyCard(
                  icon: Icons.groups_outlined,
                  message: TranslationKeys.myTeamsEmptyHint.tr,
                  action: CricketButton(
                    buttonText: TranslationKeys.createTeam.tr,
                    onPressed: () =>
                        showCreateTeamSheet(teams: myTeams, orgs: orgs),
                    width: 220,
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildOrganizations() {
    return Obx(() {
      final all = orgs.organizations;
      final loading = orgs.isLoading.value && all.isEmpty;
      final failed = orgs.loadError.value != null;
      final shown = _isFiltering
          ? all.where(_organizationMatches).toList()
          : all.toList();

      if (_isFiltering && !loading && !failed && shown.isEmpty) {
        return const SizedBox.shrink();
      }

      final visible = _isFiltering
          ? shown
          : shown.take(_organizationPreviewCount).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeSectionHeader(
            title: TranslationKeys.organizations.tr,
            // Full management (leave/delete an organization) stays on the
            // dedicated screen — this is a capped, read-only preview.
            onSeeAll: !_isFiltering && all.length > _organizationPreviewCount
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
          4.h,
          if (loading)
            const HomeListSkeleton(rows: 2)
          else ...[
            if (failed) ...[
              _refreshFailedStrip(orgs.loadOrganizations),
              if (shown.isNotEmpty) 12.h,
            ],
            if (shown.isNotEmpty)
              CricketGroupedCard(
                children: [
                  for (final org in visible) OrganizationRow(org: org),
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
        ],
      );
    });
  }

  /// Shown only when an active search matches neither section, and both have
  /// finished loading without an error — otherwise "nothing found" would be
  /// a claim about data that never arrived.
  Widget _buildNoSearchResults() {
    return Obx(() {
      // Every observable is read before any early return: GetX treats an
      // Obx that returns without reading one as misuse and throws.
      final busy = myTeams.isLoading.value || orgs.isLoading.value;
      final failed =
          myTeams.loadError.value != null || orgs.loadError.value != null;
      final anyMatch =
          myTeams.teams.any(_teamMatches) ||
          orgs.organizations.any(_organizationMatches);
      if (!_isFiltering || busy || failed || anyMatch) {
        return const SizedBox.shrink();
      }

      return HomeSearchEmptyState(
        message: TranslationKeys.noTeamsSearchResults.trParams({
          'query': _text.text.trim(),
        }),
        onClear: _clear,
      );
    });
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
