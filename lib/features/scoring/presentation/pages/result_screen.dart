import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/result_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_result_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reachable two ways — see [AppRoutes.matchResult] — and identical either
/// way: [ResultController] always loads from `GET .../scorecard`, so this
/// screen has no branch for "how did I get here."
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
          MatchResultBanner(result: data.result, nameFor: data.nameFor),
          24.h,
          for (final innings in data.innings) ...[
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
                      CricketText(
                        text: line.isNotOut
                            ? line.playerName
                            : '${line.playerName} '
                                  '(${_dismissalLabel(line.dismissalType)})',
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
                    DataCell(CricketText(text: line.playerName)),
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
