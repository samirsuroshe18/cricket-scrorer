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
}
