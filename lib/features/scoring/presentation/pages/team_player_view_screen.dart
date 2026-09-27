import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_entity_avatar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_player_view_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_player_view_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/team_stats_strip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _matchFilters = <(String, String)>[
  ('all', TranslationKeys.filterAll),
  ('live', TranslationKeys.statusLive),
  ('upcoming', TranslationKeys.statusUpcoming),
  ('completed', TranslationKeys.statusCompleted),
];

/// A team the caller plays for but does not run: the roster, stats and matches,
/// with no way to change any of it. The team's scorer manages it from
/// [TeamProfileScreen]; this is the same page with every write control left out.
class TeamPlayerViewScreen extends StatefulWidget {
  const TeamPlayerViewScreen({super.key});

  @override
  State<TeamPlayerViewScreen> createState() => _TeamPlayerViewScreenState();
}

class _TeamPlayerViewScreenState extends State<TeamPlayerViewScreen> {
  // Captured once rather than read from `Get.parameters` in build(): that map is
  // global and follows whichever route is current, so a rebuild for an
  // unrelated reason (a language or theme change) could resolve another team.
  late final String _teamId = Get.parameters['teamId']?.trim() ?? '';
  late final TeamPlayerViewController controller =
      Get.find<TeamPlayerViewController>(tag: _teamId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.teamProfile.tr),
      body: SafeArea(
        child: Obx(() {
          final data = controller.profile.value;
          final error = controller.profileError.value;

          if (controller.isLoadingProfile.value && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && data == null) {
            return _ErrorState(message: error, onRetry: controller.loadProfile);
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => Future.wait([
              controller.loadProfile(),
              controller.loadMatches(),
            ]),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  unawaited(controller.loadMoreMatches());
                }
                return false;
              },
              child: ListView(
                padding: 16.p,
                children: [
                  _Header(profile: data),
                  24.h,
                  CricketText(
                    text: TranslationKeys.teamMatchesSection.tr,
                    style: context.textTheme.titleSmall,
                  ),
                  12.h,
                  _FilterChips(controller: controller),
                  12.h,
                  _Matches(controller: controller),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final TeamPlayerViewRes profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CricketEntityAvatar(name: profile.name, logoUrl: profile.logoUrl),
            16.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CricketText(
                    text: profile.name,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  if (profile.shortName != null) ...[
                    4.h,
                    CricketText(
                      text: profile.shortName!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        12.h,
        CricketText(
          text: TranslationKeys.readOnlyTeamNote.tr,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        16.h,
        if (profile.stats != null) ...[
          TeamStatsStrip(stats: profile.stats!),
          16.h,
        ],
        CricketText(
          text: TranslationKeys.roster.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        8.h,
        if (profile.roster.isEmpty)
          CricketText(text: TranslationKeys.noRosterYet.tr)
        else
          for (final player in profile.roster) _RosterRow(player: player),
      ],
    );
  }
}

/// A name, its leadership badges, jersey and role. Not tappable: a player's
/// career stats belong to the scorer who created them, so there is nowhere
/// this row could send a linked player.
class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.player});

  final TeamPlayerRosterPlayer player;

  String? get _roleLabel => switch (player.role) {
    'batsman' => TranslationKeys.roleBatsman.tr,
    'bowler' => TranslationKeys.roleBowler.tr,
    'allrounder' => TranslationKeys.roleAllrounder.tr,
    'wicketkeeper' => TranslationKeys.roleWicketkeeper.tr,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final muted = context.colorScheme.onSurfaceVariant;
    final role = _roleLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: CricketText(
              text: player.playerName,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          if (player.isCaptain) ...[
            6.w,
            const _Badge(
              label: TranslationKeys.captainShort,
              spoken: TranslationKeys.captain,
            ),
          ],
          if (player.isViceCaptain) ...[
            6.w,
            const _Badge(
              label: TranslationKeys.viceCaptainShort,
              spoken: TranslationKeys.viceCaptain,
            ),
          ],
          const Spacer(),
          if (player.jerseyNumber != null) ...[
            CricketText(
              text: '#${player.jerseyNumber}',
              style: context.textTheme.bodySmall?.copyWith(color: muted),
            ),
            8.w,
          ],
          if (role != null)
            CricketText(
              text: role,
              style: context.textTheme.labelSmall?.copyWith(color: muted),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.spoken});

  final String label;
  final String spoken;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: spoken.tr,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: 6.radius,
        ),
        child: CricketText(
          text: label.tr,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});

  final TeamPlayerViewController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        final active = controller.statusFilter.value;
        return Row(
          children: [
            for (final (status, labelKey) in _matchFilters) ...[
              ChoiceChip(
                label: CricketText(text: labelKey.tr),
                selected: active == status,
                onSelected: (_) =>
                    unawaited(controller.setStatusFilter(status)),
              ),
              8.w,
            ],
          ],
        );
      }),
    );
  }
}

class _Matches extends StatelessWidget {
  const _Matches({required this.controller});

  final TeamPlayerViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMatches.value && controller.matches.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final error = controller.matchesError.value;
      if (error != null && controller.matches.isEmpty) {
        return _ErrorState(message: error, onRetry: controller.loadMatches);
      }

      if (controller.matches.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CricketText(
            text: TranslationKeys.noMatchesYet.tr,
            textAlign: TextAlign.center,
          ),
        );
      }

      return Column(
        children: [
          for (final item in controller.matches) ...[
            MatchHistoryCard(
              item: item,
              // A linked player is never the match's creator or scorer, so the
              // card has no delegation to describe.
              currentUserId: '',
              onTap: () => controller.openMatch(item),
              highlightTeamId: controller.teamId,
              linkTeamNames: false,
            ),
            12.h,
          ],
          if (controller.isLoadingMore.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      );
    });
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: context.colorScheme.onSurfaceVariant,
            ),
            16.h,
            CricketText(
              text: message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            24.h,
            CricketButton(
              buttonText: TranslationKeys.retry.tr,
              onPressed: () => onRetry(),
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}
