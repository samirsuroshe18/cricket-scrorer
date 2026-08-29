import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_dao.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/bowler.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/bowler_state.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/select_bowler.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/sync_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/undo_ball.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/score_ball_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Answers [startInnings] with a canned success and refuses every ball/bowler
/// call with [CricketNoInternetFailure] — every delivery in these tests is
/// meant to queue offline, never to actually reach a network.
class _OfflineMatchRepository implements MatchRepository {
  StartInningsRes? startInningsResponse;

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> createMatch({
    required CreateMatchReq? createMatchReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>>
  startInnings({
    required String matchId,
    required StartInningsReq? startInningsReq,
  }) async =>
      Either.result(CricketResponse(message: 'ok', data: startInningsResponse));

  @override
  Future<Either<CricketResponse<ScoreBallRes>, CricketFailure>> scoreBall({
    required String matchId,
    required ScoreBallReq? scoreBallReq,
  }) async => Either.fallback(CricketNoInternetFailure(statusCode: 0));

  @override
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>>
  selectBowler({
    required String matchId,
    required SelectBowlerReq? selectBowlerReq,
  }) async => Either.fallback(CricketNoInternetFailure(statusCode: 0));

  @override
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? undoBallReq,
  }) async {
    throw UnimplementedError(
      'Not exercised: with a non-empty queue, undoLastBall() always takes '
      'the local _undoQueuedBall path and never reaches the network.',
    );
  }

  @override
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> syncMatch({
    required String matchId,
    required SyncReq? syncReq,
  }) async {
    throw UnimplementedError('No sync attempt is triggered in this test.');
  }

