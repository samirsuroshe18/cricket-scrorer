import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/leaderboard_tables.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Batting + bowling leaderboards aggregated across every tournament one
/// organization runs — reached from `OrganizationDetailScreen`'s
/// "Leaderboards" action. Reuses that screen's own tag-registered
/// `OrganizationDetailController`, fetched lazily via `loadLeaderboards()`
/// only when this screen actually opens. Renders with the exact same
/// `BattingLeaderboardTable`/`BowlingLeaderboardTable` widgets the
/// tournament-scoped screen uses — only the data behind them differs.
class OrganizationLeaderboardsScreen extends StatefulWidget {
  const OrganizationLeaderboardsScreen({super.key});

  @override
  State<OrganizationLeaderboardsScreen> createState() =>
      _OrganizationLeaderboardsScreenState();
}

class _OrganizationLeaderboardsScreenState
    extends State<OrganizationLeaderboardsScreen> {
  late final String _orgId = Get.parameters['orgId']?.trim() ?? '';
  late final OrganizationDetailController controller =
      Get.find<OrganizationDetailController>(tag: _orgId);

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
                BattingLeaderboardTable(rows: batting, onRefresh: controller.loadLeaderboards),
                BowlingLeaderboardTable(rows: bowling, onRefresh: controller.loadLeaderboards),
              ],
            );
          }),
        ),
      ),
    );
  }
}
