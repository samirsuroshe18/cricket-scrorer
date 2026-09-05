import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/result_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/abandoned_match_banner.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_result_banner.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/sync_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reachable two ways — see [AppRoutes.matchResult] — and mostly identical
/// either way: [ResultController] always loads from `GET .../scorecard`.
/// The one branch is [_ProvisionalResultView] — a match completed while
/// offline, where that GET fails only because there's nothing there yet.
class ResultScreen extends GetView<ResultController> {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.matchResult.tr),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final provisional = controller.provisionalResult.value;
          if (provisional != null) {
            return _ProvisionalResultView(
              result: provisional,
              nameFor: controller.nameFor,
              offlineSyncService: controller.offlineSyncService,
              onRetrySync: controller.retrySync,
            );
          }

          final error = controller.loadError.value;
          if (error != null) {
            return _ErrorState(message: error, onRetry: controller.retry);
          }

          final data = controller.scorecard.value;
          if (data == null) return const SizedBox.shrink();

          return _ResultView(data: data);
        }),
      ),
    );
  }
}

/// The win/margin, computed locally, for a match completed offline — nothing
/// else from the real scorecard (per-batsman/bowler figures) is attempted:
/// that data only ever comes from the server, and pretending otherwise would
/// be a guess dressed up as fact. [SyncStatusBanner] is what makes clear this
/// isn't final; `ResultController`'s own `phase` listener swaps this out for
/// [_ResultView] automatically the moment the real scorecard becomes
/// fetchable, no tap required.
class _ProvisionalResultView extends StatelessWidget {
  const _ProvisionalResultView({
    required this.result,
    required this.nameFor,
    required this.offlineSyncService,
    required this.onRetrySync,
  });

  final MatchResultInfo result;
  final String Function(String sideLabel) nameFor;
  final OfflineSyncService offlineSyncService;
  final Future<void> Function() onRetrySync;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: 24.p,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => SyncStatusBanner(
              pendingCount: offlineSyncService.pendingCount.value,
              phase: offlineSyncService.phase.value,
              lastError: offlineSyncService.lastError.value,
              onRetry: () => unawaited(onRetrySync()),
            ),
          ),
          16.h,
          MatchResultBanner(result: result, nameFor: nameFor),
          16.h,
          CricketText(
            text: TranslationKeys.scorecardPendingSync.tr,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
              Icons.emoji_events_outlined,
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

class _ResultView extends StatelessWidget {
  const _ResultView({required this.data});

  final ScorecardRes data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: 24.p,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CricketText(
            text: '${data.teamA.name ?? '-'} vs ${data.teamB.name ?? '-'}',
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          16.h,
          // `result` is null exactly when the match was abandoned rather
          // than completed — no winner was ever decided, so there is
          // nothing for [MatchResultBanner] to describe.
          if (data.result case final result?)
            MatchResultBanner(result: result, nameFor: data.nameFor)
          else
            const AbandonedMatchBanner(),
          24.h,
          // An abandoned match can have a null innings[1] — the match never
          // reached innings 2. A completed match never has a null entry.
          for (final innings in data.innings)
            if (innings != null) ...[
              _InningsSummary(data: data, innings: innings),
              16.h,
              _InningsScorecard(data: data, innings: innings),
              24.h,
            ],
        ],
      ),
    );
  }
}

class _InningsSummary extends StatelessWidget {
  const _InningsSummary({required this.data, required this.innings});

  final ScorecardRes data;
  final InningsScorecard innings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CricketText(
          text: data.nameFor(innings.battingTeam),
          style: context.textTheme.titleSmall,
        ),
        CricketText(
          text:
              '${innings.totalRuns}/${innings.totalWickets} '
              '(${innings.totalOvers} ${TranslationKeys.overs.tr})',
          style: context.textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _InningsScorecard extends StatelessWidget {
  const _InningsScorecard({required this.data, required this.innings});

  final ScorecardRes data;
  final InningsScorecard innings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CricketText(
          text: TranslationKeys.battingFigures.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        8.h,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            columns: [
              DataColumn(label: CricketText(text: TranslationKeys.batter.tr)),
              DataColumn(
                label: CricketText(text: TranslationKeys.runsShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.ballsShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.foursShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.sixesShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.strikeRateShort.tr),
                numeric: true,
              ),
            ],
            rows: [
              for (final line in innings.battingScores)
                DataRow(
                  cells: [
                    DataCell(
                      GestureDetector(
                        onTap: () => Get.toNamed<dynamic>(
                          AppRoutes.playerStatsPath(line.playerId),
                        ),
                        child: CricketText(
                          text: line.isNotOut
                              ? line.playerName
                              : '${line.playerName} '
                                    '(${_dismissalLabel(line.dismissalType)})',
                        ),
                      ),
                    ),
                    DataCell(CricketText(text: '${line.runs}')),
                    DataCell(CricketText(text: '${line.balls}')),
                    DataCell(CricketText(text: '${line.fours}')),
                    DataCell(CricketText(text: '${line.sixes}')),
                    DataCell(
                      CricketText(text: line.strikeRate.toStringAsFixed(2)),
                    ),
                  ],
                ),
            ],
          ),
        ),
        16.h,
        CricketText(
          text: TranslationKeys.bowlingFigures.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        8.h,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            columns: [
              DataColumn(label: CricketText(text: TranslationKeys.bowler.tr)),
              DataColumn(
                label: CricketText(text: TranslationKeys.oversShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.maidensShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.runsShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.wicketsShort.tr),
                numeric: true,
              ),
              DataColumn(
                label: CricketText(text: TranslationKeys.economyShort.tr),
                numeric: true,
              ),
            ],
            rows: [
              for (final line in innings.bowlingScores)
                DataRow(
                  cells: [
                    DataCell(
                      GestureDetector(
                        onTap: () => Get.toNamed<dynamic>(
                          AppRoutes.playerStatsPath(line.playerId),
                        ),
                        child: CricketText(text: line.playerName),
                      ),
                    ),
                    DataCell(CricketText(text: line.overs)),
                    DataCell(CricketText(text: '${line.maidens}')),
                    DataCell(CricketText(text: '${line.runs}')),
                    DataCell(CricketText(text: '${line.wickets}')),
                    DataCell(
                      CricketText(text: line.economy.toStringAsFixed(2)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Maps a stored `wicketType` back to the same wicket-sheet vocabulary the
  /// scorer tapped in the first place — no separate label set to keep in sync.
  String _dismissalLabel(String? type) {
    switch (type) {
      case 'bowled':
        return TranslationKeys.bowled.tr;
      case 'caught':
        return TranslationKeys.caught.tr;
      case 'lbw':
        return TranslationKeys.lbw.tr;
      case 'run_out':
        return TranslationKeys.runOut.tr;
      case 'stumped':
        return TranslationKeys.stumped.tr;
      case 'hit_wicket':
        return TranslationKeys.hitWicket.tr;
      default:
        return TranslationKeys.notOut.tr;
    }
  }
}
