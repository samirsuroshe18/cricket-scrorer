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
import 'package:cricket_scorer/features/tournament/presentation/controllers/auction_room_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeTournamentRepository implements TournamentRepository {
  Stream<Either<AuctionStateRes, CricketFailure>> stateStream = const Stream.empty();
  Stream<void> sessionStartedStream = const Stream.empty();
  Stream<AuctionLotRes> lotOnBlockStream = const Stream.empty();
  Stream<AuctionBidAcceptedRes> bidAcceptedStream = const Stream.empty();
  Stream<AuctionBidRejectedRes> bidRejectedStream = const Stream.empty();
  Stream<AuctionLotResolvedRes> lotResolvedStream = const Stream.empty();
  Stream<void> pausedStream = const Stream.empty();
  Stream<DateTime?> resumedStream = const Stream.empty();
  Stream<void> sessionCompletedStream = const Stream.empty();
  String? lastBidLotId;

  @override
  Stream<Either<AuctionStateRes, CricketFailure>> watchAuctionState({required String tournamentId}) => stateStream;
  @override
  Stream<void> watchAuctionSessionStarted({required String tournamentId}) => sessionStartedStream;
  @override
  Stream<AuctionLotRes> watchAuctionLotOnBlock({required String tournamentId}) => lotOnBlockStream;
  @override
  Stream<AuctionBidAcceptedRes> watchAuctionBidAccepted({required String tournamentId}) => bidAcceptedStream;
  @override
  Stream<AuctionBidRejectedRes> watchAuctionBidRejected({required String tournamentId}) => bidRejectedStream;
  @override
  Stream<AuctionLotResolvedRes> watchAuctionLotResolved({required String tournamentId}) => lotResolvedStream;
  @override
  Stream<void> watchAuctionPaused({required String tournamentId}) => pausedStream;
  @override
  Stream<DateTime?> watchAuctionResumed({required String tournamentId}) => resumedStream;
  @override
  Stream<void> watchAuctionSessionCompleted({required String tournamentId}) => sessionCompletedStream;
  @override
  Future<void> bidOnAuctionLot({required String tournamentId, required String lotId}) async {
    lastBidLotId = lotId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StubStartAuctionUseCase implements StartAuctionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StubPauseAuctionUseCase implements PauseAuctionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StubResumeAuctionUseCase implements ResumeAuctionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StubNextAuctionLotUseCase implements NextAuctionLotUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  AuctionRoomController buildController(_FakeTournamentRepository repository) {
    return AuctionRoomController(
      tournamentId: 'tournament-1',
      tournamentRepository: repository,
      startAuctionUseCase: _StubStartAuctionUseCase(),
      pauseAuctionUseCase: _StubPauseAuctionUseCase(),
      resumeAuctionUseCase: _StubResumeAuctionUseCase(),
      nextAuctionLotUseCase: _StubNextAuctionLotUseCase(),
    );
  }

  test('applies the initial state from watchAuctionState', () async {
    final repository = _FakeTournamentRepository()
      ..stateStream = Stream.value(Either.result(AuctionStateRes(
        sessionStatus: 'active',
        lot: AuctionLotRes(lotId: 'lot-1', playerId: 'player-1', playerName: 'Rohit Sharma', basePrice: 5000, currentBid: 5000),
        bidHistory: const [],
        budgets: [
          AuctionBudgetRes(teamId: 'team-1', teamName: 'Riverside U19', ownerId: 'owner-1', budget: 100000, spent: 0, remaining: 100000),
        ],
      )));
    final controller = buildController(repository);
    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(controller.sessionStatus.value, 'active');
    expect(controller.currentLot.value?.lotId, 'lot-1');
    expect(controller.budgets.single.teamName, 'Riverside U19');
  });

  test("a bidAccepted event updates the current lot's bid and endsAt", () async {
    final endsAt = DateTime.now().add(const Duration(seconds: 15));
    final repository = _FakeTournamentRepository()
      ..stateStream = Stream.value(Either.result(AuctionStateRes(
        sessionStatus: 'active',
        lot: AuctionLotRes(lotId: 'lot-1', playerId: 'player-1', basePrice: 5000, currentBid: 5000),
        bidHistory: const [],
        budgets: const [],
      )))
      ..bidAcceptedStream = Stream.value(AuctionBidAcceptedRes(
        lotId: 'lot-1', amount: 5500, bidderTeamId: 'team-1', bidderTeamName: 'Riverside U19', endsAt: endsAt,
      ));
    final controller = buildController(repository);
    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentLot.value?.currentBid, 5500);
    expect(controller.currentLot.value?.endsAt, endsAt);
    expect(controller.bidHistory.single.amount, 5500);
  });

  test("placeBid delegates to the repository with the current lot's id", () async {
    final repository = _FakeTournamentRepository()
      ..stateStream = Stream.value(Either.result(AuctionStateRes(
        sessionStatus: 'active',
        lot: AuctionLotRes(lotId: 'lot-1', playerId: 'player-1', basePrice: 5000, currentBid: 5000),
        bidHistory: const [],
        budgets: const [],
      )));
    final controller = buildController(repository);
    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    controller.placeBid();
    await Future<void>.delayed(Duration.zero);

    expect(repository.lastBidLotId, 'lot-1');
  });

  test(
    'a sessionStarted event moves sessionStatus off null for a socket that joined before start',
    () async {
      final repository = _FakeTournamentRepository()
        ..stateStream = Stream.value(Either.result(AuctionStateRes(
          sessionStatus: null,
          lot: null,
          bidHistory: const [],
          budgets: const [],
        )))
        ..sessionStartedStream = Stream.value(null);
      final controller = buildController(repository);
      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.sessionStatus.value, 'active');
    },
  );

  test('a lotResolved event clears the current lot', () async {
    final repository = _FakeTournamentRepository()
      ..stateStream = Stream.value(Either.result(AuctionStateRes(
        sessionStatus: 'active',
        lot: AuctionLotRes(lotId: 'lot-1', playerId: 'player-1', basePrice: 5000, currentBid: 5500),
        bidHistory: const [],
        budgets: const [],
      )))
      ..lotResolvedStream = Stream.value(AuctionLotResolvedRes(lotId: 'lot-1', outcome: 'sold', soldPrice: 5500, soldTo: 'team-1'));
    final controller = buildController(repository);
    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(controller.currentLot.value, isNull);
  });

  test(
    "a sold lotResolved event applies the server's own spent/remaining, never local arithmetic",
    () async {
      final repository = _FakeTournamentRepository()
        ..stateStream = Stream.value(Either.result(AuctionStateRes(
          sessionStatus: 'active',
          lot: AuctionLotRes(lotId: 'lot-1', playerId: 'player-1', basePrice: 5000, currentBid: 5500),
          bidHistory: const [],
          budgets: [
            AuctionBudgetRes(teamId: 'team-1', teamName: 'Riverside U19', ownerId: 'owner-1', budget: 100000, spent: 0, remaining: 100000),
          ],
        )))
        // Deliberately NOT 5500/94500 (what local arithmetic off the
        // initial budget would produce) — a server figure that already
        // accounts for something the client's own cache couldn't know
        // about, so the test can tell which source the controller used.
        ..lotResolvedStream = Stream.value(AuctionLotResolvedRes(
          lotId: 'lot-1', outcome: 'sold', soldPrice: 5500, soldTo: 'team-1', spent: 12000, remaining: 88000,
        ));
      final controller = buildController(repository);
      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.budgets.single.spent, 12000);
      expect(controller.budgets.single.remaining, 88000);
    },
  );

  test('two consecutive identical bid rejections both notify listeners, never silently swallowed', () async {
    final repository = _FakeTournamentRepository()
      ..stateStream = Stream.value(Either.result(AuctionStateRes(
        sessionStatus: 'active',
        lot: AuctionLotRes(lotId: 'lot-1', playerId: 'player-1', basePrice: 5000, currentBid: 5000),
        bidHistory: const [],
        budgets: const [],
      )))
      ..bidRejectedStream = Stream.fromIterable([
        AuctionBidRejectedRes(code: 'INSUFFICIENT_BUDGET', message: 'Not enough remaining budget for this bid'),
        AuctionBidRejectedRes(code: 'INSUFFICIENT_BUDGET', message: 'Not enough remaining budget for this bid'),
      ]);
    final controller = buildController(repository);

    final emittedMessages = <String?>[];
    // Same mechanism the real screen uses (ever()) rather than reading
    // controller.actionError.value once at the end — the bug this guards
    // against is a *missed notification*, which only a listener attached
    // for the whole run can observe; reading the final value can't tell
    // "notified twice" apart from "notified once."
    final worker = ever<String?>(controller.actionError, emittedMessages.add);

    controller.onInit();
    await Future<void>.delayed(Duration.zero);
    worker.dispose();

    final nonNullEmissions = emittedMessages.where((m) => m != null).length;
    expect(nonNullEmissions, 2);
  });
}
