import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/utils/career_stats_format.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Batting + bowling leaderboards for one tournament — reached from
/// `TournamentDetailScreen`'s "Leaderboards" action, shown for every
/// tournament format (unlike Standings, which hides for knockout). Reuses
/// that screen's own tag-registered `TournamentDetailController`, fetched
/// lazily via `loadLeaderboards()` only when this screen actually opens.
class TournamentLeaderboardsScreen extends StatefulWidget {
  const TournamentLeaderboardsScreen({super.key});

  @override
  State<TournamentLeaderboardsScreen> createState() =>
      _TournamentLeaderboardsScreenState();
}

class _TournamentLeaderboardsScreenState
    extends State<TournamentLeaderboardsScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  @override
  void initState() {
    super.initState();
    controller.loadLeaderboards();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: TranslationKeys.leaderboards.tr,
          bottom: TabBar(
            tabs: [
              Tab(text: TranslationKeys.battingFigures.tr),
              Tab(text: TranslationKeys.bowlingFigures.tr),
            ],
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            final loading = controller.leaderboardsLoading.value;
            final error = controller.leaderboardsError.value;
            final batting = controller.battingLeaderboard;
            final bowling = controller.bowlingLeaderboard;

            if (loading && batting.isEmpty && bowling.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (error != null && batting.isEmpty && bowling.isEmpty) {
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
                      CricketText(text: error, textAlign: TextAlign.center),
                      24.h,
                      CricketButton(
                        buttonText: TranslationKeys.retry.tr,
                        onPressed: controller.loadLeaderboards,
                        width: 160,
                      ),
                    ],
                  ),
                ),
              );
            }

            return TabBarView(
              children: [
                _BattingTable(rows: batting, onRefresh: controller.loadLeaderboards),
                _BowlingTable(rows: bowling, onRefresh: controller.loadLeaderboards),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _BattingTable extends StatelessWidget {
  const _BattingTable({required this.rows, required this.onRefresh});

  final List<BattingLeaderboardRowRes> rows;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: CricketText(
          text: TranslationKeys.noLeaderboardsYet.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: 16.p,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            columns: [
              DataColumn(label: CricketText(text: TranslationKeys.rankShort.tr)),
              DataColumn(label: CricketText(text: TranslationKeys.player.tr)),
              DataColumn(label: CricketText(text: TranslationKeys.innings.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.runsShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.average.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.strikeRateShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.highScore.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.foursShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.sixesShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.fifties.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.hundreds.tr), numeric: true),
            ],
            rows: [
              for (var i = 0; i < rows.length; i += 1)
                DataRow(
                  cells: [
                    DataCell(CricketText(text: '${i + 1}')),
                    DataCell(CricketText(text: rows[i].playerName)),
                    DataCell(CricketText(text: '${rows[i].inningsBatted}')),
                    DataCell(
                      CricketText(
                        text: '${rows[i].runs}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(CricketText(text: formatAverage(rows[i].average))),
                    DataCell(CricketText(text: rows[i].strikeRate.toStringAsFixed(2))),
                    DataCell(CricketText(text: formatHighScore(rows[i].highScore))),
                    DataCell(CricketText(text: '${rows[i].fours}')),
                    DataCell(CricketText(text: '${rows[i].sixes}')),
                    DataCell(CricketText(text: '${rows[i].fifties}')),
                    DataCell(CricketText(text: '${rows[i].hundreds}')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BowlingTable extends StatelessWidget {
  const _BowlingTable({required this.rows, required this.onRefresh});

  final List<BowlingLeaderboardRowRes> rows;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: CricketText(
          text: TranslationKeys.noLeaderboardsYet.tr,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: 16.p,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            columns: [
              DataColumn(label: CricketText(text: TranslationKeys.rankShort.tr)),
              DataColumn(label: CricketText(text: TranslationKeys.player.tr)),
              DataColumn(label: CricketText(text: TranslationKeys.innings.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.oversShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.runsShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.wicketsShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.economyShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.maidensShort.tr), numeric: true),
              DataColumn(label: CricketText(text: TranslationKeys.bestBowling.tr), numeric: true),
            ],
            rows: [
              for (var i = 0; i < rows.length; i += 1)
                DataRow(
                  cells: [
                    DataCell(CricketText(text: '${i + 1}')),
                    DataCell(CricketText(text: rows[i].playerName)),
                    DataCell(CricketText(text: '${rows[i].inningsBowled}')),
                    DataCell(CricketText(text: formatOversFromLegalDeliveries(rows[i].legalDeliveries))),
                    DataCell(CricketText(text: '${rows[i].runsConceded}')),
                    DataCell(
                      CricketText(
                        text: '${rows[i].wickets}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(CricketText(text: rows[i].economy.toStringAsFixed(2))),
                    DataCell(CricketText(text: '${rows[i].maidens}')),
                    DataCell(CricketText(text: formatBestBowling(rows[i].bestBowling))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
