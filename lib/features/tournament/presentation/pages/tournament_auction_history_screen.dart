import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_report_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/auction_outcome_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The resolution-summary log for the tournament's one auction — who got
/// bought, for how much, in resolution order. This is the data source
/// Phase 5's shareable "SOLD" card will eventually read from; no per-lot
/// bid trail here, just the outcome.
class TournamentAuctionHistoryScreen extends StatefulWidget {
  const TournamentAuctionHistoryScreen({super.key});

  @override
  State<TournamentAuctionHistoryScreen> createState() =>
      _TournamentAuctionHistoryScreenState();
}

class _TournamentAuctionHistoryScreenState
    extends State<TournamentAuctionHistoryScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  @override
  void initState() {
    super.initState();
    controller.loadAuctionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.auctionHistory.tr),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.auctionHistoryLoading.value;
          final error = controller.auctionHistoryError.value;
          final history = controller.auctionHistory.value;

          if (loading && history == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null && history == null) {
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
                      onPressed: controller.loadAuctionHistory,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }
          if (history == null) return const SizedBox.shrink();
          if (history.entries.isEmpty) {
            return Center(
              child: CricketText(
                text: TranslationKeys.noAuctionHistoryYet.tr,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadAuctionHistory,
            child: ListView.separated(
              padding: 16.p,
              itemCount: history.entries.length,
              separatorBuilder: (_, _) => 8.h,
              itemBuilder: (context, index) => _HistoryEntryTile(entry: history.entries[index]),
            ),
          );
        }),
      ),
    );
  }
}

class _HistoryEntryTile extends StatelessWidget {
  const _HistoryEntryTile({required this.entry});

  final AuctionHistoryEntryRes entry;

  @override
  Widget build(BuildContext context) {
    final sold = entry.outcome == 'sold';
    return Container(
      padding: 12.p,
      decoration: BoxDecoration(
        color: context.colors.chipBackground,
        borderRadius: 12.radius,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CricketText(
                  text: entry.playerName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (sold && entry.teamName != null)
                  CricketText(
                    text: entry.teamName!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: auctionOutcomeColor(context, entry.outcome).withValues(alpha: 0.12),
                  borderRadius: 8.radius,
                ),
                child: CricketText(
                  text: auctionOutcomeLabel(entry.outcome),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: auctionOutcomeColor(context, entry.outcome),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              4.h,
              CricketText(
                text: sold ? '₹${entry.soldPrice}' : '₹${entry.basePrice}',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
