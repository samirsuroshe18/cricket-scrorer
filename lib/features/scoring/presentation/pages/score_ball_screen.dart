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

    // Bumped from `onSurfaceVariant`/`bodySmall` to `onSurface`/`bodyMedium`
    // at bold weight: who's currently bowling is functionally load-bearing
    // (it's why the console may be locked), and muted small gray-on-navy is
    // the first thing direct sunlight washes out.
    return CricketText(
      text: '${TranslationKeys.currentBowler.tr}: $name',
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// The score/overs/extras/rate readout. A single high-contrast card instead
/// of bare text stacked in the page column — same numbers, but everything
/// that used to render in muted `onSurfaceVariant` gray now sits on
/// `onSurface`, since hierarchy here comes from size and weight, not from
/// dimming the color a scorer needs to read in direct sun.
class _ScoreboardCard extends StatelessWidget {
  const _ScoreboardCard({
    required this.totalRuns,
    required this.wickets,
    required this.overs,
    required this.extras,
    required this.currentRunRate,
    required this.requiredRunRate,
    required this.partnershipRuns,
    required this.partnershipBalls,
  });

  final int totalRuns;
  final int wickets;
  final String overs;
  final int extras;
  final double currentRunRate;
  final double? requiredRunRate;
  final int partnershipRuns;
  final int partnershipBalls;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Clips the top accent below to the card's own corners instead of
      // letting its square edges poke past them.
      borderRadius: 16.radius,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          border: Border.all(color: context.colorScheme.outline),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Column(
                children: [
                  CricketText(
                    text: '$totalRuns/$wickets',
                    // `displayMedium` isn't one of the styles this app's
                    // TextTheme overrides (see `CustomTextTheme`), so it
                    // falls back to GoogleFonts' un-themed default color — a
                    // near-black that's all but invisible on the dark card.
                    // Explicit `onSurface` here, same as everything else on
                    // this screen.
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  6.h,
                  CricketText(
                    text:
                        '${TranslationKeys.overs.tr}: $overs   ·   '
                        '${TranslationKeys.extras.tr}: $extras',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  10.h,
                  RateStatsLine(
                    currentRunRate: currentRunRate,
                    requiredRunRate: requiredRunRate,
                    partnershipRuns: partnershipRuns,
                    partnershipBalls: partnershipBalls,
                    highContrast: true,
                  ),
                ],
              ),
            ),
            // The one decorative touch on this screen: a quiet top accent
            // instead of a plain flat card, fading out rather than running
            // edge to edge so it reads as a highlight, not a bar.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colorScheme.primary,
                      context.colorScheme.primary.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The app bar's undo control. Was icon-only behind a hover/long-press
/// tooltip; undo is reached for constantly under real match pressure, so the
/// label is permanent now instead of something a scorer has to already know.
class _UndoAction extends StatelessWidget {
  const _UndoAction({
    required this.canUndo,
    required this.isUndoing,
    required this.onPressed,
  });

  final bool canUndo;
  final bool isUndoing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = canUndo
        ? context.colorScheme.onSurface
        : context.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: context.colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: canUndo ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUndoing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                else
                  Icon(LucideIcons.undo2, size: 16, color: fg),
                6.w,
                CricketText(
                  text: TranslationKeys.undoLastBall.tr,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One extras toggle. Sized and shaped to match [_RunDialKey]'s hit-area
/// band rather than a Material `FilterChip`'s ~32px: a wrong tap here changes
/// the score exactly like a wrong tap on a run key does, so it shouldn't
/// read as the smaller, secondary control.
class _ModifierKey extends StatelessWidget {
  const _ModifierKey({
    required this.label,
    required this.isArmed,
    required this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final bool isArmed;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isArmed) {
      // Solid, opaque fill rather than a translucent tint — the same reason
      // hazard signage is solid ink on solid color: a low-opacity tint is
      // exactly what glare erases first. Ink flips per theme brightness
      // because `statusWarning` itself flips from a light amber (dark theme)
      // to a dark amber (light theme) — one ink color could not read on both.
      final warningInk = context.isDark
          ? const Color(0xFF1A1408)
          : Colors.white;

      return _ModifierKeySurface(
        color: context.colors.statusWarning,
        onTap: onTap,
        child: CricketText(
          text: label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: context.textTheme.labelSmall?.copyWith(
            color: warningInk,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return _ModifierKeySurface(
      // `chipBackground` rather than `surfaceContainerHighest`: this is the
      // same bg/outline pairing this app's own `ChipThemeData` already uses,
      // and reads as a deliberately filled key instead of a barely-there tint.
      color: context.colors.chipBackground,
      borderColor: context.colorScheme.outline,
      onTap: onTap,
      child: CricketText(
        text: label,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: context.textTheme.labelSmall?.copyWith(
          color: isDisabled
              ? context.colorScheme.onSurfaceVariant
              : context.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ModifierKeySurface extends StatelessWidget {
  const _ModifierKeySurface({
    required this.color,
    required this.onTap,
    required this.child,
    this.borderColor,
  });

  final Color color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: 16.radius,
      child: InkWell(
        borderRadius: 16.radius,
        onTap: onTap,
        child: Container(
          height: 68,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: 16.radius,
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Wide / No Ball / Bye / Leg Bye, matched in height to the run dial below.
/// Deliberately **not** gated on `canScore`, matching the pre-redesign
/// behaviour exactly: only [isRunsFromDisabled] (a wide already armed) turns
/// Bye/Leg Bye off.
class _ModifierRow extends StatelessWidget {
  const _ModifierRow({
    required this.selectedFault,
    required this.selectedRunsFrom,
    required this.isRunsFromDisabled,
    required this.onToggleFault,
    required this.onToggleRunsFrom,
  });

  final String? selectedFault;
  final String? selectedRunsFrom;
  final bool isRunsFromDisabled;
  final ValueChanged<String> onToggleFault;
  final ValueChanged<String> onToggleRunsFrom;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModifierKey(
            label: TranslationKeys.wide.tr,
            isArmed: selectedFault == ExtraType.wide,
            onTap: () => onToggleFault(ExtraType.wide),
          ),
        ),
        8.w,
        Expanded(
          child: _ModifierKey(
            label: TranslationKeys.noBall.tr,
            isArmed: selectedFault == ExtraType.noBall,
            onTap: () => onToggleFault(ExtraType.noBall),
          ),
        ),
        8.w,
        Expanded(
          child: _ModifierKey(
            label: TranslationKeys.bye.tr,
            isArmed: selectedRunsFrom == RunsFrom.bye,
            isDisabled: isRunsFromDisabled,
            onTap: isRunsFromDisabled
                ? null
                : () => onToggleRunsFrom(RunsFrom.bye),
          ),
        ),
        8.w,
        Expanded(
          child: _ModifierKey(
            label: TranslationKeys.legBye.tr,
            isArmed: selectedRunsFrom == RunsFrom.legBye,
            isDisabled: isRunsFromDisabled,
            onTap: isRunsFromDisabled
                ? null
                : () => onToggleRunsFrom(RunsFrom.legBye),
          ),
        ),
      ],
    );
  }
}

/// One run key. Circular so it reads as a different control family from the
/// modifier row above it — shape, not just color, is what muscle memory
/// tells apart under pressure. 4 and 6 carry a quiet boundary ring so a six
/// registers at a glance instead of a beat later on the scoreboard.
class _RunDialKey extends StatelessWidget {
  const _RunDialKey({
    required this.runs,
    required this.isBoundary,
    required this.onTap,
  });

  final int runs;
  final bool isBoundary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final ringColor = isBoundary && isEnabled
        ? context.colors.statusSuccess
        : context.colorScheme.outline;

    return Material(
      // Same reasoning as the modifier keys: `chipBackground` gives a
      // visibly filled key instead of `surfaceContainerHighest`'s subtler,
      // barely-distinct-from-background tint.
      color: context.colors.chipBackground,
      shape: CircleBorder(
        side: BorderSide(color: ringColor, width: isBoundary ? 2 : 1),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: CricketText(
            text: '$runs',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: !isEnabled
                  ? context.colorScheme.onSurfaceVariant
                  : (isBoundary
                        ? context.colors.statusSuccess
                        : context.colorScheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}

/// 0/1/2/3/4/6 as a 3×2 dial instead of a `Wrap` of squares — fixed columns
/// keep every key's size and position stable regardless of screen width,
/// which a `Wrap` reflow cannot guarantee.
class _RunDialPad extends StatelessWidget {
  const _RunDialPad({required this.canScore, required this.onScore});

  final bool canScore;
  final ValueChanged<int> onScore;

  static const _runs = [0, 1, 2, 3, 4, 6];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        for (final runs in _runs)
          _RunDialKey(
            runs: runs,
            isBoundary: runs == 4 || runs == 6,
            onTap: canScore ? () => onScore(runs) : null,
          ),
      ],
    );
  }
}

/// The wicket control. Full-width and pill-shaped — not just wider than a
/// run key, but a different silhouette entirely — and the only control on
/// this screen still allowed to be primary red now that the run keys have
/// moved to a neutral tone.
class _OutButton extends StatelessWidget {
  const _OutButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: isEnabled
            ? context.colors.statusDanger
            : context.colorScheme.surfaceContainerHighest,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Center(
            child: CricketText(
              text: TranslationKeys.out.tr,
              style: context.textTheme.titleMedium?.copyWith(
                color: isEnabled
                    ? Colors.white
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sits over the run dial + OUT (never the modifier row, which stays
/// tappable in this state exactly as it did before the redesign) so a
/// scorer sees *why* those two are unresponsive instead of just finding
/// them dead under a thumb.
class _BlockScrim extends StatelessWidget {
  const _BlockScrim({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: 16.radius,
        ),
        child: Center(
          child: Padding(
            padding: 24.p,
            child: CricketText(
              text: message,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The fixed, non-scrolling bottom of the screen: modifier row, run dial,
/// OUT. Pinned outside the scrolling info area above it so these targets
/// never move — not when the sync banner appears, not when the bowler
/// prompt does. Everything here reads plain values and callbacks, per the
/// private-presentational-sub-widget convention; the single [Obx] wrapping
/// it at the call site is what makes it reactive.
class _ActionZone extends StatelessWidget {
  const _ActionZone({
    required this.selectedFault,
    required this.selectedRunsFrom,
    required this.isRunsFromDisabled,
    required this.canScore,
    required this.isInningsComplete,
    required this.needsBowler,
    required this.onToggleFault,
    required this.onToggleRunsFrom,
    required this.onScoreRuns,
    required this.onWicket,
  });

  final String? selectedFault;
  final String? selectedRunsFrom;
  final bool isRunsFromDisabled;
  final bool canScore;
  final bool isInningsComplete;
  final bool needsBowler;
  final ValueChanged<String> onToggleFault;
  final ValueChanged<String> onToggleRunsFrom;
  final ValueChanged<int> onScoreRuns;
  final VoidCallback onWicket;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(top: BorderSide(color: context.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            children: [
              _ModifierRow(
                selectedFault: selectedFault,
                selectedRunsFrom: selectedRunsFrom,
                isRunsFromDisabled: isRunsFromDisabled,
                onToggleFault: onToggleFault,
                onToggleRunsFrom: onToggleRunsFrom,
              ),
              16.h,
              Stack(
                children: [
                  Column(
                    children: [
                      _RunDialPad(canScore: canScore, onScore: onScoreRuns),
                      14.h,
                      _OutButton(onTap: canScore ? onWicket : null),
                    ],
                  ),
                  if (isInningsComplete)
                    _BlockScrim(
                      message: TranslationKeys.allOut.tr,
                      color: context.colors.statusDanger,
                    )
                  else if (needsBowler)
                    _BlockScrim(
                      message:
                          '${TranslationKeys.endOfOver.tr} — '
                          '${TranslationKeys.chooseBowler.tr}',
                      color: context.colors.statusWarning,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            () => _UndoAction(
              canUndo: controller.canUndo,
              isUndoing: controller.isUndoing.value,
              onPressed: () => unawaited(controller.undoLastBall()),
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
      // The scrolling info area (banner, score, strike, bowler) sits above a
      // fixed, never-scrolling action zone — not one long `SingleChildScrollView`
      // like before. That split is the point: the run dial and OUT now hold
      // a constant position on screen no matter what appears in the banner
      // above them.
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                children: [
                  // Topmost, above even the team names — "is my data safe" should
                  // never require scrolling past the score to find out.
                  Obx(() {
                    final pendingCount =
                        controller.offlineSyncService.pendingCount.value;
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
                          onRetry: () =>
                              unawaited(controller.handleSyncBannerTap()),
                        ),
                        12.h,
                      ],
                    );
                  }),
                  CricketText(
                    text:
                        '${controller.match.teamA.name} vs ${controller.match.teamB.name}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                  16.h,
                  Obx(
                    () => _ScoreboardCard(
                      totalRuns: controller.totalRuns.value,
                      wickets: controller.wickets.value,
                      overs: controller.overs.value,
                      extras: controller.extrasTotal.value,
                      currentRunRate: controller.currentRunRate.value,
                      requiredRunRate: controller.requiredRunRate.value,
                      partnershipRuns: controller.partnershipRuns.value,
                      partnershipBalls: controller.partnershipBalls.value,
                    ),
                  ),
                  16.h,
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
                ],
              ),
            ),
          ),
          Obx(
            () => _ActionZone(
              selectedFault: controller.selectedFault.value,
              selectedRunsFrom: controller.selectedRunsFrom.value,
              isRunsFromDisabled: controller.isRunsFromDisabled,
              canScore: controller.canScore,
              isInningsComplete: controller.isInningsComplete.value,
              needsBowler: controller.needsBowler.value,
              onToggleFault: controller.toggleFault,
              onToggleRunsFrom: controller.toggleRunsFrom,
              onScoreRuns: controller.scoreRuns,
              onWicket: () => unawaited(controller.promptForWicket()),
            ),
          ),
        ],
      ),
    );
  }
}
