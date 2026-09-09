import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_event_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/next_auction_lot.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/pause_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resume_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_auction.dart';
import 'package:get/get.dart';

/// The live auction room's state, driven entirely by [TournamentRepository]'s
/// auction streams — unlike [TournamentDetailController]'s lazy-load-once-
/// per-tab pattern, this controller has no `loadX()` to call on open; its
/// state arrives continuously for as long as the room is joined
/// ([watchAuctionState] owns join/leave; see [onClose]).
class AuctionRoomController extends GetxController {
  final String tournamentId;
  final TournamentRepository tournamentRepository;
  final StartAuctionUseCase startAuctionUseCase;
  final PauseAuctionUseCase pauseAuctionUseCase;
  final ResumeAuctionUseCase resumeAuctionUseCase;
  final NextAuctionLotUseCase nextAuctionLotUseCase;

  AuctionRoomController({
    required this.tournamentId,
    required this.tournamentRepository,
    required this.startAuctionUseCase,
    required this.pauseAuctionUseCase,
    required this.resumeAuctionUseCase,
    required this.nextAuctionLotUseCase,
  });

  final sessionStatus = Rxn<String>();
  final currentLot = Rxn<AuctionLotRes>();
  final bidHistory = <AuctionBidEventRes>[].obs;
  final budgets = <AuctionBudgetRes>[].obs;

  /// Set on a socket disconnect/error — never blanks [currentLot] or
  /// [budgets], the same "don't blank what's already on screen" rule
  /// SpectatorController.loadError documents for its own reconnect case.
  final connectionError = Rxn<String>();

  /// Set from `auction:bidRejected` — the screen shows this via
  /// CricketSnackbar.
  final actionError = Rxn<String>();

  StreamSubscription<Either<AuctionStateRes, CricketFailure>>? _stateSub;
  StreamSubscription<AuctionLotRes>? _lotOnBlockSub;
  StreamSubscription<AuctionBidAcceptedRes>? _bidAcceptedSub;
  StreamSubscription<AuctionBidRejectedRes>? _bidRejectedSub;
  StreamSubscription<AuctionLotResolvedRes>? _lotResolvedSub;
  StreamSubscription<void>? _pausedSub;
  StreamSubscription<DateTime?>? _resumedSub;
  StreamSubscription<void>? _sessionCompletedSub;

  @override
  void onInit() {
    super.onInit();

    _stateSub = tournamentRepository.watchAuctionState(tournamentId: tournamentId).listen((either) {
      if (either.isResult) {
        final state = either.result;
        sessionStatus.value = state.sessionStatus;
        currentLot.value = state.lot;
        bidHistory.assignAll(state.bidHistory);
        budgets.assignAll(state.budgets);
        connectionError.value = null;
      } else {
        connectionError.value = either.fallback.message;
      }
    });

    _lotOnBlockSub = tournamentRepository.watchAuctionLotOnBlock(tournamentId: tournamentId).listen((lot) {
      currentLot.value = lot;
      bidHistory.clear();
    });

    _bidAcceptedSub = tournamentRepository.watchAuctionBidAccepted(tournamentId: tournamentId).listen((event) {
      final lot = currentLot.value;
      if (lot != null && lot.lotId == event.lotId) {
        currentLot.value = AuctionLotRes(
          lotId: lot.lotId, playerId: lot.playerId, playerName: lot.playerName, playerRole: lot.playerRole,
          basePrice: lot.basePrice, currentBid: event.amount, endsAt: event.endsAt,
        );
      }
      bidHistory.add(AuctionBidEventRes(
        bidderTeamId: event.bidderTeamId, bidderTeamName: event.bidderTeamName, amount: event.amount, at: DateTime.now(),
      ));
    });

    _bidRejectedSub = tournamentRepository.watchAuctionBidRejected(tournamentId: tournamentId).listen((rejection) {
      // Rx only notifies listeners on an actual value change — setting the
      // same message twice in a row (e.g. two consecutive INSUFFICIENT_
      // BUDGET rejections) would otherwise be silently swallowed the
      // second time, since GetX's equality check sees no change. Clearing
      // first forces every rejection to always produce a real transition,
      // so the snackbar worker in the screen fires every time, never just
      // the first.
      actionError.value = null;
      actionError.value = rejection.message;
    });

    _lotResolvedSub = tournamentRepository.watchAuctionLotResolved(tournamentId: tournamentId).listen((resolved) {
      currentLot.value = null;
      bidHistory.clear();
      // spent/remaining come from the server's own post-charge figures
      // (see AuctionLotResolvedRes's own doc comment) — never recomputed
      // here from the locally-cached budget, which could already be stale.
      if (resolved.outcome == 'sold' && resolved.soldTo != null &&
          resolved.spent != null && resolved.remaining != null) {
        final index = budgets.indexWhere((b) => b.teamId == resolved.soldTo);
        if (index != -1) {
          final b = budgets[index];
          budgets[index] = AuctionBudgetRes(
            teamId: b.teamId, teamName: b.teamName, ownerId: b.ownerId, budget: b.budget,
            spent: resolved.spent!, remaining: resolved.remaining!,
          );
        }
      }
    });

    _pausedSub = tournamentRepository.watchAuctionPaused(tournamentId: tournamentId).listen((_) {
      sessionStatus.value = 'paused';
    });

    _resumedSub = tournamentRepository.watchAuctionResumed(tournamentId: tournamentId).listen((endsAt) {
      sessionStatus.value = 'active';
      final lot = currentLot.value;
      if (lot != null && endsAt != null) {
        currentLot.value = AuctionLotRes(
          lotId: lot.lotId, playerId: lot.playerId, playerName: lot.playerName, playerRole: lot.playerRole,
          basePrice: lot.basePrice, currentBid: lot.currentBid, endsAt: endsAt,
        );
      }
    });

    _sessionCompletedSub = tournamentRepository.watchAuctionSessionCompleted(tournamentId: tournamentId).listen((_) {
      sessionStatus.value = 'completed';
      currentLot.value = null;
    });
  }

  @override
  void onClose() {
    _stateSub?.cancel();
    _lotOnBlockSub?.cancel();
    _bidAcceptedSub?.cancel();
    _bidRejectedSub?.cancel();
    _lotResolvedSub?.cancel();
    _pausedSub?.cancel();
    _resumedSub?.cancel();
    _sessionCompletedSub?.cancel();
    super.onClose();
  }

  void placeBid() {
    final lot = currentLot.value;
    if (lot == null) return;
    tournamentRepository.bidOnAuctionLot(tournamentId: tournamentId, lotId: lot.lotId);
  }

  Future<String?> startAuction() async {
    final response = await startAuctionUseCase(params: StartAuctionParams(tournamentId: tournamentId));
    return response.isResult ? null : response.fallback.message;
  }

  Future<String?> pauseAuction() async {
    final response = await pauseAuctionUseCase(params: PauseAuctionParams(tournamentId: tournamentId));
    return response.isResult ? null : response.fallback.message;
  }

  Future<String?> resumeAuction() async {
    final response = await resumeAuctionUseCase(params: ResumeAuctionParams(tournamentId: tournamentId));
    return response.isResult ? null : response.fallback.message;
  }

  Future<String?> nextLot() async {
    final response = await nextAuctionLotUseCase(params: NextAuctionLotParams(tournamentId: tournamentId));
    return response.isResult ? null : response.fallback.message;
  }
}
