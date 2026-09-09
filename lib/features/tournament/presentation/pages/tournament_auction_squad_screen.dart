import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_report_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The tournament's one auction, live-reflecting whatever's resolved so
/// far — no "completed" gate, and no session picker (a tournament has at
/// most one `AuctionSession` ever). Reuses the tag-registered
/// `TournamentDetailController`, same lazy-load-once-per-visit pattern as
/// standings/leaderboards/pool/auction-setup.
class TournamentAuctionSquadScreen extends StatefulWidget {
  const TournamentAuctionSquadScreen({super.key});

  @override
  State<TournamentAuctionSquadScreen> createState() =>
      _TournamentAuctionSquadScreenState();
}

class _TournamentAuctionSquadScreenState
    extends State<TournamentAuctionSquadScreen> {
  late final String _tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
  late final TournamentDetailController controller =
      Get.find<TournamentDetailController>(tag: _tournamentId);

  @override
  void initState() {
    super.initState();
    controller.loadAuctionSquad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.auctionSquad.tr),
      body: SafeArea(
        child: Obx(() {
          final loading = controller.auctionSquadLoading.value;
          final error = controller.auctionSquadError.value;
          final notStarted = controller.auctionSquadNotStarted.value;
          final squad = controller.auctionSquad.value;

          if (loading && squad == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notStarted) {
            return Center(
              child: CricketText(
                text: TranslationKeys.auctionNotStarted.tr,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          if (error != null && squad == null) {
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
                      onPressed: controller.loadAuctionSquad,
                      width: 160,
                    ),
                  ],
                ),
              ),
            );
          }
          if (squad == null) return const SizedBox.shrink();

          final noSalesYet = squad.teams.every((t) => t.players.isEmpty) && squad.unsold.isEmpty;
          if (noSalesYet) {
            return Center(
              child: CricketText(
                text: TranslationKeys.noSquadYet.tr,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadAuctionSquad,
            child: ListView(
              padding: 16.p,
              children: [
                for (final team in squad.teams) ...[
                  _TeamSquadCard(team: team),
                  12.h,
                ],
                if (squad.unsold.isNotEmpty) ...[
                  CricketText(
                    text: TranslationKeys.unsoldPlayers.tr,
                    style: context.textTheme.titleSmall,
                  ),
                  8.h,
                  for (final player in squad.unsold) ...[
                    _UnsoldPlayerTile(player: player),
                    8.h,
                  ],
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TeamSquadCard extends StatelessWidget {
  const _TeamSquadCard({required this.team});

  final AuctionSquadTeamRes team;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.p,
      decoration: BoxDecoration(
        color: context.colors.chipBackground,
        borderRadius: 12.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: team.teamName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CricketText(
                      text: team.ownerName,
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
                  CricketText(
                    text: '${TranslationKeys.budget.tr}: ₹${team.budget}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  CricketText(
                    text: '${TranslationKeys.spent.tr}: ₹${team.spent}',
                    style: context.textTheme.bodySmall,
                  ),
                  CricketText(
                    text: '${TranslationKeys.remaining.tr}: ₹${team.remaining}',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (team.players.isNotEmpty) ...[
            8.h,
            const Divider(height: 1),
            8.h,
            for (final player in team.players)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: CricketText(text: player.playerName),
                    ),
                    CricketText(
                      text: '₹${player.soldPrice}',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _UnsoldPlayerTile extends StatelessWidget {
  const _UnsoldPlayerTile({required this.player});

  final AuctionUnsoldPlayerRes player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.p,
      decoration: BoxDecoration(
        color: context.colors.chipBackground.withValues(alpha: 0.4),
        borderRadius: 12.radius,
      ),
      child: Row(
        children: [
          Expanded(child: CricketText(text: player.playerName)),
          CricketText(
            text: '₹${player.basePrice}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
