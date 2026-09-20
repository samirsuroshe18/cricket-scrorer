import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/current_user.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_section_header.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_state_placeholders.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_actions_sheet.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_list_row.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/matches_skeleton.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The full match list — the same `HomeController` fetch, infinite scroll and
/// pull-to-refresh Home reads, scoped to its own tab with a status filter.
/// The filter is server-side: picking a chip asks `GET /v1/match/history` for
/// just that status (`HomeController.selectStatusFilter`), so a live match on
/// a later page is found rather than hidden, and the chips' counts come from
/// the server too. "All" is the same list Home reads.
class MatchesTab extends StatelessWidget {
  const MatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Semantics(
                header: true,
                child: CricketText(
                  text: TranslationKeys.navMatches.tr,
                  style: context.homeText(22, weight: FontWeight.w600),
                ),
              ),
            ),
            Obx(() {
              final counts = controller.statusCounts;
              final hasLive = counts.isNotEmpty
                  ? (_countFor('live', counts) ?? 0) > 0
                  : controller.matches.any(
                      (m) => _liveStatuses.contains(m.status),
                    );
              return _FilterChips(
                selected: controller.statusFilter.value,
                showLiveDot: hasLive,
                countFor: (filter) => _countFor(filter, counts),
                onSelected: (value) =>
                    unawaited(controller.selectStatusFilter(value)),
              );
            }),
            12.h,
            Expanded(child: _MatchesBody(controller: controller)),
          ],
        ),
      ),
    );
  }
}

/// `null` is "All". `live` also covers `innings_break`, which is a kind of
/// live rather than a state of its own to a scorer choosing what to open.
const _filterOptions = <String?>[
  null,
  'live',
  'upcoming',
  'completed',
  'abandoned',
];

const _liveStatuses = {'live', 'innings_break'};
const _inProgressStatuses = {'live', 'innings_break', 'upcoming'};

String _filterLabel(String? status) => switch (status) {
  null => TranslationKeys.filterAll.tr,
  'live' => TranslationKeys.statusLive.tr,
  'upcoming' => TranslationKeys.statusUpcoming.tr,
  'completed' => TranslationKeys.statusCompleted.tr,
  'abandoned' => TranslationKeys.statusAbandoned.tr,
  _ => status,
};

/// A chip's number from the server's per-status counts, or null when there
/// are none yet (first load, or a server that predates them) so the chip
/// shows no number rather than a misleading zero.
int? _countFor(String? filter, Map<String, int> counts) {
  if (counts.isEmpty) return null;
  return switch (filter) {
    null => counts.values.fold<int>(0, (sum, n) => sum + n),
    'live' => (counts['live'] ?? 0) + (counts['innings_break'] ?? 0),
    _ => counts[filter] ?? 0,
  };
}

/// Side gutter of the whole tab.
const _gutter = EdgeInsets.symmetric(horizontal: 16);

class _MatchesBody extends StatelessWidget {
  const _MatchesBody({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filter = controller.statusFilter.value;
      final isAll = filter == null;
      final items = (isAll ? controller.matches : controller.filteredMatches)
          .toList();
      final loading = isAll
          ? controller.isLoading.value
          : controller.isLoadingFiltered.value;
      final error = isAll
          ? controller.loadError.value
          : controller.filteredError.value;
      final hasMore = isAll
          ? controller.hasMore.value
          : controller.hasMoreFiltered.value;
      final isLoadingMore = isAll
          ? controller.isLoadingMore.value
          : controller.isLoadingMoreFiltered.value;
      final loadMore = isAll
          ? controller.loadMore
          : controller.loadMoreFiltered;
      final reload = isAll ? controller.loadHistory : controller.loadFiltered;

      if (loading && items.isEmpty) return const MatchesSkeleton();

      if (error != null && items.isEmpty) {
        return MatchesErrorState(message: error, onRetry: reload);
      }

      if (items.isEmpty) {
        // Two different empty states: no matches at all (the same copy the
        // dashboard's empty state shows) vs. a filter the server found
        // nothing for — the latter would otherwise say "No matches yet" to
        // someone who has plenty, just none of this status right now.
        return RefreshIndicator(
          onRefresh: controller.refreshMatches,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 44),
            children: [
              if (isAll) ...[
                120.h,
                const EmptyMatchesState(),
              ] else ...[
                48.h,
                _FilteredEmptyState(
                  label: _filterLabel(filter),
                  onShowAll: () =>
                      unawaited(controller.selectStatusFilter(null)),
                ),
              ],
            ],
          ),
        );
      }

      final uid = currentUserId();
      final List<({String? title, List<MatchHistoryItem> items})> sections =
          isAll
          ? [
              (
                title: TranslationKeys.matchesSectionActive.tr,
                items: items
                    .where((m) => _inProgressStatuses.contains(m.status))
                    .toList(),
              ),
              (
                title: TranslationKeys.matchesSectionPast.tr,
                items: items
                    .where((m) => !_inProgressStatuses.contains(m.status))
                    .toList(),
              ),
            ]
          : [(title: null, items: items)];

