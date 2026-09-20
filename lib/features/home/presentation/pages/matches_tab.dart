import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_state_placeholders.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_card_actions.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/assign_scorer_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The full match list — exactly what the old single-screen `HomePage` used
/// to show as its entire body (same `HomeController`, same infinite scroll,
/// same pull-to-refresh), now scoped to its own tab and given a status
/// filter. Filtering is view-only, local `StatefulWidget` state: it narrows
/// what's already been fetched rather than changing what `HomeController`
/// fetches, so it can't perfectly pre-filter across a page boundary — a
/// filtered view can look like it has "no more" results before the
/// unfiltered list actually does, for an account with enough matches to
/// paginate at all.
class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

const _filterOptions = <String?>[
  null,
  'live',
  'innings_break',
  'upcoming',
  'completed',
  'abandoned',
];

String _filterLabel(String? status) => switch (status) {
  null => TranslationKeys.filterAll.tr,
  'live' => TranslationKeys.statusLive.tr,
  'innings_break' => TranslationKeys.statusInningsBreak.tr,
  'upcoming' => TranslationKeys.statusUpcoming.tr,
  'completed' => TranslationKeys.statusCompleted.tr,
  'abandoned' => TranslationKeys.statusAbandoned.tr,
  _ => status,
};

class _MatchesTabState extends State<MatchesTab> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.matchHistory.tr,
        actions: [
          PopupMenuButton<String?>(
            tooltip: TranslationKeys.filterMatches.tr,
            icon: Icon(
              _statusFilter == null ? Icons.filter_list : Icons.filter_list_alt,
            ),
            onSelected: (value) => setState(() => _statusFilter = value),
            itemBuilder: (context) => _filterOptions
                .map(
                  (status) => PopupMenuItem<String?>(
                    value: status,
                    child: Text(_filterLabel(status)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
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

          final filtered = _statusFilter == null
              ? controller.matches
              : controller.matches
                    .where((m) => m.status == _statusFilter)
                    .toList();

          if (filtered.isEmpty) {
            // Two different empty states: no matches at all (reuse the same
            // copy the dashboard's empty state shows) vs. a filter that
            // matched nothing (the account has matches, just none of this
            // status) — the latter would otherwise misleadingly say "No
            // matches yet" to someone who has plenty, just not any "Live"
            // ones right now.
            return RefreshIndicator(
              onRefresh: controller.loadHistory,
              child: ListView(
                children: [
                  const SizedBox(height: 120),
                  if (_statusFilter == null)
                    const EmptyMatchesState()
                  else
                    _FilteredEmptyState(label: _filterLabel(_statusFilter)),
                ],
              ),
            );
          }

          final uid = currentUserId();

          return RefreshIndicator(
            onRefresh: controller.loadHistory,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  controller.loadMore();
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 44),
                itemCount: filtered.length + 1,
                separatorBuilder: (_, _) => 12.h,
                itemBuilder: (context, index) {
                  if (index == filtered.length) {
                    return Obx(
                      () => controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }
                  final item = filtered[index];
                  return MatchHistoryCard(
                    item: item,
                    currentUserId: uid,
                    onTap: () => controller.openMatch(item),
                    onDelete: () =>
                        unawaited(confirmDeleteMatch(controller, item)),
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
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 56,
              color: context.colorScheme.onSurfaceVariant,
            ),
            16.h,
            CricketText(
              text: TranslationKeys.noFilteredMatches.trParams({
                'status': label,
              }),
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
