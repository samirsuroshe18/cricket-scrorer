import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_stats_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_stat_chips.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_state_placeholders.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_card_actions.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/assign_scorer_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/watch_match_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The statuses that still need scoring — a match that's live, mid
/// innings-break, or created but not finished. Mirrors
/// `HomeController._liveStatuses`, which decides where a tap on the card
/// routes to; this decides which dashboard section the card appears in.
const _liveNowStatuses = {'live', 'innings_break'};
const _terminalStatuses = {'completed', 'abandoned'};

/// One capped preview per section — enough to answer "what's happening
/// right now" at a glance without turning Home back into the full list the
/// Matches tab already is. "See all" on a capped section jumps to that tab
/// instead of pushing a new route.
const _sectionCap = 3;

/// Home tab: a dashboard, not a list. Reuses the same [HomeController] the
/// Matches tab reads from — one fetch, two views of it — grouped into
/// Live Now / Continue Scoring / Recent Matches rather than one flat feed.
/// Cards render exactly what the full Matches tab's cards already show,
/// `MatchHistoryItem.currentInnings` score included where present.
class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final shell = Get.find<MainShellController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.matches.isEmpty) {
            return const Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _BrandStrip(),
                ),
                Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          final error = controller.loadError.value;
          if (error != null && controller.matches.isEmpty) {
            return MatchesErrorState(
              message: error,
              onRetry: controller.loadHistory,
            );
          }

          if (controller.matches.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => Future.wait([
                controller.loadHistory(),
                Get.find<MyStatsController>().load(),
              ]),
              child: ListView(
                padding: 16.p,
                children: [
                  const _BrandStrip(),
                  12.h,
                  _Header(controller: controller),
                  16.h,
                  const _MyStatsSection(),
                  _QuickActionsRow(shell: shell),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.42,
                    child: const EmptyMatchesState(),
                  ),
                ],
              ),
            );
          }

          final uid = currentUserId();
          final liveNow = controller.matches
              .where((m) => _liveNowStatuses.contains(m.status))
              .toList();
          final continueScoring = controller.matches
              .where((m) => m.status == 'upcoming')
              .toList();
          final recent = controller.matches
              .where((m) => _terminalStatuses.contains(m.status))
              .toList();

          Widget buildCard(MatchHistoryItem item) => MatchHistoryCard(
            item: item,
            currentUserId: uid,
            onTap: () => controller.openMatch(item),
            onDelete: () => unawaited(confirmDeleteMatch(controller, item)),
            onAssignScorer: () => unawaited(
              showAssignScorerSheet(
                item: item,
                loadCandidates: controller.loadScorerCandidates,
                onAssign: controller.assignScorer,
              ),
            ),
            isDeleting: () =>
                controller.deletingMatchIds.contains(item.matchId),
          );

          return RefreshIndicator(
            onRefresh: () => Future.wait([
              controller.loadHistory(),
              Get.find<MyStatsController>().load(),
            ]),
            child: ListView(
              padding: 16.p,
              children: [
                const _BrandStrip(),
                12.h,
                _Header(controller: controller),
                16.h,
                const _MyStatsSection(),
                _QuickActionsRow(shell: shell),
                24.h,
                if (liveNow.isNotEmpty) ...[
                  DashboardSectionHeader(
                    title: TranslationKeys.liveNow.tr,
                    onSeeAll: liveNow.length > _sectionCap
                        ? () => shell.showTab(1)
                        : null,
                  ),
                  12.h,
                  ...liveNow
                      .take(_sectionCap)
                      .map(buildCard)
                      .expand((card) => [card, 12.h]),
                  8.h,
                ],
                if (continueScoring.isNotEmpty) ...[
                  DashboardSectionHeader(
                    title: TranslationKeys.continueScoring.tr,
                    onSeeAll: continueScoring.length > _sectionCap
                        ? () => shell.showTab(1)
                        : null,
                  ),
                  12.h,
                  ...continueScoring
                      .take(_sectionCap)
                      .map(buildCard)
                      .expand((card) => [card, 12.h]),
                  8.h,
                ],
                if (recent.isNotEmpty) ...[
                  DashboardSectionHeader(
                    title: TranslationKeys.recentMatches.tr,
                    onSeeAll: () => shell.showTab(1),
                  ),
                  12.h,
                  ...recent
                      .take(_sectionCap)
                      .map(buildCard)
                      .expand((card) => [card, 12.h]),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final username = controller.currentUserProfile.value?.userName;
              final greeting = (username != null && username.isNotEmpty)
                  ? TranslationKeys.homeGreeting.trParams({'name': username})
                  : TranslationKeys.homeGreetingNoName.tr;
              return CricketText(
                text: greeting,
                style: context.textTheme.headlineMedium,
              );
            }),
          ),
          const _NotificationBell(),
        ],
      ),
    );
  }
}

/// Hidden until the user has claimed at least one Player and the first load
/// has succeeded, so a new user never sees a strip of zeros.
class _MyStatsSection extends StatelessWidget {
  const _MyStatsSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyStatsController>();

    return Obx(() {
      final stats = controller.stats.value;
      if (stats == null || stats.linkedPlayerCount == 0) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: HomeStatChips(stats: stats),
      );
    });
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final notifications = Get.find<NotificationsController>();

    return Obx(() {
      final count = notifications.unreadCount.value;
      return IconButton(
        tooltip: TranslationKeys.notifications.tr,
        onPressed: () => Get.toNamed<dynamic>(AppRoutes.notifications),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: context.colors.statusDanger,
                    borderRadius: 8.radius,
                  ),
                  child: CricketText(
                    text: count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// A compact take on `AuthScoreboardHeader`'s ball-mark + wordmark + accent
/// bar — same brand language, sized for a dashboard row rather than a full
/// auth screen (no theme/language pickers; those already live in Settings).
/// Kept visible through the loading state too, so Home never looks blank
/// while the first fetch is in flight.
class _BrandStrip extends StatelessWidget {
  const _BrandStrip();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Row(
      children: [
        const ExcludeSemantics(
          child: CricketImage(
            source: CricketImageSource.asset(AssetsUtil.ballMark),
            width: 18,
            height: 15,
            fit: BoxFit.contain,
          ),
        ),
        6.w,
        CricketText(
          text: TranslationKeys.cricketScorer.tr.toUpperCase(),
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: scheme.onSurfaceVariant,
          ),
        ),
        10.w,
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: 1.radius,
            ),
          ),
        ),
      ],
    );
  }
}

/// Supplements the shell's "Start Match" FAB with a row of the other common
/// entry points a single FAB under-discovers, per the Home UI/UX review.
/// Start Match is kept first — it stays the primary action — and the other
/// two reuse navigation the app already has: [WatchMatchBottomSheet] (the
/// same sheet the login screen's spectator entry point uses) and the shell's
/// own Teams tab.
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.shell});

  final MainShellController shell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.add_circle_outline,
            label: TranslationKeys.startMatch.tr,
            onTap: () => Get.toNamed<dynamic>(AppRoutes.createMatch),
          ),
        ),
        10.w,
        Expanded(
          child: _QuickActionTile(
            icon: Icons.qr_code_rounded,
            label: TranslationKeys.joinByCode.tr,
            onTap: () => unawaited(WatchMatchBottomSheet.show()),
          ),
        ),
        10.w,
        Expanded(
          child: _QuickActionTile(
            icon: Icons.groups_outlined,
            label: TranslationKeys.navTeams.tr,
            onTap: () => shell.showTab(2),
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.5),
      borderRadius: 14.radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: scheme.primary),
              6.h,
              CricketText(
                text: label,
                textAlign: TextAlign.center,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