      return RefreshIndicator(
        onRefresh: controller.refreshMatches,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              unawaited(loadMore());
            }
            return false;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 44),
            children: [
              if (error != null) ...[
                HomeStatusStrip(
                  tone: HomeStripTone.neutral,
                  icon: Icons.refresh_rounded,
                  message: TranslationKeys.homeRefreshFailed.tr,
                  actionLabel: TranslationKeys.retry.tr,
                  onTap: () => unawaited(reload()),
                ),
                12.h,
              ],
              for (final section in sections)
                if (section.items.isNotEmpty) ...[
                  if (section.title case final title?)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: HomeSectionHeader(title: title),
                    ),
                  for (final item in section.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MatchListRow(
                        item: item,
                        currentUserId: uid,
                        onTap: () => controller.openMatch(item),
                        onMore: () => unawaited(
                          showMatchActionsSheet(
                            controller: controller,
                            item: item,
                          ),
                        ),
                        isDeleting: () =>
                            controller.deletingMatchIds.contains(item.matchId),
                      ),
                    ),
                ],
              if (hasMore)
                _LoadMoreButton(
                  isLoading: isLoadingMore,
                  onTap: () => unawaited(loadMore()),
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// Single-select status filter. Neutral ink when selected so the brand red
/// stays reserved for "live" — the dot on the Live chip is the only red here.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.showLiveDot,
    required this.countFor,
    required this.onSelected,
  });

  final String? selected;
  final bool showLiveDot;
  final int? Function(String? filter) countFor;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: _gutter,
      child: Row(
        children: [
          for (final option in _filterOptions) ...[
            _FilterChip(
              label: _filterLabel(option),
              count: countFor(option),
              isSelected: option == selected,
              showDot: option == 'live' && showLiveDot,
              onTap: () => onSelected(option),
            ),
            8.w,
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.showDot,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool isSelected;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final ink = isSelected ? scheme.surface : scheme.onSurface;
    // The number stays in the chip's own ink when selected (muted grey on the
    // dark selected fill would fall short), and muted on an unselected chip.
    final countInk = isSelected ? scheme.surface : context.homeMuted;

    final fill = isSelected ? scheme.onSurface : context.homeCard;
    final splashInk = isSelected ? scheme.surface : scheme.onSurface;
    final outline = isSelected ? scheme.onSurface : context.homeLine;

    return Semantics(
      button: true,
      selected: isSelected,
      label: count == null ? label : '$label, $count',
      excludeSemantics: true,
      // The outer detector keeps the full 44px-tall touch target; the ink
      // itself lives on the chip's own Material below, so its splash and
      // highlight are clipped to the pill instead of bleeding onto the page
      // around it (which read as a white halo on the dark theme).
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Center(
            child: Material(
              color: fill,
              shape: StadiumBorder(side: BorderSide(color: outline)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                customBorder: const StadiumBorder(),
                // Explicit rather than the theme's faint iOS grey, in the
                // colour that reads against this chip's own fill: light ink
                // on the dark chip, and the reverse on the selected one.
                // Both are painted on the pill's Material, so they are
                // clipped to its shape and never spill onto the page.
                splashColor: splashInk.withValues(alpha: 0.22),
                highlightColor: splashInk.withValues(alpha: 0.14),
                child: Padding(
                  // Not symmetric on purpose: the app font reserves more room
                  // above its baseline than the letters use, so equal padding
                  // left the label about 1pt low in the pill (measured on a
                  // device screenshot). One point moved from top to bottom
                  // puts the ink in the middle.
                  padding: const EdgeInsets.only(
                    left: 14,
                    right: 14,
                    top: 6,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showDot) ...[
                        // Nudged down to sit level with the label's
                        // x-height, which is below the line box's centre.
                        Padding(
                          padding: const EdgeInsets.only(top: 1.5),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        6.w,
                      ],
                      CricketText(
                        text: label,
                        maxLines: 1,
                        style: context.homeText(
                          13,
                          weight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: ink,
                        ),
                      ),
                      if (count != null) ...[
                        6.w,
                        CricketText(
                          text: '$count',
                          maxLines: 1,
                          style: context.homeText(
                            13,
                            color: countInk,
                            tabular: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tap fallback for a list too short to scroll: the scroll-to-bottom
/// trigger never fires there, so this calls the same `loadMore` on a tap.
class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: context.homeCardDecoration(alwaysBordered: true),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: 12.radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CricketText(
                      text: TranslationKeys.loadMoreMatches.tr,
                      style: context.homeText(14),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.label, required this.onShowAll});

  final String label;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 24.p,
      child: Column(
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
          8.h,
          TextButton(
            onPressed: onShowAll,
            child: CricketText(
              text: TranslationKeys.showAllMatches.tr,
              // Ink plus an underline, not the interactive blue: 14px text in
              // that blue is 4.3:1 on a white card, short of 4.5:1.
              style: context
                  .homeText(14, weight: FontWeight.w600)
                  .copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
