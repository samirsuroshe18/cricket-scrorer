import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/spectator_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_result_banner.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/rate_stats_line.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/strike_banner.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/toss_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reachable from a cold, never-authenticated launch — see
/// [PendingDeepLink] and [SplashController] — so this screen and everything
/// under it must build with no signed-in user, no token, and no other
/// feature's state assumed to exist.
///
/// There is no control on this screen that sends anything to the server.
/// [SpectatorController] has no method that could; see [SpectatorBinding]'s
/// doc comment for why that is a property of the dependency graph, not a
/// promise kept by this file.
class SpectatorScreen extends GetView<SpectatorController> {
  const SpectatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.liveScore.tr),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.loadError.value;
          if (error != null) {
            return _ErrorState(message: error, onRetry: controller.retry);
          }

          return _MatchView(controller: controller);
        }),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_cricket_outlined,
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
              onPressed: onRetry,
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchView extends StatelessWidget {
  const _MatchView({required this.controller});

  final SpectatorController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final match = controller.matchInfo.value;

      return SingleChildScrollView(
        padding: 24.p,
        child: Column(
          children: [
            CricketText(
              text:
                  '${match?.teamA.name ?? '-'} vs ${match?.teamB.name ?? '-'}',
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            8.h,
            CricketText(
              text: '${TranslationKeys.overs.tr}: ${match?.totalOvers ?? '-'}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            4.h,
            TossLine(
              tossWinner: match?.tossWinner,
              tossDecision: match?.tossDecision,
              nameFor: (sideLabel) => sideLabel == 'teamA'
                  ? (match?.teamA.name ?? sideLabel)
                  : (match?.teamB.name ?? sideLabel),
            ),
            24.h,

            if (controller.matchResult.value != null) ...[
              // Not gated on hasInningsStarted, unlike the live block below:
              // an overs-complete or target-achieved ending dismisses
              // nobody, so the striker is still non-null and that flag would
              // wrongly route here through the live branch instead. See
              // matchResult's own doc comment.
              MatchResultBanner(
                result: controller.matchResult.value!,
                nameFor: (sideLabel) => sideLabel == 'teamA'
                    ? (match?.teamA.name ?? sideLabel)
                    : (match?.teamB.name ?? sideLabel),
              ),
              16.h,
              CricketText(
                text:
                    '${controller.totalRuns.value}/${controller.wickets.value}',
                style: context.textTheme.displayMedium,
              ),
              8.h,
              CricketText(
                text: '${TranslationKeys.overs.tr}: ${controller.overs.value}',
                style: context.textTheme.bodyMedium,
              ),
              4.h,
              CricketText(
                text:
                    '${TranslationKeys.extras.tr}: ${controller.extrasTotal.value}',
                style: context.textTheme.bodySmall,
              ),
            ] else if (!controller.hasInningsStarted)
              _WaitingForPlay(status: match?.status)
            else ...[
              CricketText(
                text:
                    '${controller.totalRuns.value}/${controller.wickets.value}',
                style: context.textTheme.displayMedium,
              ),
              8.h,
              CricketText(
                text: '${TranslationKeys.overs.tr}: ${controller.overs.value}',
                style: context.textTheme.bodyMedium,
              ),
              4.h,
              CricketText(
                text:
                    '${TranslationKeys.extras.tr}: ${controller.extrasTotal.value}',
                style: context.textTheme.bodySmall,
              ),
              8.h,
              RateStatsLine(
                currentRunRate: controller.currentRunRate.value,
                requiredRunRate: controller.requiredRunRate.value,
                partnershipRuns: controller.partnershipRuns.value,
                partnershipBalls: controller.partnershipBalls.value,
              ),
              24.h,
              StrikeBanner(strike: controller.strike.value),
              12.h,
              if (controller.currentBowler.value != null)
                CricketText(
                  text:
                      '${TranslationKeys.currentBowler.tr}: '
                      '${controller.currentBowler.value}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ],
        ),
      );
    });
  }
}

class _WaitingForPlay extends StatelessWidget {
  const _WaitingForPlay({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final text = status == 'completed'
        ? TranslationKeys.matchCompleted.tr
        : TranslationKeys.waitingForPlayToBegin.tr;

    return CricketText(
      text: text,
      style: context.textTheme.titleMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}
