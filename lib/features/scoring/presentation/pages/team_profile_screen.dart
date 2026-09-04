import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A team's roster plus its past results — reached by tapping a team's name
/// on a `MatchHistoryCard` (home's match history, or another team's own
/// past-results list). Not a stats page: v1 is deliberately roster + past
/// results only, no aggregate wins/losses/win% — see docs/api.md.
class TeamProfileScreen extends GetView<TeamProfileController> {
  const TeamProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.teamProfile.tr),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.isLoadingProfile.value;
          final error = controller.profileError.value;
          final data = controller.profile.value;

          if (loading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && data == null) {
            return _ErrorState(message: error, onRetry: controller.loadProfile);
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () =>
                Future.wait([controller.loadProfile(), controller.loadMatches()]),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
                  controller.loadMoreMatches();
                }
                return false;
              },
              child: ListView(
                padding: 16.p,
                children: [
                  _TeamHeader(profile: data),
                  24.h,
                  CricketText(
                    text: TranslationKeys.pastResults.tr,
                    style: context.textTheme.titleSmall,
                  ),
                  12.h,
                  Obx(() {
                    if (controller.isLoadingMatches.value &&
                        controller.matches.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final matchesError = controller.matchesError.value;
                    if (matchesError != null && controller.matches.isEmpty) {
                      return _ErrorState(
                        message: matchesError,
                        onRetry: controller.loadMatches,
                      );
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
                            onTap: () => controller.openMatch(item),
                            highlightTeamId: controller.teamId,
                          ),
                          12.h,
                        ],
                        if (controller.isLoadingMore.value)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ),
    );
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

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.profile});

  final TeamProfileRes profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CricketText(
          text: profile.shortName == null
              ? profile.name
              : '${profile.name} (${profile.shortName})',
          style: context.textTheme.headlineSmall,
        ),
        16.h,
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
          for (final player in profile.roster) ...[
            _RosterRow(player: player),
            8.h,
          ],
      ],
    );
  }
}

class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.player});

  final TeamRosterPlayer player;

  String _roleLabel(String role) => switch (role) {
    'batsman' => TranslationKeys.roleBatsman.tr,
    'bowler' => TranslationKeys.roleBowler.tr,
    'allrounder' => TranslationKeys.roleAllrounder.tr,
    'wicketkeeper' => TranslationKeys.roleWicketkeeper.tr,
    _ => TranslationKeys.roleUnknown.tr,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed<dynamic>(AppRoutes.playerStatsPath(player.playerId)),
      child: Row(
        children: [
          Expanded(
            child: CricketText(
              text: player.playerName,
              style: context.textTheme.bodyMedium,
            ),
          ),
          if (player.jerseyNumber != null) ...[
            CricketText(
              text: '#${player.jerseyNumber}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            8.w,
          ],
          CricketText(
            text: _roleLabel(player.role),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
