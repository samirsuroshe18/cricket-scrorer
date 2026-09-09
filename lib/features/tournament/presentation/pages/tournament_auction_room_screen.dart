import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/auction_room_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/auction_countdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TournamentAuctionRoomScreen extends StatefulWidget {
  const TournamentAuctionRoomScreen({super.key});

  @override
  State<TournamentAuctionRoomScreen> createState() => _TournamentAuctionRoomScreenState();
}

class _TournamentAuctionRoomScreenState extends State<TournamentAuctionRoomScreen> {
  late final AuctionRoomController _controller;
  late final bool _isOwner;
  Worker? _actionErrorWorker;

  @override
  void initState() {
    super.initState();
    final tournamentId = Get.parameters['tournamentId']?.trim() ?? '';
    _controller = Get.find<AuctionRoomController>(tag: tournamentId);
    final args = Get.arguments;
    _isOwner = args is Map && args['isOwner'] == true;

    // Rejections surface via CricketSnackbar with the server's own message,
    // exactly once per rejection — never silently swallowed. A once()
    // worker rather than an ever() listener inside build() avoids re-firing
    // the same snackbar on unrelated rebuilds.
    _actionErrorWorker = ever<String?>(_controller.actionError, (message) {
      if (message != null) {
        CricketSnackbar.showErrorMessage(message);
      }
    });
  }

  @override
  void dispose() {
    _actionErrorWorker?.dispose();
    super.dispose();
  }

  Future<void> _runOwnerAction(Future<String?> Function() action) async {
    final error = await action();
    if (error != null) {
      CricketSnackbar.showErrorMessage(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.liveAuction.tr)),
      body: Obx(() {
        final status = _controller.sessionStatus.value;

        if (status == null) {
          return Center(
            child: _isOwner
                ? ElevatedButton(
                    onPressed: () => _runOwnerAction(_controller.startAuction),
                    child: CricketText(text: TranslationKeys.startAuction.tr),
                  )
                : CricketText(text: TranslationKeys.auctionNotStarted.tr),
          );
        }

        if (status == 'completed') {
          return Center(child: CricketText(text: TranslationKeys.auctionCompleted.tr));
        }

        final lot = _controller.currentLot.value;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_controller.connectionError.value != null)
                CricketText(
                  text: _controller.connectionError.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Expanded(
                child: lot == null
                    ? Center(
                        child: _isOwner
                            ? ElevatedButton(
                                onPressed: () => _runOwnerAction(_controller.nextLot),
                                child: CricketText(text: TranslationKeys.nextPlayer.tr),
                              )
                            : CricketText(text: TranslationKeys.waitingForNextPlayer.tr),
                      )
                    : _LotCard(lot: lot, onBid: _controller.placeBid, isPaused: status == 'paused'),
              ),
              const SizedBox(height: 16),
              CricketText(text: TranslationKeys.budgets.tr, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _controller.budgets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _BudgetChip(budget: _controller.budgets[index]),
                ),
              ),
              if (lot != null) ...[
                const SizedBox(height: 16),
                CricketText(text: TranslationKeys.bidHistory.tr, style: Theme.of(context).textTheme.titleSmall),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _controller.bidHistory.length,
                    itemBuilder: (context, index) {
                      final event = _controller.bidHistory[_controller.bidHistory.length - 1 - index];
                      return ListTile(
                        dense: true,
                        title: CricketText(text: event.bidderTeamName),
                        trailing: CricketText(text: '₹${event.amount}'),
                      );
                    },
                  ),
                ),
              ],
              if (_isOwner) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (status == 'active')
                      TextButton(
                        onPressed: () => _runOwnerAction(_controller.pauseAuction),
                        child: CricketText(text: TranslationKeys.pauseAuction.tr),
                      ),
                    if (status == 'paused')
                      TextButton(
                        onPressed: () => _runOwnerAction(_controller.resumeAuction),
                        child: CricketText(text: TranslationKeys.resumeAuction.tr),
                      ),
                    if (lot == null && status == 'active')
                      TextButton(
                        onPressed: () => _runOwnerAction(_controller.nextLot),
                        child: CricketText(text: TranslationKeys.nextPlayer.tr),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _LotCard extends StatelessWidget {
  final AuctionLotRes lot;
  final VoidCallback onBid;
  final bool isPaused;

  const _LotCard({required this.lot, required this.onBid, required this.isPaused});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CricketText(text: lot.playerName ?? '', style: Theme.of(context).textTheme.headlineSmall),
            if (lot.playerRole != null) CricketText(text: lot.playerRole!),
            const SizedBox(height: 24),
            CricketText(text: '₹${lot.currentBid}', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            AuctionCountdown(endsAt: isPaused ? null : lot.endsAt),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isPaused ? null : onBid,
              child: CricketText(text: TranslationKeys.placeBid.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetChip extends StatelessWidget {
  final AuctionBudgetRes budget;

  const _BudgetChip({required this.budget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CricketText(text: budget.teamName, style: Theme.of(context).textTheme.labelMedium),
          CricketText(text: '₹${budget.remaining}'),
        ],
      ),
    );
  }
}
