import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The points table for a round_robin/league tournament — reached from
/// `TournamentDetailScreen`'s "Standings" action. Reuses that screen's own
/// tag-registered `TournamentDetailController` rather than a controller of
/// its own: standings are one more piece of tournament data, fetched lazily
/// (only when this screen actually opens) via `loadStandings()`.
class TournamentStandingsScreen extends StatefulWidget {
  const TournamentStandingsScreen({super.key});

  @override
  State<TournamentStandingsScreen> createState() =>
      _TournamentStandingsScreenState();
}

class _TournamentStandingsScreenState extends State<TournamentStandingsScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  @override
  void initState() {
    super.initState();
    controller.loadStandings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.standings.tr),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.standingsLoading.value;
          final error = controller.standingsError.value;
          final rows = controller.standings;

          if (loading && rows.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && rows.isEmpty) {
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
                      onPressed: controller.loadStandings,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }
          if (rows.isEmpty) {
            return Center(
              child: CricketText(
                text: TranslationKeys.noStandingsYet.tr,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadStandings,
            child: SingleChildScrollView(
              padding: 16.p,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  columns: [
                    DataColumn(label: CricketText(text: TranslationKeys.rankShort.tr)),
                    DataColumn(label: CricketText(text: TranslationKeys.teams.tr)),
                    DataColumn(label: CricketText(text: TranslationKeys.playedShort.tr), numeric: true),
                    DataColumn(label: CricketText(text: TranslationKeys.wonShort.tr), numeric: true),
                    DataColumn(label: CricketText(text: TranslationKeys.lostShort.tr), numeric: true),
                    DataColumn(label: CricketText(text: TranslationKeys.tiedShort.tr), numeric: true),
                    DataColumn(label: CricketText(text: TranslationKeys.noResultShort.tr), numeric: true),
                    DataColumn(label: CricketText(text: TranslationKeys.pointsShort.tr), numeric: true),
                    DataColumn(label: CricketText(text: TranslationKeys.nrrShort.tr), numeric: true),
                  ],
                  rows: [
                    for (var i = 0; i < rows.length; i += 1)
                      DataRow(
                        cells: [
                          DataCell(CricketText(text: '${i + 1}')),
                          DataCell(CricketText(text: rows[i].teamName)),
                          DataCell(CricketText(text: '${rows[i].played}')),
                          DataCell(CricketText(text: '${rows[i].won}')),
                          DataCell(CricketText(text: '${rows[i].lost}')),
                          DataCell(CricketText(text: '${rows[i].tied}')),
                          DataCell(CricketText(text: '${rows[i].noResult}')),
                          DataCell(
                            CricketText(
                              text: '${rows[i].points}',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(CricketText(text: _formatNrr(rows[i].nrr))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// `+0.850` / `-1.000` / `0.000` — a signed 3-decimal figure, matching how
/// net run rate is conventionally printed on a points table.
String _formatNrr(double nrr) {
  final sign = nrr > 0 ? '+' : '';
  return '$sign${nrr.toStringAsFixed(3)}';
}