  @override
  Stream<Either<LiveScoreRes, CricketFailure>> watchScoreUpdates({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<OverCompleteRes, CricketFailure>> watchOverComplete({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<ScoreUndoRes, CricketFailure>> watchScoreUndo({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<PublicMatchRes>, CricketFailure>>
  getPublicMatch({required String code}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  }) => const Stream.empty();
}

/// Answers [startInnings] with a canned success, then toggles between
/// scoring/undoing dot balls "online" (a real, sequential response, as a
/// server would give) and "offline" ([CricketNoInternetFailure]) via
/// [online] — this is what lets a test cross from a still-queued ball into
/// an already-synced one and back, which [_OfflineMatchRepository] (always
/// offline) cannot exercise.
///
/// Deliberately dot balls only (0 runs, no wicket, never reaching a 6th legal
/// ball): this keeps the fake's own bookkeeping to a single incrementing
/// counter, since a dot ball changes nothing about strike or the over-bowler
/// prompt — exactly the parts of `ScoreBallController` these tests are not
/// about. What they ARE about is the [BallHistory] ledger this repository's
/// [scoreBall]/[undoBall] responses drive.
class _MixedMatchRepository implements MatchRepository {
  StartInningsRes? startInningsResponse;
  bool online = true;

  final List<String> _ballIds = [];
  int _legalBalls = 0;

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> createMatch({
    required CreateMatchReq? createMatchReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>>
  startInnings({
    required String matchId,
    required StartInningsReq? startInningsReq,
  }) async {
    if (!online) {
      return Either.fallback(CricketNoInternetFailure(statusCode: 0));
    }
    return Either.result(
      CricketResponse(message: 'ok', data: startInningsResponse),
    );
  }

  @override
  Future<Either<CricketResponse<ScoreBallRes>, CricketFailure>> scoreBall({
    required String matchId,
    required ScoreBallReq? scoreBallReq,
  }) async {
    if (!online) {
      return Either.fallback(CricketNoInternetFailure(statusCode: 0));
    }

    _legalBalls += 1;
    final id = 'ball-$_legalBalls';
    _ballIds.add(id);

    return Either.result(
      CricketResponse(
        message: 'ok',
        data: ScoreBallRes(
          ballEventId: id,
          matchId: matchId,
          inningsId: 'innings-1',
          overNumber: 1,
          ballNumber: _legalBalls,
          absoluteBallSeq: _legalBalls,
          runs: 0,
          extras: 0,
          isLegal: true,
          overComplete: false,
          inningsComplete: false,
          matchComplete: false,
          strike: Strike(
            strikerName: 'Striker',
            strikerBalls: _legalBalls,
            nonStrikerName: 'Non-Striker',
          ),
          inningsTotals: InningsTotals(
            totalRuns: 0,
            wickets: 0,
            legalBalls: _legalBalls,
            totalBalls: _legalBalls,
            oversCompleted: 0,
            extras: ExtrasBreakdown(),
          ),
        ),
      ),
    );
  }

  @override
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>>
  selectBowler({
    required String matchId,
    required SelectBowlerReq? selectBowlerReq,
  }) async => Either.fallback(CricketNoInternetFailure(statusCode: 0));

  @override
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? undoBallReq,
  }) async {
    if (!online) {
      return Either.fallback(CricketNoInternetFailure(statusCode: 0));
    }

    // Mirrors the real endpoint's own idempotency/latest-only guard closely
    // enough for these tests: undoing anything but the current last ball is
    // never something a correct `undoLastBall()` would attempt.
    expect(_ballIds, isNotEmpty, reason: 'nothing left for the fake to undo');
    expect(undoBallReq!.ballEventId, _ballIds.last);

    _ballIds.removeLast();
    _legalBalls -= 1;

    return Either.result(
      CricketResponse(
        message: 'ok',
        data: UndoBallRes(
          matchId: matchId,
          inningsId: 'innings-1',
          inningsNumber: 1,
          undone: UndoneBall(
            ballEventId: undoBallReq.ballEventId,
            overNumber: 1,
            ballNumber: _legalBalls + 1,
            absoluteBallSeq: _legalBalls + 1,
          ),
          strike: Strike(
            strikerName: 'Striker',
            strikerBalls: _legalBalls,
            nonStrikerName: 'Non-Striker',
          ),
          bowler: BowlerState(
            currentBowlerId: 'bowler-1',
            currentBowlerName: 'Bumrah',
          ),
          inningsTotals: InningsTotals(
            totalRuns: 0,
            wickets: 0,
            legalBalls: _legalBalls,
            totalBalls: _legalBalls,
            oversCompleted: 0,
            extras: ExtrasBreakdown(),
          ),
          overs: '0.$_legalBalls',
        ),
      ),
    );
  }

  @override
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> syncMatch({
    required String matchId,
    required SyncReq? syncReq,
  }) async {
    throw UnimplementedError('No sync attempt is triggered in this test.');
  }

  @override
  Stream<Either<LiveScoreRes, CricketFailure>> watchScoreUpdates({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<OverCompleteRes, CricketFailure>> watchOverComplete({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<ScoreUndoRes, CricketFailure>> watchScoreUndo({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<PublicMatchRes>, CricketFailure>>
  getPublicMatch({required String code}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  }) => const Stream.empty();
}

/// Records every `/sync` call it receives instead of reaching a network —
/// what lets a test assert exactly how many calls `_attemptSync`'s
/// homogeneous-run grouping made, and what each one contained.
class _RecordingMatchRepository implements MatchRepository {
  final List<SyncReq> syncCalls = [];

  @override
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> syncMatch({
    required String matchId,
    required SyncReq? syncReq,
  }) async {
    syncCalls.add(syncReq!);

    final ballCount = syncReq.events.whereType<SyncBallEvent>().length;
    final lastBallId = ballCount == 0 ? null : 'synced-${syncCalls.length}';

    return Either.result(
      CricketResponse(
        message: 'ok',
        data: SyncRes(
          matchId: matchId,
          inningsId: 'innings-1',
          inningsNumber: syncReq.inningsNumber,
          syncStatus: 'synced',
          baseAbsoluteBallSeq: syncReq.baseAbsoluteBallSeq,
          absoluteBallSeq: syncReq.baseAbsoluteBallSeq + syncReq.events.length,
          appliedCount: syncReq.events.length,
          lastBallEventId: lastBallId,
          state: SyncState(
            inningsTotals: InningsTotals(
              totalRuns: 0,
              wickets: 0,
              legalBalls: 0,
              totalBalls: 0,
              oversCompleted: 0,
              extras: ExtrasBreakdown(),
            ),
            overs: '0.0',
          ),
        ),
      ),
    );
  }

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> createMatch({
    required CreateMatchReq? createMatchReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>>
  startInnings({
    required String matchId,
    required StartInningsReq? startInningsReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<ScoreBallRes>, CricketFailure>> scoreBall({
    required String matchId,
    required ScoreBallReq? scoreBallReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>>
  selectBowler({
    required String matchId,
    required SelectBowlerReq? selectBowlerReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? undoBallReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Stream<Either<LiveScoreRes, CricketFailure>> watchScoreUpdates({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<OverCompleteRes, CricketFailure>> watchOverComplete({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<ScoreUndoRes, CricketFailure>> watchScoreUndo({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<PublicMatchRes>, CricketFailure>>
  getPublicMatch({required String code}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  }) => const Stream.empty();
}

void main() {
  late _OfflineMatchRepository repo;
  late ScoringQueueDatabase db;
  late ScoreBallController controller;

  setUp(() async {
    repo = _OfflineMatchRepository();
    db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
    final dao = ScoringQueueDao(db);
    final offlineSyncService = OfflineSyncService(
      dao: dao,
      syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
      startInningsUseCase: StartInningsUseCase(matchRepository: repo),
    );

    controller = ScoreBallController(
      scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
      startInningsUseCase: StartInningsUseCase(matchRepository: repo),
      selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
      undoBallUseCase: UndoBallUseCase(matchRepository: repo),
      matchRepository: repo,
      offlineSyncService: offlineSyncService,
    );

    // ScoreBallController.onInit() reads Get.arguments rather than taking the
    // match via constructor — set it the same way real navigation would,
    // without needing to pump a widget tree.
    Get.testMode = true;
    Get.routing.args = CreateMatchRes(
      matchId: 'match-1',
      joinCode: null,
      teamA: TeamRef(id: 'team-a', name: 'Team A'),
      teamB: TeamRef(id: 'team-b', name: 'Team B'),
      totalOvers: 2,
      status: 'live',
      syncStatus: 'local',
      createdAt: '2026-01-01T00:00:00.000Z',
    );

    repo.startInningsResponse = StartInningsRes(
      matchId: 'match-1',
      inningsId: 'innings-1',
      inningsNumber: 1,
      battingTeam: 'teamA',
      bowlingTeam: 'teamB',
      strike: Strike(strikerName: 'Striker', nonStrikerName: 'Non-Striker'),
      bowler: Bowler(bowlerId: 'bowler-1', bowlerName: 'Bumrah'),
      target: null,
      inningsTotals: InningsTotals(
        totalRuns: 0,
        wickets: 0,
        legalBalls: 0,
        totalBalls: 0,
        oversCompleted: 0,
        extras: ExtrasBreakdown(),
      ),
    );

    // Deliberately onInit() only, never onReady(): onReady() wires the `ever`
    // listeners that drive _promptIfNeeded(), which would try to open a real
    // GetX bottom sheet the moment needsBowler flips true. This bug lives
    // entirely in the Rx state the sheet would be built from, not in the
    // sheet itself, so testing through the sheet would only add unrelated
    // navigation machinery to fake.
    controller.onInit();
    await controller.startInnings(
      strikerName: 'Striker',
      nonStrikerName: 'Non-Striker',
      bowlerName: 'Bumrah',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'undoing a queued ball that completed an over, then re-completing that '
    'same over, asks for a new bowler again',
    () async {
      // Six dot balls complete over 1 of this 2-over match while offline.
      for (var i = 0; i < 6; i++) {
        await controller.scoreRuns(0);
      }
      expect(
        controller.needsBowler.value,
        isTrue,
        reason: 'over 1 just completed — a bowler is owed for over 2',
      );
      expect(controller.currentBowler.value, isNull);

      // The scorer undoes that over-ending ball, e.g. via the bowler sheet's
      // own "Undo last ball" escape hatch.
      final undone = await controller.undoLastBall();
      expect(undone, isTrue);
      expect(
        controller.needsBowler.value,
        isFalse,
        reason: 'over 1 is open again — Bumrah is still bowling it',
      );
      expect(controller.currentBowler.value, 'Bumrah');

      // A replacement ball re-completes the SAME over.
      await controller.scoreRuns(0);

      expect(
        controller.needsBowler.value,
        isTrue,
        reason:
            'over 1 completed a second time — a bowler must be requested '
            'again for over 2, exactly as it was the first time',
      );
      expect(
        controller.currentBowler.value,
        isNull,
        reason: 'the over just ended; Bumrah must not silently carry over',
      );
    },
  );

  group('chained offline undo of already-synced balls', () {
    late _MixedMatchRepository mixedRepo;
    late ScoringQueueDao mixedDao;
    late ScoringQueueDatabase mixedDb;
    late OfflineSyncService mixedSyncService;
    late ScoreBallController mixedController;

    setUp(() async {
      mixedRepo = _MixedMatchRepository();
      mixedDb = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      mixedDao = ScoringQueueDao(mixedDb);
      mixedSyncService = OfflineSyncService(
        dao: mixedDao,
        syncMatchUseCase: SyncMatchUseCase(matchRepository: mixedRepo),
        startInningsUseCase: StartInningsUseCase(matchRepository: mixedRepo),
      );

      mixedController = ScoreBallController(
        scoreBallUseCase: ScoreBallUseCase(matchRepository: mixedRepo),
        startInningsUseCase: StartInningsUseCase(matchRepository: mixedRepo),
        selectBowlerUseCase: SelectBowlerUseCase(matchRepository: mixedRepo),
        undoBallUseCase: UndoBallUseCase(matchRepository: mixedRepo),
        matchRepository: mixedRepo,
        offlineSyncService: mixedSyncService,
      );

      Get.testMode = true;
      Get.routing.args = CreateMatchRes(
        matchId: 'match-1',
        joinCode: null,
        teamA: TeamRef(id: 'team-a', name: 'Team A'),
        teamB: TeamRef(id: 'team-b', name: 'Team B'),
        totalOvers: 2,
        status: 'live',
        syncStatus: 'local',
        createdAt: '2026-01-01T00:00:00.000Z',
      );

      mixedRepo.startInningsResponse = StartInningsRes(
        matchId: 'match-1',
        inningsId: 'innings-1',
        inningsNumber: 1,
        battingTeam: 'teamA',
        bowlingTeam: 'teamB',
        strike: Strike(strikerName: 'Striker', nonStrikerName: 'Non-Striker'),
        bowler: Bowler(bowlerId: 'bowler-1', bowlerName: 'Bumrah'),
        target: null,
        inningsTotals: InningsTotals(
          totalRuns: 0,
          wickets: 0,
          legalBalls: 0,
          totalBalls: 0,
          oversCompleted: 0,
          extras: ExtrasBreakdown(),
        ),
      );

      mixedController.onInit();
      await mixedController.startInnings(
        strikerName: 'Striker',
        nonStrikerName: 'Non-Striker',
        bowlerName: 'Bumrah',
      );
    });

    tearDown(() async {
      await mixedDb.close();
    });

    test(
      'undoing an already-synced ball no longer blocks further scoring, and '
      'can chain arbitrarily far back offline',
      () async {
        // Three dot balls, all scored ONLINE — each lands directly via
        // scoreBall, never touching the queue, so the only record of any of
        // them afterwards is their BallHistory ledger entry.
        for (var i = 0; i < 3; i++) {
          await mixedController.scoreRuns(0);
        }
        expect(mixedController.overs.value, '0.3');
        expect(
          await mixedSyncService.ballHistoryCount(
            matchId: 'match-1',
            inningsNumber: 1,
          ),
          3,
        );

        mixedRepo.online = false;

        // Undoing the most recent (already-synced) ball used to be the one
        // thing this app could not do offline at all — nothing populated
        // _scoredBallIds for a ball that arrived this way. It should now
        // both succeed AND leave the console able to keep scoring.
        expect(await mixedController.undoLastBall(), isTrue);
        expect(mixedController.overs.value, '0.2');
        expect(
          await mixedSyncService.ballHistoryCount(
            matchId: 'match-1',
            inningsNumber: 1,
          ),
          2,
          reason: 'the undone ball\'s ledger entry is gone',
        );

        // This is the actual regression this fixes: scoring must not be
        // blocked just because an offline undo of a synced ball is pending.
        await mixedController.scoreRuns(0);
        expect(
          mixedController.overs.value,
          '0.3',
          reason: 'the new ball queued instead of being refused',
        );

        // Undo the ball just queued (still-queued path)...
        expect(await mixedController.undoLastBall(), isTrue);
        expect(mixedController.overs.value, '0.2');

        // ...then keep undoing BACK INTO already-synced territory, twice
        // more, entirely offline — the "unlimited chained" requirement.
        expect(await mixedController.undoLastBall(), isTrue);
        expect(mixedController.overs.value, '0.1');
        expect(await mixedController.undoLastBall(), isTrue);
        expect(mixedController.overs.value, '0.0');

        // `canUndo` is gated on two Drift `.watch()` streams
        // (`queuedBallCount`/`historyCount`), which — like `pendingCount`
        // elsewhere in this service — deliver a tick behind the write that
        // triggered them, never synchronously. `pumpEventQueue` drains that
        // one microtask gap; a real UI binding just repaints a moment later
        // and never shows a wrong value long enough to matter.
        await pumpEventQueue();
        expect(mixedController.canUndo, isFalse);
      },
    );

    test(
      'interleaved undo/score/undo produces a clean, wire-ready undo-only '
      'queue with no trace of the locally-undone queued ball',
      () async {
        // Ball A, ball B: both synced online.
        await mixedController.scoreRuns(0);
        await mixedController.scoreRuns(0);

        mixedRepo.online = false;

        // Undo B (already-synced → queues undo(B)).
        expect(await mixedController.undoLastBall(), isTrue);
        // Score C (queued — no longer blocked by the pending undo).
        await mixedController.scoreRuns(0);
        // Undo C (still-queued → deletes its row directly, no wire event).
        expect(await mixedController.undoLastBall(), isTrue);
        // Undo again — back into already-synced territory, targets A.
        expect(await mixedController.undoLastBall(), isTrue);

        final queued = await mixedDao.pendingEvents(
          matchId: 'match-1',
          inningsNumber: 1,
        );
        expect(
          queued.map((e) => e.eventType).toList(),
          [SyncEventType.undo, SyncEventType.undo],
          reason:
              'C never reached the wire at all; only the two undos of the '
              'already-synced balls (B, then A) do — homogeneous and ready '
              'to flush in one call',
        );
      },
    );
  });

  group('offline innings transition', () {
    late _MixedMatchRepository repo;
    late ScoringQueueDao dao;
    late ScoringQueueDatabase db;
    late OfflineSyncService syncService;
    late ScoreBallController controller;

    setUp(() async {
      repo = _MixedMatchRepository();
      db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      dao = ScoringQueueDao(db);
      syncService = OfflineSyncService(
        dao: dao,
        syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
      );

      controller = ScoreBallController(
        scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
        undoBallUseCase: UndoBallUseCase(matchRepository: repo),
        matchRepository: repo,
        offlineSyncService: syncService,
      );

      Get.testMode = true;
      Get.routing.args = CreateMatchRes(
        matchId: 'match-1',
        joinCode: null,
        teamA: TeamRef(id: 'team-a', name: 'Team A'),
        teamB: TeamRef(id: 'team-b', name: 'Team B'),
        totalOvers: 2,
        status: 'live',
        syncStatus: 'local',
        createdAt: '2026-01-01T00:00:00.000Z',
      );

      repo.startInningsResponse = StartInningsRes(
        matchId: 'match-1',
        inningsId: 'innings-1',
        inningsNumber: 1,
        battingTeam: 'teamA',
        bowlingTeam: 'teamB',
        strike: Strike(strikerName: 'Striker', nonStrikerName: 'Non-Striker'),
        bowler: Bowler(bowlerId: 'bowler-1', bowlerName: 'Bumrah'),
        target: null,
        inningsTotals: InningsTotals(
          totalRuns: 0,
          wickets: 0,
          legalBalls: 0,
          totalBalls: 0,
          oversCompleted: 0,
          extras: ExtrasBreakdown(),
        ),
      );

      controller.onInit();
      await controller.startInnings(
        strikerName: 'Striker',
        nonStrikerName: 'Non-Striker',
        bowlerName: 'Bumrah',
      );

      // Innings 1 "completed" for the purposes of this test — bypassing
      // actually playing it out ball by ball, since what's under test is
      // startInnings()'s offline branch and the reconnect chain, not the
      // preview engine's own innings-complete detection (covered elsewhere).
      await syncService.recordInningsSummary(
        matchId: 'match-1',
        inningsNumber: 1,
        battingTeam: 'teamA',
        totalRuns: 120,
        wickets: 3,
        overs: '2.0',
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'startInnings() offline writes a pending marker and unlocks a zeroed, '
      'correctly-targeted innings-2 preview',
      () async {
        repo.online = false;

        final started = await controller.startInnings(
          strikerName: 'New Striker',
          nonStrikerName: 'New Non-Striker',
          bowlerName: 'New Bowler',
        );
        expect(started, isTrue);

        final pending = await syncService.pendingStartInningsFor(
          matchId: 'match-1',
          inningsNumber: 2,
        );
        expect(pending, isNotNull);
        expect(pending!.strikerName, 'New Striker');
        expect(pending.nonStrikerName, 'New Non-Striker');
        expect(pending.bowlerName, 'New Bowler');

        expect(
          controller.target.value,
          121,
          reason: 'innings 1 finished on 120 — target is runs + 1',
        );
        expect(controller.totalRuns.value, 0);
        expect(controller.wickets.value, 0);
        expect(controller.overs.value, '0.0');
        expect(controller.strike.value?.strikerName, 'New Striker');
        expect(controller.strike.value?.nonStrikerName, 'New Non-Striker');
        expect(controller.currentBowler.value, 'New Bowler');
        expect(
          controller.needsBowler.value,
          isFalse,
          reason: 'the entered name is already the bowler for over 1',
        );
      },
    );

    test(
      'reconnecting opens the real innings and clears the marker, with '
      'nothing left to flush',
      () async {
        repo.online = false;
        await controller.startInnings(
          strikerName: 'New Striker',
          nonStrikerName: 'New Non-Striker',
          bowlerName: 'New Bowler',
        );

        repo.online = true;
        repo.startInningsResponse = StartInningsRes(
          matchId: 'match-1',
          inningsId: 'innings-2',
          inningsNumber: 2,
          battingTeam: 'teamB',
          bowlingTeam: 'teamA',
          strike: Strike(
            strikerName: 'New Striker',
            nonStrikerName: 'New Non-Striker',
          ),
          bowler: Bowler(bowlerId: 'bowler-2', bowlerName: 'New Bowler'),
          target: 121,
          inningsTotals: InningsTotals(
            totalRuns: 0,
            wickets: 0,
            legalBalls: 0,
            totalBalls: 0,
            oversCompleted: 0,
            extras: ExtrasBreakdown(),
          ),
        );

        await syncService.retryNow(matchId: 'match-1', inningsNumber: 2);

        final pending = await syncService.pendingStartInningsFor(
          matchId: 'match-1',
          inningsNumber: 2,
        );
        expect(
          pending,
          isNull,
          reason: 'the real start-innings call succeeded, marker cleared',
        );
        expect(syncService.lastAppliedStartInnings.value?.inningsNumber, 2);
      },
    );
  });

  group('offline match completion', () {
    late _MixedMatchRepository repo;
    late ScoringQueueDao dao;
    late ScoringQueueDatabase db;
    late OfflineSyncService syncService;
    late ScoreBallController controller;

    setUp(() async {
      repo = _MixedMatchRepository();
      db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      dao = ScoringQueueDao(db);
      syncService = OfflineSyncService(
        dao: dao,
        syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
      );

      controller = ScoreBallController(
        scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
        undoBallUseCase: UndoBallUseCase(matchRepository: repo),
        matchRepository: repo,
        offlineSyncService: syncService,
      );

      Get.testMode = true;
      // 1 over, so a full innings 2 (all dot balls) is a short, deterministic
      // 6 balls — enough to exercise `oversDone` without a long loop.
      Get.routing.args = CreateMatchRes(
        matchId: 'match-1',
        joinCode: null,
        teamA: TeamRef(id: 'team-a', name: 'Team A'),
        teamB: TeamRef(id: 'team-b', name: 'Team B'),
        totalOvers: 1,
        status: 'live',
        syncStatus: 'local',
        createdAt: '2026-01-01T00:00:00.000Z',
      );

      repo.startInningsResponse = StartInningsRes(
        matchId: 'match-1',
        inningsId: 'innings-1',
        inningsNumber: 1,
        battingTeam: 'teamA',
        bowlingTeam: 'teamB',
        strike: Strike(strikerName: 'Striker', nonStrikerName: 'Non-Striker'),
        bowler: Bowler(bowlerId: 'bowler-1', bowlerName: 'Bumrah'),
        target: null,
        inningsTotals: InningsTotals(
          totalRuns: 0,
          wickets: 0,
          legalBalls: 0,
          totalBalls: 0,
          oversCompleted: 0,
          extras: ExtrasBreakdown(),
        ),
      );

      controller.onInit();
      await controller.startInnings(
        strikerName: 'Striker',
        nonStrikerName: 'Non-Striker',
        bowlerName: 'Bumrah',
      );

      // Innings 1 "completed" on 120/3 — bypassing actually playing it out,
      // same as the innings-transition tests above; what this group tests is
      // the result computation, not the preview engine's own detection.
      await syncService.recordInningsSummary(
        matchId: 'match-1',
        inningsNumber: 1,
        battingTeam: 'teamA',
        totalRuns: 120,
        wickets: 3,
        overs: '1.0',
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'the terminal ball of an all-dot-ball innings 2, queued offline, '
      'saves a correct provisional result',
      () async {
        repo.online = false;
        await controller.startInnings(
          strikerName: 'New Striker',
          nonStrikerName: 'New Non-Striker',
          bowlerName: 'New Bowler',
        );

        // 6 dot balls complete this 1-over innings 2 on 0/0 — short of
        // innings 1's 120, so innings 1's side should win by 120 runs.
        for (var i = 0; i < 6; i++) {
          await controller.scoreRuns(0);
        }

        // The provisional-result save is fire-and-forget from the
        // controller's own perspective (`unawaited`, so a slow DB write
        // never delays the console) — drain the microtask queue so it has
        // actually landed before checking.
        await pumpEventQueue();

        final result = await syncService.provisionalResultFor('match-1');
        expect(result, isNotNull);
        expect(result!.winner, 'teamA');
        expect(result.marginType, 'runs');
        expect(result.margin, 120);
      },
    );
  });

  group('OfflineSyncService homogeneous-run grouping', () {
    test(
      'a mixed queue flushes as separate same-type calls, in order',
      () async {
        final recordingRepo = _RecordingMatchRepository();
        final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
        final dao = ScoringQueueDao(db);
        final service = OfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: recordingRepo),
          startInningsUseCase: StartInningsUseCase(
            matchRepository: recordingRepo,
          ),
        );

        const pre = PreEventState(
          totalRuns: 0,
          wickets: 0,
          legalBalls: 0,
          totalBalls: 0,
          oversCompleted: 0,
          striker: BatsmanFigures(name: 'Striker'),
          nonStriker: BatsmanFigures(name: 'Non-Striker'),
          currentBowlerName: 'Bumrah',
          overTotalRuns: 0,
          overLegalDeliveries: 0,
          extrasSnapshot: ExtrasSnapshot(),
          overExtrasSnapshot: ExtrasSnapshot(),
        );
        ScoreBallReq ballReq() => ScoreBallReq(
          runs: 0,
          idempotencyKey: 'key-${DateTime.now().microsecondsSinceEpoch}',
        );

        // Seeded directly via the DAO — [ball, ball, undo, undo, ball] — a
        // shape the controller itself would never hand-assemble in one go,
        // but exactly what a real interleaved session can leave behind.
        await dao.enqueueBall(
          matchId: 'match-1',
          inningsNumber: 1,
          req: ballReq(),
          pre: pre,
        );
        await dao.enqueueBall(
          matchId: 'match-1',
          inningsNumber: 1,
          req: ballReq(),
          pre: pre,
        );
        await dao.enqueueUndo(
          matchId: 'match-1',
          inningsNumber: 1,
          ballEventId: 'already-synced-1',
        );
        await dao.enqueueUndo(
          matchId: 'match-1',
          inningsNumber: 1,
          ballEventId: 'already-synced-2',
        );
        await dao.enqueueBall(
          matchId: 'match-1',
          inningsNumber: 1,
          req: ballReq(),
          pre: pre,
        );

        await service.retryNow(matchId: 'match-1', inningsNumber: 1);

        expect(
          recordingRepo.syncCalls.length,
          4,
          reason: '[ball] [ball] [undo,undo] [ball] — four contiguous runs',
        );
        expect(recordingRepo.syncCalls[0].events.length, 1);
        expect(recordingRepo.syncCalls[0].events.single, isA<SyncBallEvent>());
        expect(recordingRepo.syncCalls[1].events.length, 1);
        expect(recordingRepo.syncCalls[1].events.single, isA<SyncBallEvent>());
        expect(recordingRepo.syncCalls[2].events.length, 2);
        expect(
          recordingRepo.syncCalls[2].events,
          everyElement(isA<SyncUndoEvent>()),
        );
        expect(recordingRepo.syncCalls[3].events.length, 1);
        expect(recordingRepo.syncCalls[3].events.single, isA<SyncBallEvent>());

        expect(
          await dao.pendingEvents(matchId: 'match-1', inningsNumber: 1),
          isEmpty,
          reason: 'every run applied cleanly, so nothing is left queued',
        );

        await db.close();
      },
    );
  });
}
