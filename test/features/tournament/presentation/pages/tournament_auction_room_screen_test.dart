import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_event_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/next_auction_lot.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/pause_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resume_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_auction.dart';
import 'package:cricket_scorer/features/tournament/presentation/bindings/auction_room_binding.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_auction_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeTournamentRepository implements TournamentRepository {
  Stream<Either<AuctionStateRes, CricketFailure>> stateStream = const Stream.empty();
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

class _UnusedStartAuctionUseCase implements StartAuctionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedPauseAuctionUseCase implements PauseAuctionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedResumeAuctionUseCase implements ResumeAuctionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedNextAuctionLotUseCase implements NextAuctionLotUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  // Navigates via a real Get.toNamed(..., arguments: ...) call from a
  // button, rather than relying on GetPage's own `arguments` default —
  // that default only applies inconsistently for a cold-start
  // `initialRoute`, not for every route-matching path GetX takes.
  Future<void> pumpScreen(WidgetTester tester, _FakeTournamentRepository repository, {bool isOwner = false}) async {
    Get.put<TournamentRepository>(repository);
    Get.put<StartAuctionUseCase>(_UnusedStartAuctionUseCase());
    Get.put<PauseAuctionUseCase>(_UnusedPauseAuctionUseCase());
    Get.put<ResumeAuctionUseCase>(_UnusedResumeAuctionUseCase());
    Get.put<NextAuctionLotUseCase>(_UnusedNextAuctionLotUseCase());

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Get.toNamed<dynamic>(
                '/tournament/tournament-1/auction-room',
                arguments: {'isOwner': isOwner},
              ),
              child: const Text('open'),
            ),
          ),
        ),
        getPages: [
          GetPage(
            name: '/tournament/:tournamentId/auction-room',
            page: () => const TournamentAuctionRoomScreen(),
            binding: AuctionRoomBinding(),
          ),
        ],
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows a start-auction button for the owner before the session exists', (tester) async {
    final repository = _FakeTournamentRepository();
    await pumpScreen(tester, repository, isOwner: true);

    expect(find.text('start_auction'), findsOneWidget);
  });

  testWidgets(
    'the active-lot card does not overflow on a short viewport',
    (tester) async {
      // Regression test for a real RenderFlex overflow this screen shipped
      // with: the lot card's Column had no way to shrink, so on a shorter
      // screen than the test framework's default it overflowed instead of
      // scrolling. Fixed by wrapping it in a SingleChildScrollView — this
      // pins that fix by asserting no exception is thrown while laying out
      // at a deliberately short height.
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final repository = _FakeTournamentRepository()
        ..stateStream = Stream.value(Either.result(AuctionStateRes(
          sessionStatus: 'active',
          lot: AuctionLotRes(
            lotId: 'lot-1', playerId: 'player-1', playerName: 'Rohit Sharma', playerRole: 'batsman',
            basePrice: 5000, currentBid: 5000, endsAt: DateTime.now().add(const Duration(seconds: 15)),
          ),
          bidHistory: const [],
          budgets: [
            AuctionBudgetRes(teamId: 'team-1', teamName: 'Riverside U19', ownerId: 'owner-1', budget: 100000, spent: 0, remaining: 100000),
          ],
        )));
      await pumpScreen(tester, repository);
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows the current player and current bid once a lot is active', (tester) async {
    final repository = _FakeTournamentRepository()
      ..stateStream = Stream.value(Either.result(AuctionStateRes(
        sessionStatus: 'active',
        lot: AuctionLotRes(
          lotId: 'lot-1', playerId: 'player-1', playerName: 'Rohit Sharma', basePrice: 5000, currentBid: 5000,
          endsAt: DateTime.now().add(const Duration(seconds: 15)),
        ),
        bidHistory: const [],
        budgets: const [],
      )));
    await pumpScreen(tester, repository);
    await tester.pump();

    expect(find.text('Rohit Sharma'), findsOneWidget);
    expect(find.text('₹5000'), findsOneWidget);
  });

  testWidgets('tapping the bid button delegates to the repository with the active lot id', (tester) async {
    final repository = _FakeTournamentRepository()
      ..stateStream = Stream.value(Either.result(AuctionStateRes(
        sessionStatus: 'active',
        lot: AuctionLotRes(
          lotId: 'lot-1', playerId: 'player-1', playerName: 'Rohit Sharma', basePrice: 5000, currentBid: 5000,
          endsAt: DateTime.now().add(const Duration(seconds: 15)),
        ),
        bidHistory: const [],
        budgets: const [],
      )));
    await pumpScreen(tester, repository);
    await tester.pump();

    await tester.tap(find.text('place_bid'));
    await tester.pump();

    expect(repository.lastBidLotId, 'lot-1');
  });
}
