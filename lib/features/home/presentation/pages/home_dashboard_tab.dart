import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_sync_status_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_stats_controller.dart';
import 'package:cricket_scorer/features/home/presentation/utils/home_match_view.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_header.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_hero_card.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_live_carousel.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_recent_results.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_section_header.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_skeleton.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_state_placeholders.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_stat_chips.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_actions_sheet.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/watch_match_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const _liveNowStatuses = {'live', 'innings_break'};
const _terminalStatuses = {'completed', 'abandoned'};

/// How many recent results Home previews. "See all" jumps to the Matches tab
/// rather than pushing a route — it is the same shell, a different tab.
const _recentCap = 3;

/// Side gutter of the whole dashboard. Sections that bleed to the screen edge
/// (the live carousel) opt out of it and pad themselves.
const _gutter = EdgeInsets.symmetric(horizontal: 16);

/// Home: one hero for what the user needs next, quiet shortcuts, other live
/// matches as a sideways row, and recent results as flat rows. Reads the same
/// [HomeController] the Matches tab does — one fetch, two views of it.
class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  Future<void> _refresh() => Future.wait([
    Get.find<HomeController>().loadHistory(),
    Get.find<MyStatsController>().load(),
  ]);

  void _startMatch() => unawaited(Get.toNamed<dynamic>(AppRoutes.createMatch));

  void _share(MatchHistoryItem item) {
    final code = item.joinCode;
    if (code == null) return;
    unawaited(
      Clipboard.setData(
        ClipboardData(
          text: TranslationKeys.homeShareMessage.trParams({
            'teams': '${item.teamA.name} vs ${item.teamB.name}',
            'code': code,
            'link': 'cricketscorer:///spectate/$code',
          }),
        ),
      ),
    );
    CricketSnackbar.showSuccessMessage(TranslationKeys.homeLinkCopied.tr);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final shell = Get.find<MainShellController>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final user = controller.currentUserProfile.value;

          if (controller.isLoading.value && controller.matches.isEmpty) {
            return HomeSkeleton(user: user);
          }

          final error = controller.loadError.value;
          if (error != null && controller.matches.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: HomeHeader(user: user),
                ),
                Expanded(
                  child: MatchesErrorState(
                    message: error,
                    onRetry: controller.loadHistory,
                  ),
                ),
              ],
            );
          }

          final matches = controller.matches;
          final uid = currentUserId();
          final isFirstRun = matches.isEmpty;

          final live = matches
              .where((m) => _liveNowStatuses.contains(m.status))
              .toList();
          // What the user is scoring right now beats anything else Home could
          // put in the hero; failing that, a match created but never started.
          final hero =
              live.firstWhereOrNull((m) => isScoredBy(m, uid)) ??
              matches.firstWhereOrNull(
                (m) => m.status == 'upcoming' && isScoredBy(m, uid),
              );
          final otherLive = live.where((m) => m != hero).toList();
          final recent = matches
              .where((m) => _terminalStatuses.contains(m.status))
              .take(_recentCap)
              .toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              children: [
                Padding(
                  padding: _gutter,
                  child: HomeHeader(user: user),
                ),
                16.h,
                _TopStrip(controller: controller),
                Padding(
                  padding: _gutter,
                  child: hero != null
                      ? ResumeScoringHero(
                          item: hero,
                          onResume: () => controller.openMatch(hero),
                        )
                      : isFirstRun
                      ? FirstMatchHero(onStart: _startMatch)
                      : StartMatchHero(onStart: _startMatch),
                ),
                16.h,
                Padding(
                  padding: _gutter,
                  child: HomeActionRow(
                    pills: [
                      HomeActionPill(
                        icon: Icons.qr_code_rounded,
                        label: isFirstRun
                            ? TranslationKeys.homeWatchWithCode.tr
                            : TranslationKeys.homeJoinByCode.tr,
                        onTap: () => unawaited(WatchMatchBottomSheet.show()),
                      ),
                      HomeActionPill(
                        icon: Icons.groups_outlined,
                        label: TranslationKeys.myTeams.tr,
                        onTap: () => shell.showTab(2),
                      ),
                      if (!isFirstRun)
                        HomeActionPill(
                          icon: Icons.search_rounded,
                          label: TranslationKeys.search.tr,
                          onTap: () => unawaited(
                            Get.toNamed<dynamic>(AppRoutes.search),
                          ),
                        ),
                    ],
                  ),
                ),
                18.h,
                if (otherLive.isNotEmpty) ...[
                  Padding(
                    padding: _gutter,
                    child: HomeSectionHeader(
                      title: TranslationKeys.liveNow.tr,
                      onSeeAll: () => shell.showTab(1),
                    ),
                  ),
                  4.h,
                  HomeLiveCarousel(
                    items: otherLive,
                    onOpen: controller.openMatch,
                    onShare: _share,
                    onMore: (item) => unawaited(
                      showMatchActionsSheet(controller: controller, item: item),
                    ),
                  ),
                  18.h,
                ],
                const _SeasonSection(),
                if (recent.isNotEmpty) ...[
                  Padding(
                    padding: _gutter,
                    child: HomeSectionHeader(
                      title: TranslationKeys.homeRecentResults.tr,
                      onSeeAll: () => shell.showTab(1),
                    ),
                  ),
                  Padding(
                    padding: _gutter,
                    child: HomeRecentResults(
                      items: recent,
                      onOpen: controller.openMatch,
                      onMore: (item) => unawaited(
                        showMatchActionsSheet(
                          controller: controller,
                          item: item,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Hidden until the user has claimed at least one Player and the first load
/// has succeeded, so a new user never sees a strip of zeros.
class _SeasonSection extends StatelessWidget {
  const _SeasonSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyStatsController>();

    return Obx(() {
      final stats = controller.stats.value;
      if (stats == null || stats.linkedPlayerCount == 0) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(title: TranslationKeys.homeYourSeason.tr),
            8.h,
            HomeStatChips(stats: stats),
          ],
        ),
      );
    });
  }
}

/// The single most serious thing needing attention, or nothing. Conflict beats
/// waiting-to-sync beats a failed refresh — a stuck scoring conflict is data at
/// risk, a stale list is only stale.
class _TopStrip extends StatelessWidget {
  const _TopStrip({required this.controller});

  final HomeController controller;

  void _open(String? matchId) {
    final match = controller.matches.firstWhereOrNull(
      (m) => m.matchId == matchId,
    );
    if (match != null) controller.openMatch(match);
  }

  @override
  Widget build(BuildContext context) {
    final sync = Get.isRegistered<HomeSyncStatusController>()
        ? Get.find<HomeSyncStatusController>()
        : null;

    return Obx(() {
      final conflicts = controller.matches
          .where((m) => m.syncStatus == 'conflict')
          .toList();
      final pending = sync?.pendingCount.value ?? 0;
      final balls = sync?.ballCount.value ?? 0;
      final offline = sync?.isOffline.value ?? false;
      final refreshFailed =
          controller.loadError.value != null && controller.matches.isNotEmpty;

      final HomeStatusStrip? strip;
      if (conflicts.isNotEmpty) {
        final first = conflicts.first;
        strip = HomeStatusStrip(
          tone: HomeStripTone.danger,
          icon: Icons.sync_problem_rounded,
          message: conflicts.length == 1
              ? TranslationKeys.homeSyncConflictOne.trParams({
                  'match': '${first.teamA.name} vs ${first.teamB.name}',
                })
              : TranslationKeys.homeSyncConflictMany.trParams({
                  'count': '${conflicts.length}',
                }),
          actionLabel: TranslationKeys.homeStripReview.tr,
          onTap: () => controller.openMatch(first),
        );
      } else if (pending > 0) {
        final body = balls == 0
            ? TranslationKeys.homeUpdatesWaiting.tr
            : balls == 1
            ? TranslationKeys.homeBallsWaitingOne.tr
            : TranslationKeys.homeBallsWaitingMany.trParams({
                'count': '$balls',
              });
        strip = HomeStatusStrip(
          tone: HomeStripTone.warning,
          icon: offline ? Icons.cloud_off_outlined : Icons.cloud_sync_outlined,
          message: offline
              ? '${TranslationKeys.homeOfflinePrefix.tr} · $body'
              : body,
          actionLabel: TranslationKeys.homeStripDetails.tr,
          onTap: () => _open(sync?.pendingMatchId.value),
        );
      } else if (refreshFailed) {
        strip = HomeStatusStrip(
          tone: HomeStripTone.neutral,
          icon: Icons.refresh_rounded,
          message: TranslationKeys.homeRefreshFailed.tr,
          actionLabel: TranslationKeys.retry.tr,
          onTap: () => unawaited(controller.loadHistory()),
        );
      } else {
        strip = null;
      }

      if (strip == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: strip,
      );
    });
  }
}
