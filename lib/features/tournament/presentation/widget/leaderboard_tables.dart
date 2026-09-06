import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/utils/career_stats_format.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The batting/bowling leaderboard `DataTable`s — shared by
/// `TournamentLeaderboardsScreen` and `OrganizationLeaderboardsScreen` so
/// neither copy of this rendering can drift from the other. Both screens'
/// controllers already return identically-shaped
/// `BattingLeaderboardRowRes`/`BowlingLeaderboardRowRes` lists; only the
/// query behind them differs (one tournament vs. every tournament an org
/// runs).
class BattingLeaderboardTable extends StatelessWidget {
  const BattingLeaderboardTable({
    super.key,
    required this.rows,
    required this.onRefresh,
  });

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

class BowlingLeaderboardTable extends StatelessWidget {
  const BowlingLeaderboardTable({
    super.key,
    required this.rows,
    required this.onRefresh,
  });

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
