import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/player_stats_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/utils/career_stats_format.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/edit_player_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Map<String, String> _roleLabels = <String, String>{
  'batsman': TranslationKeys.roleBatsman,
  'bowler': TranslationKeys.roleBowler,
  'allrounder': TranslationKeys.roleAllrounder,
  'wicketkeeper': TranslationKeys.roleWicketkeeper,
  'unknown': TranslationKeys.roleUnknown,
};

const Map<String, String> _battingStyleLabels = <String, String>{
  'right_handed': TranslationKeys.rightHanded,
  'left_handed': TranslationKeys.leftHanded,
};

const Map<String, String> _bowlingStyleLabels = <String, String>{
  'right_arm_pace': TranslationKeys.rightArmPace,
  'left_arm_pace': TranslationKeys.leftArmPace,
  'right_arm_spin': TranslationKeys.rightArmSpin,
  'left_arm_spin': TranslationKeys.leftArmSpin,
};

/// One player's totals across every completed match their scorer has
/// recorded — reached by tapping a name in a completed match's scorecard
/// (`ResultScreen`'s batting/bowling tables). Not a per-innings breakdown
/// (that's `ResultScreen`'s own job); this is scalar career totals, so it
/// follows `_InningsSummary`'s label/value-row idiom rather than
/// `ResultScreen`'s `DataTable`.
class PlayerStatsScreen extends GetView<PlayerStatsController> {
  const PlayerStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: TranslationKeys.playerStats.tr,
        actions: [
          Obx(() {
            final data = controller.careerStats.value;
            if (data == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showEditPlayerProfileSheet(
                controller: controller,
                stats: data,
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.loadError.value;
          if (error != null) {
            return _ErrorState(message: error, onRetry: controller.retry);
          }

          final data = controller.careerStats.value;
          if (data == null) return const SizedBox.shrink();

          return _CareerStatsView(data: data);
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
              Icons.bar_chart_outlined,
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

class _CareerStatsView extends StatelessWidget {
  const _CareerStatsView({required this.data});

  final CareerStatsRes data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: 24.p,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CricketText(
            text: data.playerName,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          8.h,
          CricketText(
            text: '${data.matchesPlayed} ${TranslationKeys.matchesPlayed.tr}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          24.h,
          _StatSection(
            title: TranslationKeys.profile.tr,
            rows: [
              _StatRowData(TranslationKeys.role.tr, _roleLabels[data.role]!.tr),
              if (data.jerseyNumber != null)
                _StatRowData(TranslationKeys.jerseyNumber.tr, '${data.jerseyNumber}'),
              if (data.battingStyle != null)
                _StatRowData(TranslationKeys.battingStyle.tr, _battingStyleLabels[data.battingStyle]!.tr),
              if (data.bowlingStyle != null)
                _StatRowData(TranslationKeys.bowlingStyle.tr, _bowlingStyleLabels[data.bowlingStyle]!.tr),
            ],
          ),
          if (data.bio != null && data.bio!.isNotEmpty) ...[
            8.h,
            CricketText(
              text: data.bio!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          24.h,
          _StatSection(
            title: TranslationKeys.battingFigures.tr,
            rows: [
              _StatRowData(
                TranslationKeys.innings.tr,
                '${data.batting.inningsBatted}',
              ),
              _StatRowData(
                TranslationKeys.runsShort.tr,
                '${data.batting.runs}',
              ),
              _StatRowData(
                TranslationKeys.average.tr,
                formatAverage(data.batting.average),
              ),
              _StatRowData(
                TranslationKeys.strikeRateShort.tr,
                data.batting.strikeRate.toStringAsFixed(2),
              ),
              _StatRowData(
                TranslationKeys.highScore.tr,
                formatHighScore(data.batting.highScore),
              ),
              _StatRowData(
                TranslationKeys.fifties.tr,
                '${data.batting.fifties}',
              ),
              _StatRowData(
                TranslationKeys.hundreds.tr,
                '${data.batting.hundreds}',
              ),
              _StatRowData(
                TranslationKeys.foursShort.tr,
                '${data.batting.fours}',
              ),
              _StatRowData(
                TranslationKeys.sixesShort.tr,
                '${data.batting.sixes}',
              ),
            ],
          ),
          24.h,
          _StatSection(
            title: TranslationKeys.bowlingFigures.tr,
            rows: [
              _StatRowData(
                TranslationKeys.innings.tr,
                '${data.bowling.inningsBowled}',
              ),
              _StatRowData(
                TranslationKeys.oversShort.tr,
                formatOversFromLegalDeliveries(data.bowling.legalDeliveries),
              ),
              _StatRowData(
                TranslationKeys.runsShort.tr,
                '${data.bowling.runsConceded}',
              ),
              _StatRowData(
                TranslationKeys.wicketsShort.tr,
                '${data.bowling.wickets}',
              ),
              _StatRowData(
                TranslationKeys.economyShort.tr,
                data.bowling.economy.toStringAsFixed(2),
              ),
              _StatRowData(
                TranslationKeys.maidensShort.tr,
                '${data.bowling.maidens}',
              ),
              _StatRowData(
                TranslationKeys.bestBowling.tr,
                formatBestBowling(data.bowling.bestBowling),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRowData {
  const _StatRowData(this.label, this.value);

  final String label;
  final String value;
}

class _StatSection extends StatelessWidget {
  const _StatSection({required this.title, required this.rows});

  final String title;
  final List<_StatRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CricketText(
          text: title,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        12.h,
        for (final row in rows) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CricketText(text: row.label, style: context.textTheme.bodyMedium),
              CricketText(text: row.value, style: context.textTheme.titleSmall),
            ],
          ),
          8.h,
        ],
      ],
    );
  }
}
