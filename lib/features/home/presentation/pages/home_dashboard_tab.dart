import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_state_placeholders.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_card_actions.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/assign_scorer_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
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
/// Live-score detail isn't shown here: `MatchHistoryItem` (and the API
/// response behind it) carries no score field today, only status/teams/
/// overs, so these cards show exactly what the full Matches tab's cards
/// already show. Adding a score requires a backend + DTO change, called out
/// separately rather than built silently.
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
            return const Center(child: CircularProgressIndicator());
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
              onRefresh: controller.loadHistory,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _Header(controller: controller),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.5,
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
            onRefresh: controller.loadHistory,
            child: ListView(
              padding: 16.p,
              children: [
                _Header(controller: controller),
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
      padding: const EdgeInsets.only(top: 8, bottom: 4),
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
