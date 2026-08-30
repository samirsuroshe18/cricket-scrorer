import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/score_ball_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/rate_stats_line.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/strike_banner.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/sync_status_banner.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/toss_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The bowler strip under the strike banner. A plain `StatelessWidget` with no
/// controller of its own, per the private-presentational-sub-widget convention.
class _BowlerLine extends StatelessWidget {
  const _BowlerLine({
    required this.bowlerName,
    required this.needsBowler,
    required this.isInningsComplete,
  });

  final String? bowlerName;
  final bool needsBowler;

  // The innings-complete ball also clears `bowlerName` (the over that just
  // ended has no successor), which the `name == null` branch below would
  // otherwise read as "still need to choose one" — contradicting the
  // all-out text shown beneath it. Checked first so a finished innings never
  // asks who bowls next.
  final bool isInningsComplete;

  @override
  Widget build(BuildContext context) {
    final name = bowlerName;

    if (!isInningsComplete && (needsBowler || name == null || name.isEmpty)) {
      return CricketText(
        text: TranslationKeys.chooseBowler.tr,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.statusWarning,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (name == null || name.isEmpty) return const SizedBox.shrink();

    return CricketText(
      text: '${TranslationKeys.currentBowler.tr}: $name',
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// The confirmation for [ScoreBallController.abandonMatch] — a destructive,
/// unresumable action, so it goes through the same warning-sheet pattern as
/// every other confirm-before-you-break-something moment in this codebase
/// rather than firing straight off a menu tap.
Future<void> _confirmAbandon(ScoreBallController controller) async {
  final confirmed = await CustomBottomSheet.warningBottomSheet<bool>(
    title: TranslationKeys.abandonMatchConfirmTitle.tr,
    message: TranslationKeys.abandonMatchConfirmMessage.tr,
    confirmButtonName: TranslationKeys.abandonMatch.tr,
  );
  if (confirmed == true) {
    await controller.abandonMatch();
  }
}

class ScoreBallScreen extends GetView<ScoreBallController> {
  const ScoreBallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.liveScore.tr,
        // In the app bar rather than beside the run grid on purpose: undo
        // destroys a delivery, and a control that sits a thumb's width from
        // the 6 button is a control that gets tapped by accident during fast
        // scoring. Reaching for it should take a moment.
        actions: [
          // Older matches (created before share codes existed) have no
          // joinCode — hide the action rather than offer to copy null.
          if (controller.match.joinCode != null)
            IconButton(
              tooltip: TranslationKeys.copyShareCode.tr,
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: controller.match.joinCode!),
                );
                CricketSnackbar.showSuccessMessage(
                  TranslationKeys.codeCopied.tr,
                );
              },
              icon: const Icon(Icons.share_outlined),
            ),
          Obx(
            () => IconButton(
              tooltip: TranslationKeys.undoLastBall.tr,
              onPressed: controller.canUndo
                  ? () => unawaited(controller.undoLastBall())
                  : null,
              icon: controller.isUndoing.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.undo2),
            ),
          ),
          Obx(
            () => controller.isAbandoning.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : PopupMenuButton<void>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem<void>(
                        onTap: () => unawaited(_confirmAbandon(controller)),
                        child: CricketText(text: TranslationKeys.abandonMatch.tr),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      // Scrollable rather than a bare Column: the sync banner at the top
      // adds height on demand (offline queue banner, conflict/blocked-on-rule
      // states), and a fixed-height body would push the run/OUT buttons
      // below the viewport instead of just scrolling to reach them.
      body: SingleChildScrollView(
        padding: 24.p,
        child: Column(
          children: [
            // Topmost, above even the team names — "is my data safe" should
            // never require scrolling past the score to find out.
            Obx(() {
              final pendingCount = controller.offlineSyncService.pendingCount.value;
              final phase = controller.offlineSyncService.phase.value;
              if (pendingCount == 0 && phase == SyncPhase.idle) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  SyncStatusBanner(
                    pendingCount: pendingCount,
                    phase: phase,
                    lastError: controller.offlineSyncService.lastError.value,
                    onRetry: () => unawaited(controller.handleSyncBannerTap()),
                  ),
                  12.h,
                ],
              );
            }),
            CricketText(
              text:
                  '${controller.match.teamA.name} vs ${controller.match.teamB.name}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            4.h,
            TossLine(
              tossWinner: controller.match.tossWinner,
              tossDecision: controller.match.tossDecision,
              nameFor: (sideLabel) => sideLabel == 'teamA'
                  ? controller.match.teamA.name
                  : controller.match.teamB.name,
            ),
            24.h,
            Obx(
              () => Column(
                children: [
                  CricketText(
                    text:
                        '${controller.totalRuns.value}/${controller.wickets.value}',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  8.h,
                  CricketText(
                    text:
                        '${TranslationKeys.overs.tr}: ${controller.overs.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  4.h,
                  CricketText(
                    text:
                        '${TranslationKeys.extras.tr}: ${controller.extrasTotal.value}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  8.h,
                  RateStatsLine(
                    currentRunRate: controller.currentRunRate.value,
                    requiredRunRate: controller.requiredRunRate.value,
                    partnershipRuns: controller.partnershipRuns.value,
                    partnershipBalls: controller.partnershipBalls.value,
                  ),
                ],
              ),
            ),
            24.h,
            Obx(() => StrikeBanner(strike: controller.strike.value)),
            8.h,
            // Who is bowling, and — between overs — that somebody has to be
            // chosen. The run buttons below are disabled in that state via
            // `canScore`; this line is what explains why.
            Obx(
              () => _BowlerLine(
                bowlerName: controller.currentBowler.value,
                needsBowler: controller.needsBowler.value,
                isInningsComplete: controller.isInningsComplete.value,
              ),
            ),
            16.h,
            CricketText(
              text: TranslationKeys.wideOrNoBall.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            8.h,
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  FilterChip(
                    label: CricketText(text: TranslationKeys.wide.tr),
                    selected: controller.selectedFault.value == ExtraType.wide,
                    onSelected: (_) => controller.toggleFault(ExtraType.wide),
                  ),
                  FilterChip(
                    label: CricketText(text: TranslationKeys.noBall.tr),
                    selected:
                        controller.selectedFault.value == ExtraType.noBall,
                    onSelected: (_) => controller.toggleFault(ExtraType.noBall),
                  ),
                ],
              ),
            ),
            16.h,
            CricketText(
              text: TranslationKeys.byeOrLegBye.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            8.h,
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  FilterChip(
                    label: CricketText(text: TranslationKeys.bye.tr),
                    selected: controller.selectedRunsFrom.value == RunsFrom.bye,
                    onSelected: controller.isRunsFromDisabled
                        ? null
                        : (_) => controller.toggleRunsFrom(RunsFrom.bye),
                  ),
                  FilterChip(
                    label: CricketText(text: TranslationKeys.legBye.tr),
                    selected:
                        controller.selectedRunsFrom.value == RunsFrom.legBye,
                    onSelected: controller.isRunsFromDisabled
                        ? null
                        : (_) => controller.toggleRunsFrom(RunsFrom.legBye),
                  ),
                ],
              ),
            ),
            24.h,
            CricketText(
              text: TranslationKeys.selectRuns.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            16.h,
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...[0, 1, 2, 3, 4, 6].map(
                    (runs) => SizedBox(
                      width: 64,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: controller.canScore
                            ? () => controller.scoreRuns(runs)
                            : null,
                        child: CricketText(text: '$runs'),
                      ),
                    ),
                  ),
                  SizedBox(
                    // Wider than the run buttons: "OUT" wraps to two letters in
                    // a 64pt box, and the extra width doubles as a signal that
                    // this is a different kind of action.
                    width: 96,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.statusDanger,
                      ),
                      onPressed: controller.canScore
                          ? () => unawaited(controller.promptForWicket())
                          : null,
                      child: CricketText(text: TranslationKeys.out.tr),
                    ),
                  ),
                ],
              ),
            ),
            16.h,
            Obx(() {
              if (controller.isInningsComplete.value) {
                return CricketText(
                  text: TranslationKeys.allOut.tr,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.statusDanger,
                  ),
                );
              }
              // The bowler sheet is blocking, so this is normally behind it.
              // It matters when the sheet has been dismissed by a system back
              // gesture: the console stays locked, and this says why.
              if (controller.needsBowler.value) {
                return CricketText(
                  text:
                      '${TranslationKeys.endOfOver.tr} — '
                      '${TranslationKeys.chooseBowler.tr}',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.statusWarning,
                  ),
                  textAlign: TextAlign.center,
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
