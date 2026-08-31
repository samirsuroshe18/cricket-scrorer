import 'dart:async';

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
import 'package:cricket_scorer/features/scoring/data/models/response/abandon_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/delete_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_abandoned_res.dart';
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
import 'package:cricket_scorer/features/scoring/domain/usecases/abandon_match.dart';
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

  /// Settable per test — null means "not exercised", matching every other
  /// unset field on this fake.
  Either<CricketResponse<AbandonMatchRes>, CricketFailure>?
  abandonMatchResponse;

  /// Settable per test, same convention — null falls back to this fake's
  /// default "no internet" answer below.
  Either<CricketResponse<SelectBowlerRes>, CricketFailure>?
  selectBowlerResponse;

  /// Captured on every call, regardless of [selectBowlerResponse] — what
  /// proves the controller actually sent a `bowlerId`, not just that
  /// `bowlersSeen` ended up looking right.
  SelectBowlerReq? lastSelectBowlerReq;

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
  }) async {
    lastSelectBowlerReq = selectBowlerReq;
    final response = selectBowlerResponse;
    if (response != null) return response;
    return Either.fallback(CricketNoInternetFailure(statusCode: 0));
  }

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

  @override
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId}) async {
    final response = abandonMatchResponse;
    if (response == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return response;
  }

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> deleteMatch({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }
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
  // Runs credited by each ball still on the server, in the same order as
  // [_ballIds] — what makes undo able to subtract exactly what the ball
  // being removed actually contributed, rather than always assuming 0.
  final List<int> _ballRuns = [];
  int _legalBalls = 0;
  int _totalRuns = 0;

  /// Lets a test simulate the socket's own `score:update` broadcast landing
  /// for a ball WHILE its REST response is still in flight — a real race on
  /// a real device (the server broadcasts the instant it commits; the REST
  /// response to the very same request can arrive a moment later), and
  /// exactly what [watchScoreUpdatesController] exists to make reproducible.
  Future<void> Function()? onScoreBallInFlight;
  final watchScoreUpdatesController =
      StreamController<Either<LiveScoreRes, CricketFailure>>.broadcast();

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

    final runs = scoreBallReq!.runs;
    _legalBalls += 1;
    _totalRuns += runs;
    final id = 'ball-$_legalBalls';
    _ballIds.add(id);
    _ballRuns.add(runs);

    // The server has "committed" the ball at this point — a hook here, if
    // set, is what lets a test fire the socket broadcast for it before this
    // method's own REST response makes its way back to the caller.
    final hook = onScoreBallInFlight;
    if (hook != null) await hook();

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
          runs: runs,
          extras: 0,
          isLegal: true,
          overComplete: false,
          inningsComplete: false,
          matchComplete: false,
          strike: Strike(
            strikerName: 'Striker',
            strikerRuns: _totalRuns,
            strikerBalls: _legalBalls,
            nonStrikerName: 'Non-Striker',
          ),
          inningsTotals: InningsTotals(
            totalRuns: _totalRuns,
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
    // Mirrors the real endpoint's own idempotency/latest-only guard closely
    // enough for these tests: undoing anything but the current last ball is
    // never something a correct `undoLastBall()` would attempt.
    expect(_ballIds, isNotEmpty, reason: 'nothing left for the fake to undo');
    expect(undoBallReq!.ballEventId, _ballIds.last);

    // Decremented BEFORE the offline check, not after: an offline undo
    // still genuinely removes the ball from this fake's own bookkeeping —
    // it just queues instead of confirming immediately — exactly as the
    // real server eventually does once the queued undo syncs. Without
    // this, a later "replacement" ball scored after reconnecting would get
    // a `absoluteBallSeq` this fake's own count never actually freed up,
    // which is not what a real server would do.
    _ballIds.removeLast();
    _legalBalls -= 1;
    _totalRuns -= _ballRuns.removeLast();

    if (!online) {
      return Either.fallback(CricketNoInternetFailure(statusCode: 0));
    }

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
            strikerRuns: _totalRuns,
            strikerBalls: _legalBalls,
            nonStrikerName: 'Non-Striker',
          ),
          bowler: BowlerState(
            currentBowlerId: 'bowler-1',
            currentBowlerName: 'Bumrah',
          ),
          inningsTotals: InningsTotals(
            totalRuns: _totalRuns,
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
  }) => watchScoreUpdatesController.stream;

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

  @override
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> deleteMatch({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }
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

  @override
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> deleteMatch({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }
}

/// One innings' server-side state, as the fake below tracks it: how many
/// balls have landed, and in what order their `idempotencyKey`s arrived —
/// exactly the two things `resolveSyncDecision` (backend
/// `src/utils/resolveSync.js`) needs to tell a resumable retry from a real
/// conflict.
class _ServerInnings {
  int totalBalls = 0;
  final List<String> ballKeys = [];
}

/// Mirrors the REAL backend's `/sync` conflict/resume algorithm
/// (`resolveSyncDecision` + `syncMatch` in `match.controller.js`) closely
/// enough to catch a genuine ordering bug — unlike every other fake in this
/// file, whose `syncMatch` either throws `UnimplementedError` or always
/// reports success unconditionally. Neither of those can ever produce (or
/// rule out) a `SYNC_CONFLICT`, which is exactly why the full offline
/// lifecycle below was never covered before.
class _ServerSimulatingMatchRepository implements MatchRepository {
  _ServerSimulatingMatchRepository({required this.ballsPerInnings});

  /// A whole 1-over innings in 6 dot balls — short and deterministic, same
  /// convention the "offline match completion" group above uses.
  final int ballsPerInnings;

  bool online = true;

  /// Mirrors `Match.currentInnings` — flips to 2 only as a side effect of
  /// innings 1's terminal ball actually being *applied* here, the same way
  /// the real server only flips it inside `applyDelivery`, never as a
  /// standalone step.
  int currentInnings = 1;

  final Map<int, _ServerInnings> _innings = {};

  _ServerInnings innings(int inningsNumber) =>
      _innings[inningsNumber] ??
      (throw StateError('innings $inningsNumber was never started'));

  final watchScoreUpdatesController =
      StreamController<Either<LiveScoreRes, CricketFailure>>.broadcast();

  @override
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>>
  startInnings({
    required String matchId,
    required StartInningsReq? startInningsReq,
  }) async {
    if (!online) {
      return Either.fallback(CricketNoInternetFailure(statusCode: 0));
    }

    final inningsNumber = currentInnings;
    _innings.putIfAbsent(inningsNumber, () => _ServerInnings());

    return Either.result(
      CricketResponse(
        message: 'ok',
        data: StartInningsRes(
          matchId: matchId,
          inningsId: 'innings-$inningsNumber',
          inningsNumber: inningsNumber,
          battingTeam: inningsNumber == 1 ? 'teamA' : 'teamB',
          bowlingTeam: inningsNumber == 1 ? 'teamB' : 'teamA',
          strike: Strike(
            strikerName: startInningsReq!.strikerName,
            nonStrikerName: startInningsReq.nonStrikerName,
          ),
          bowler: Bowler(
            bowlerId: 'bowler-$inningsNumber',
            bowlerName: startInningsReq.bowlerName,
          ),
          target: inningsNumber == 2 ? 1 : null,
          inningsTotals: InningsTotals(
            totalRuns: 0,
            wickets: 0,
            legalBalls: 0,
            totalBalls: 0,
            oversCompleted: 0,
            extras: ExtrasBreakdown(),
          ),
        ),
      ),
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
    throw UnimplementedError(
      'Every ball in this test is scored while online only via syncMatch, '
      'never a direct score-ball call.',
    );
  }

  @override
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>>
  selectBowler({
    required String matchId,
    required SelectBowlerReq? selectBowlerReq,
  }) async {
    if (!online) {
      return Either.fallback(CricketNoInternetFailure(statusCode: 0));
    }
    throw UnimplementedError(
      'Every bowler selection in this test is made while online only via '
      'syncMatch, never a direct select-bowler call.',
    );
  }

  @override
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? undoBallReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> syncMatch({
    required String matchId,
    required SyncReq? syncReq,
  }) async {
    if (!online) {
      return Either.fallback(CricketNoInternetFailure(statusCode: 0));
    }

    final req = syncReq!;

    if (req.inningsNumber != currentInnings) {
      return Either.fallback(
        CricketBadRequestFailure(
          statusCode: 400,
          code: 'SYNC_INNINGS_MISMATCH',
        ),
      );
    }

    final inn = _innings[req.inningsNumber];
    if (inn == null) {
      return Either.fallback(
        CricketBadRequestFailure(statusCode: 400, code: 'INNINGS_NOT_STARTED'),
      );
    }

    final serverSeq = inn.totalBalls;
    final baseSeq = req.baseAbsoluteBallSeq;
    var ballsToSkip = 0;

    // Exactly `resolveSyncDecision`'s three-way branch.
    if (serverSeq != baseSeq) {
      final ahead = serverSeq - baseSeq;
      final batchBallKeys = req.events
          .whereType<SyncBallEvent>()
          .map((e) => e.req.idempotencyKey)
          .toList();

      if (ahead < 0 || ahead > batchBallKeys.length) {
        return Either.fallback(
          CricketConflictFailure(statusCode: 409, code: 'SYNC_CONFLICT'),
        );
      }

      final serverKeysAhead = inn.ballKeys.sublist(baseSeq, baseSeq + ahead);
      for (var i = 0; i < ahead; i++) {
        if (serverKeysAhead[i] != batchBallKeys[i]) {
          return Either.fallback(
            CricketConflictFailure(statusCode: 409, code: 'SYNC_CONFLICT'),
          );
        }
      }
      ballsToSkip = ahead;
    }

    var appliedCount = 0;
    var skippedCount = 0;
    String? lastBallEventId;

    for (final event in req.events) {
      switch (event) {
        case SyncBallEvent():
          if (ballsToSkip > 0) {
            ballsToSkip -= 1;
            skippedCount += 1;
            continue;
          }
          inn.totalBalls += 1;
          inn.ballKeys.add(event.req.idempotencyKey);
          lastBallEventId = 'synced-${req.inningsNumber}-${inn.totalBalls}';
          appliedCount += 1;

          // The one side effect that matters here: innings 1's own terminal
          // ball flips `currentInnings`, purely as a consequence of applying
          // it — never a separate step, matching the real server.
          if (req.inningsNumber == 1 &&
              currentInnings == 1 &&
              inn.totalBalls >= ballsPerInnings) {
            currentInnings = 2;
          }
        case SyncBowlerEvent():
          appliedCount += 1;
        case SyncUndoEvent():
          throw UnimplementedError('Not exercised in this test.');
      }
    }

    return Either.result(
      CricketResponse(
        message: 'ok',
        data: SyncRes(
          matchId: matchId,
          inningsId: 'innings-${req.inningsNumber}',
          inningsNumber: req.inningsNumber,
          syncStatus: 'synced',
          baseAbsoluteBallSeq: req.baseAbsoluteBallSeq,
          absoluteBallSeq: inn.totalBalls,
          appliedCount: appliedCount,
          skippedCount: skippedCount,
          lastBallEventId: lastBallEventId,
          state: SyncState(
            inningsTotals: InningsTotals(
              totalRuns: 0,
              wickets: 0,
              legalBalls: inn.totalBalls,
              totalBalls: inn.totalBalls,
              oversCompleted: inn.totalBalls ~/ 6,
              extras: ExtrasBreakdown(),
            ),
            overs: '${inn.totalBalls ~/ 6}.${inn.totalBalls % 6}',
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
  Stream<Either<LiveScoreRes, CricketFailure>> watchScoreUpdates({
    required String matchId,
  }) => watchScoreUpdatesController.stream;

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

  @override
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> deleteMatch({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }
}

/// Answers [startInnings] with a canned success, refuses every ball/bowler
/// call with [CricketNoInternetFailure] (so everything queues offline, same
/// as [_OfflineMatchRepository]), and answers the eventual [syncMatch]
/// attempt with a `failedAt`/`failedCode` response — simulating a queued
/// event that fails a genuine server-side rule check, never a transient
/// failure. Mirrors what `OfflineSyncService._flushQueue` does with such a
/// response: nothing commits (`appliedCount`/`skippedCount` both 0), so the
/// failing event stays at the head of the queue and `phase` becomes
/// [SyncPhase.blockedOnRule].
class _RuleBlockingMatchRepository implements MatchRepository {
  StartInningsRes? startInningsResponse;

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
    final req = syncReq!;
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: SyncRes(
          matchId: matchId,
          inningsId: 'innings-${req.inningsNumber}',
          inningsNumber: req.inningsNumber,
          syncStatus: 'conflict',
          baseAbsoluteBallSeq: req.baseAbsoluteBallSeq,
          absoluteBallSeq: req.baseAbsoluteBallSeq,
          appliedCount: 0,
          skippedCount: 0,
          failedAt: 0,
          failedCode: 'BOWLER_CANNOT_BOWL_CONSECUTIVE_OVERS',
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
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> createMatch({
    required CreateMatchReq? createMatchReq,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId}) async {
    throw UnimplementedError('Not exercised in this test.');
  }

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> deleteMatch({
    required String matchId,
  }) async {
    throw UnimplementedError('Not exercised in this test.');
  }
}

/// Deterministically reproduces the race `_seedProvisionalStateIfQueued`
/// guards against: something else finishes flushing this exact queue while
/// the seed's own read of it is still in flight. Rather than trying to time
/// a real async race, this makes it happen — the queue is cleared for real,
/// from directly inside the overridden read, immediately before it returns
/// the (now stale) snapshot it had already computed.
class _RaceyOfflineSyncService extends OfflineSyncService {
  _RaceyOfflineSyncService({
    required super.dao,
    required super.syncMatchUseCase,
    required super.startInningsUseCase,
  });

  @override
  Future<PreEventState?> currentProvisionalState({
    required String matchId,
    required int inningsNumber,
    required int totalOvers,
    int? target,
  }) async {
    final pre = await super.currentProvisionalState(
      matchId: matchId,
      inningsNumber: inningsNumber,
      totalOvers: totalOvers,
      target: target,
    );

    // The concurrent flush landing mid-read — real rows deleted for real,
    // through the same dao/db the controller's own `watch()` is subscribed
    // to, so `pendingCount` reacts exactly as it would in production. Left
    // for the *caller* to pump/settle afterward — nesting a pumpEventQueue()
    // call inside a Future this same test is also pumping from the outside
    // is a re-entrancy hazard, not a synchronization primitive.
    await dao.clearQueue(matchId: matchId, inningsNumber: inningsNumber);

    return pre;
  }
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
      abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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
        abandonMatchUseCase: AbandonMatchUseCase(matchRepository: mixedRepo),
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
      await mixedRepo.watchScoreUpdatesController.close();
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

    test(
      'a fresh online ack after an offline undo of a synced ball is not '
      'silently dropped by a stale strike-sequence watermark',
      () async {
        // Ball A, ball B: both synced online — B's real ack advances
        // _lastAppliedSeq to 2 (A's own ack already moved it to 1).
        await mixedController.scoreRuns(0);
        await mixedController.scoreRuns(0);
        expect(mixedController.strike.value?.strikerBalls, 2);

        mixedRepo.online = false;
        // Undo B — already-synced, offline branch. Restores the console to
        // ball A's own state (strikerBalls: 1).
        expect(await mixedController.undoLastBall(), isTrue);
        expect(mixedController.strike.value?.strikerBalls, 1);

        mixedRepo.online = true;
        // The queued undo hasn't flushed yet in this test (nothing drives
        // reconnection here), but the fake's own ball count already freed
        // up B's slot the instant the undo was requested — exactly as the
        // real server does once the queued undo actually syncs. So the very
        // next ball scored gets the SAME absoluteBallSeq (2) the original
        // B once had: the exact collision this bug depended on.
        await mixedController.scoreRuns(0);

        expect(
          mixedController.strike.value?.strikerBalls,
          2,
          reason:
              'the new ball\'s real ack must actually apply — a stale '
              '_lastAppliedSeq left over from the undone ball would silently '
              'drop it via the seq <= watermark guard, freezing the striker '
              'on the undo\'s restored value forever',
        );
      },
    );

    test(
      'undoing an already-synced non-zero-run ball offline immediately '
      'reverts totalRuns and overs, not just the ball count',
      () async {
        // Three singles online: 3 runs, 0.3 overs — the exact numbers from
        // the reported repro.
        await mixedController.scoreRuns(1);
        await mixedController.scoreRuns(1);
        await mixedController.scoreRuns(1);
        expect(mixedController.totalRuns.value, 3);
        expect(mixedController.overs.value, '0.3');

        mixedRepo.online = false;
        expect(await mixedController.undoLastBall(), isTrue);

        expect(
          mixedController.totalRuns.value,
          2,
          reason: 'the undone ball\'s own run must come back off the total',
        );
        expect(mixedController.overs.value, '0.2');
      },
    );

    test(
      'a socket score:update landing while a ball\'s own REST ack is still '
      'in flight is not captured as that ball\'s ledger pre-state',
      () async {
        await mixedController.scoreRuns(1);
        await mixedController.scoreRuns(1);

        // Ball 3: the socket "delivers" this exact ball's own broadcast —
        // its POST-state — while scoreBall's REST response is still
        // pending. A real device's socket connection can do exactly this:
        // the server broadcasts the instant it commits, and the REST
        // response to that same request can still be in flight back to the
        // very client that sent it.
        mixedRepo.onScoreBallInFlight = () async {
          mixedRepo.watchScoreUpdatesController.add(
            Either.result(
              LiveScoreRes(
                matchId: 'match-1',
                inningsNumber: 1,
                totalRuns: 3,
                wickets: 0,
                overs: '0.3',
                strike: Strike(
                  strikerName: 'Striker',
                  strikerRuns: 3,
                  strikerBalls: 3,
                  nonStrikerName: 'Non-Striker',
                ),
                lastBall: LastBall(
                  runs: 1,
                  overNumber: 1,
                  ballNumber: 3,
                  absoluteBallSeq: 3,
                ),
              ),
            ),
          );
          // Lets the stream listener's (synchronous) callback actually run
          // before this hook returns and the REST response continues past
          // it — otherwise the event would still be sitting unprocessed in
          // the controller's microtask queue when we resume.
          await Future<void>.delayed(Duration.zero);
        };

        await mixedController.scoreRuns(1);
        expect(mixedController.totalRuns.value, 3);
        expect(mixedController.overs.value, '0.3');

        mixedRepo.online = false;
        expect(await mixedController.undoLastBall(), isTrue);

        expect(
          mixedController.totalRuns.value,
          2,
          reason:
              'undoing ball 3 must revert to ball 3\'s own PRE-state (2 '
              'runs) — a racing socket broadcast landing mid-flight must '
              'not get captured into the ledger row meant to hold that '
              'pre-state instead',
        );
        expect(mixedController.overs.value, '0.2');
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
        abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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
      await repo.watchScoreUpdatesController.close();
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

  group('cold-restart provisional seeding across an innings break', () {
    test(
      'a queued ball in innings 2, with the app killed and relaunched before '
      'reconnecting, seeds the provisional preview from innings 2 — not the '
      '_currentInningsNumber default of 1',
      () async {
        final repo = _MixedMatchRepository();
        final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
        final dao = ScoringQueueDao(db);

        final syncService1 = OfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        );
        final controller1 = ScoreBallController(
          scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
          selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
          undoBallUseCase: UndoBallUseCase(matchRepository: repo),
          abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
          matchRepository: repo,
          offlineSyncService: syncService1,
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

        controller1.onInit();
        await controller1.startInnings(
          strikerName: 'Striker',
          nonStrikerName: 'Non-Striker',
          bowlerName: 'Bumrah',
        );

        // Innings 1 "completed" without ever queuing a single ball for it —
        // exactly like the `offline innings transition` group above. This is
        // what makes the bug reproducible: innings 1's own queue is
        // genuinely empty, so a seed that wrongly targets it (the stale
        // `_currentInningsNumber` default) finds nothing at all, rather than
        // merely the wrong balls.
        await syncService1.recordInningsSummary(
          matchId: 'match-1',
          inningsNumber: 1,
          battingTeam: 'teamA',
          totalRuns: 120,
          wickets: 3,
          overs: '2.0',
        );

        // Go offline, open innings 2 offline, and queue two deliveries for
        // it — everything a scorer would have done before the app died.
        repo.online = false;
        await controller1.startInnings(
          strikerName: 'New Striker',
          nonStrikerName: 'New Non-Striker',
          bowlerName: 'New Bowler',
        );
        await controller1.scoreRuns(4);
        await controller1.scoreRuns(4);

        expect(
          await dao.pendingCount(matchId: 'match-1', inningsNumber: 2),
          2,
          reason: 'sanity check: both deliveries actually queued for innings 2',
        );

        // Simulate the app being killed and relaunched, still offline: a
        // fresh `OfflineSyncService` and a fresh `ScoreBallController`, both
        // starting with `_currentInningsNumber`'s default of 1, backed by
        // the SAME on-disk queue the first controller just wrote to.
        final syncService2 = OfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        );
        final controller2 = ScoreBallController(
          scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
          selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
          undoBallUseCase: UndoBallUseCase(matchRepository: repo),
          abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
          matchRepository: repo,
          offlineSyncService: syncService2,
        );

        controller2.onInit();
        await pumpEventQueue();

        expect(
          controller2.isProvisional.value,
          isTrue,
          reason: 'a non-empty queue must always resume as provisional',
        );
        expect(
          controller2.totalRuns.value,
          8,
          reason:
              'the two queued innings-2 deliveries, not innings 1\'s '
              'finished total of 120 and not a stale zero',
        );
        expect(controller2.strike.value?.strikerName, 'New Striker');

        await repo.watchScoreUpdatesController.close();
        await db.close();
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
        abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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
      await repo.watchScoreUpdatesController.close();
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

  group('full offline match lifecycle, synced once at the end', () {
    test(
      'starting innings 1 online, then scoring and completing BOTH innings '
      'entirely offline, does not manufacture a SYNC_CONFLICT on reconnect',
      () async {
        final repo = _ServerSimulatingMatchRepository(ballsPerInnings: 6);
        final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
        final dao = ScoringQueueDao(db);
        final syncService = OfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        );
        final controller = ScoreBallController(
          scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
          selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
          undoBallUseCase: UndoBallUseCase(matchRepository: repo),
          abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
          matchRepository: repo,
          offlineSyncService: syncService,
        );

        Get.testMode = true;
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

        controller.onInit();

        // 1. Start innings 1 ONLINE.
        expect(
          await controller.startInnings(
            strikerName: 'Striker',
            nonStrikerName: 'Non-Striker',
            bowlerName: 'Bumrah',
          ),
          isTrue,
        );

        // 2. Go offline for the rest of the match.
        repo.online = false;

        // 3/4. Score and complete innings 1 offline — 6 dot balls completes
        // this 1-over innings.
        for (var i = 0; i < 6; i++) {
          await controller.scoreRuns(0);
        }
        expect(controller.isInningsComplete.value, isTrue);

        // 5. Start innings 2, still offline.
        expect(
          await controller.startInnings(
            strikerName: 'New Striker',
            nonStrikerName: 'New Non-Striker',
            bowlerName: 'New Bowler',
          ),
          isTrue,
        );

        // 6. Score and complete innings 2 — and the match — offline too.
        for (var i = 0; i < 6; i++) {
          await controller.scoreRuns(0);
        }
        await pumpEventQueue();

        // 7. Reconnect and sync, exactly as `ResultController.retrySync`
        // does — hardcoding innings 2, the innings the console was last on.
        repo.online = true;
        await syncService.retryNow(matchId: 'match-1', inningsNumber: 2);

        expect(
          syncService.phase.value,
          isNot(SyncPhase.conflict),
          reason:
              'the whole match was scored offline in order; catching up on '
              'reconnect must not manufacture a conflict out of it',
        );
        expect(
          await dao.pendingCount(matchId: 'match-1', inningsNumber: 1),
          0,
          reason:
              'innings 1\'s queue should have flushed before innings 2 '
              'was ever opened for real',
        );
        expect(await dao.pendingCount(matchId: 'match-1', inningsNumber: 2), 0);
        expect(
          await syncService.pendingStartInningsFor(
            matchId: 'match-1',
            inningsNumber: 2,
          ),
          isNull,
          reason:
              'the real start-innings(2) call should have gone out and '
              'succeeded as part of the same reconnect',
        );
        expect(repo.currentInnings, 2);
        expect(repo.innings(1).totalBalls, 6);
        expect(repo.innings(2).totalBalls, 6);

        await repo.watchScoreUpdatesController.close();
        await db.close();
      },
    );

    test(
      'the same full offline lifecycle, but a MULTI-over match — so a '
      'bowler-selection event sits in the queue between overs — still does '
      'not manufacture a SYNC_CONFLICT on reconnect',
      () async {
        final repo = _ServerSimulatingMatchRepository(ballsPerInnings: 12);
        final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
        final dao = ScoringQueueDao(db);
        final syncService = OfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        );
        final controller = ScoreBallController(
          scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
          selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
          undoBallUseCase: UndoBallUseCase(matchRepository: repo),
          abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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

        controller.onInit();

        expect(
          await controller.startInnings(
            strikerName: 'Striker',
            nonStrikerName: 'Non-Striker',
            bowlerName: 'Bumrah',
          ),
          isTrue,
        );

        repo.online = false;

        // Innings 1: over 1 (6 dot balls), a bowler change, then over 2 (6
        // more dot balls) completes the innings.
        for (var i = 0; i < 6; i++) {
          await controller.scoreRuns(0);
        }
        expect(controller.needsBowler.value, isTrue);
        expect(await controller.selectBowler('Second Bowler Innings1'), isTrue);
        for (var i = 0; i < 6; i++) {
          await controller.scoreRuns(0);
        }
        expect(controller.isInningsComplete.value, isTrue);

        expect(
          await controller.startInnings(
            strikerName: 'New Striker',
            nonStrikerName: 'New Non-Striker',
            bowlerName: 'New Bowler',
          ),
          isTrue,
        );

        // Innings 2: same shape — over 1, a bowler change, over 2 completes
        // the innings and the match.
        for (var i = 0; i < 6; i++) {
          await controller.scoreRuns(0);
        }
        expect(
          controller.needsBowler.value,
          isTrue,
          reason:
              '`_lastOverPrompted` is innings-scoped in the wire protocol '
              '(`overNumber` resets to 1 each innings) but was never reset '
              'on this side — left stale from innings 1, innings 2\'s own '
              'over 1 completing would read as `1 <= _lastOverPrompted` and '
              'silently skip the new-bowler prompt entirely',
        );
        expect(await controller.selectBowler('Second Bowler Innings2'), isTrue);
        for (var i = 0; i < 6; i++) {
          await controller.scoreRuns(0);
        }
        await pumpEventQueue();

        repo.online = true;
        await syncService.retryNow(matchId: 'match-1', inningsNumber: 2);

        expect(
          syncService.phase.value,
          isNot(SyncPhase.conflict),
          reason:
              'a bowler-selection event sitting between two overs\' worth of '
              'balls must not throw off the ahead/resume accounting on '
              'reconnect',
        );
        expect(await dao.pendingCount(matchId: 'match-1', inningsNumber: 1), 0);
        expect(await dao.pendingCount(matchId: 'match-1', inningsNumber: 2), 0);
        expect(repo.currentInnings, 2);
        expect(repo.innings(1).totalBalls, 12);
        expect(repo.innings(2).totalBalls, 12);

        await repo.watchScoreUpdatesController.close();
        await db.close();
      },
    );
  });

  group('resolving a blocked-on-rule sync state', () {
    test(
      'undoBackToBlockedBall clears every queued ball back through the one '
      'that failed a rule check, and returns sync to idle',
      () async {
        final repo = _RuleBlockingMatchRepository();
        final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
        final dao = ScoringQueueDao(db);
        final syncService = OfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        );
        final controller = ScoreBallController(
          scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
          selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
          undoBallUseCase: UndoBallUseCase(matchRepository: repo),
          abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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

        // Deliberately onInit() only — see the earlier setUp's own comment
        // on why onReady() (which wires the bottom-sheet-opening `ever`
        // listeners) would only add unrelated navigation machinery here.
        controller.onInit();
        await controller.startInnings(
          strikerName: 'Striker',
          nonStrikerName: 'Non-Striker',
          bowlerName: 'Bumrah',
        );

        // Two balls queue offline — every scoreBall call in this fake
        // always fails with no-internet.
        await controller.scoreRuns(1);
        await controller.scoreRuns(4);
        await pumpEventQueue();
        expect(syncService.pendingCount.value, 2);

        // The sync attempt reports the first (oldest) queued ball failed a
        // genuine rule check. Nothing commits, so both balls stay queued.
        await syncService.retryNow(matchId: 'match-1', inningsNumber: 1);

        expect(syncService.phase.value, SyncPhase.blockedOnRule);
        expect(
          syncService.lastError.value,
          'BOWLER_CANNOT_BOWL_CONSECUTIVE_OVERS',
        );
        expect(
          syncService.pendingCount.value,
          2,
          reason: 'nothing committed — the failing event is still queued',
        );

        await controller.undoBackToBlockedBall();

        expect(
          syncService.pendingCount.value,
          0,
          reason:
              'both queued balls — including the one that failed the rule '
              'check — must be gone; retrying could only fail identically',
        );
        expect(syncService.phase.value, SyncPhase.idle);
        expect(syncService.lastError.value, isNull);

        await db.close();
      },
    );
  });

  group('abandonMatch', () {
    Future<({ScoreBallController controller, _OfflineMatchRepository repo})>
    buildAbandonableController() async {
      final repo = _OfflineMatchRepository();
      final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      final dao = ScoringQueueDao(db);
      final syncService = OfflineSyncService(
        dao: dao,
        syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
      );
      final controller = ScoreBallController(
        scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
        undoBallUseCase: UndoBallUseCase(matchRepository: repo),
        abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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

      // onInit() only — see the file's earlier setUp comment on why
      // onReady()'s bottom-sheet-opening listeners are irrelevant here.
      controller.onInit();

      return (controller: controller, repo: repo);
    }

    test(
      'a successful abandon marks the match complete, closing the console '
      'the same way a normal match:complete does',
      () async {
        final built = await buildAbandonableController();
        built.repo.abandonMatchResponse = Either.result(
          CricketResponse(
            message: 'ok',
            data: AbandonMatchRes(matchId: 'match-1', status: 'abandoned'),
          ),
        );

        expect(built.controller.isMatchComplete.value, isFalse);
        await built.controller.abandonMatch();

        expect(built.controller.isAbandoning.value, isFalse);
        expect(
          built.controller.isMatchComplete.value,
          isTrue,
          reason:
              'this is what stops _promptIfNeeded from continuing to '
              'treat the console as a live match once it navigates away',
        );
      },
    );

    // The failure path (isResult == false) is not covered here: it calls
    // CricketSnackbar.showErrorMessage, which needs a real Overlay/widget
    // tree to show against — this file's whole pattern is deliberately
    // onInit()-only, no pumped widget tree, so that call throws a null-check
    // error from GetX's snackbar queue outside one. Verified manually
    // instead (abandoning an already-ended match against the real backend).
  });

  group('selectBowler bowlerId disambiguation', () {
    Future<({ScoreBallController controller, _OfflineMatchRepository repo})>
    buildController() async {
      final repo = _OfflineMatchRepository();
      final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      final dao = ScoringQueueDao(db);
      final syncService = OfflineSyncService(
        dao: dao,
        syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
      );
      final controller = ScoreBallController(
        scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
        undoBallUseCase: UndoBallUseCase(matchRepository: repo),
        abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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

      controller.onInit();

      return (controller: controller, repo: repo);
    }

    test(
      'a bowler picked by bare name sends no bowlerId and is remembered '
      'with the id the server assigns',
      () async {
        final built = await buildController();
        built.repo.selectBowlerResponse = Either.result(
          CricketResponse(
            message: 'ok',
            data: SelectBowlerRes(
              matchId: 'match-1',
              inningsId: 'innings-1',
              overNumber: 2,
              bowler: Bowler(bowlerId: 'bowler-rahul', bowlerName: 'Rahul'),
            ),
          ),
        );

        final result = await built.controller.selectBowler('Rahul');

        expect(result, isTrue);
        expect(
          built.repo.lastSelectBowlerReq?.bowlerId,
          isNull,
          reason: 'a freshly-typed name names a new player, not a known one',
        );
        expect(
          built.controller.bowlersSeen.any(
            (b) => b.id == 'bowler-rahul' && b.name == 'Rahul',
          ),
          isTrue,
          reason:
              'the id the server assigned must be retained, not just the '
              'name, so a later re-pick of the same chip can reference it',
        );
      },
    );

    test(
      'picking a known bowler by id sends that exact id, not just the name',
      () async {
        final built = await buildController();
        built.repo.selectBowlerResponse = Either.result(
          CricketResponse(
            message: 'ok',
            data: SelectBowlerRes(
              matchId: 'match-1',
              inningsId: 'innings-1',
              overNumber: 4,
              bowler: Bowler(bowlerId: 'bowler-rahul', bowlerName: 'Rahul'),
            ),
          ),
        );

        final result = await built.controller.selectBowler(
          'Rahul',
          bowlerId: 'bowler-rahul',
        );

        expect(result, isTrue);
        expect(built.repo.lastSelectBowlerReq?.bowlerId, 'bowler-rahul');
      },
    );
  });

  group('onClose disposes ever() workers on the shared OfflineSyncService', () {
    test(
      'a zombie controller (onClose already called, no longer on screen) '
      'does not react when the singleton it used to watch reports a later '
      'match\'s sync activity',
      () async {
        final repo = _OfflineMatchRepository();
        final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
        final dao = ScoringQueueDao(db);
        final syncService = OfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        );
        final controller = ScoreBallController(
          scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
          selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
          undoBallUseCase: UndoBallUseCase(matchRepository: repo),
          abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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

        // onReady() is what registers the five `ever()` workers under test —
        // safe to call here because `_OfflineMatchRepository.watchScoreUpdates`
        // is `Stream.empty()`, so `_serverStateArrived` never flips and
        // `_promptIfNeeded()` breaks out immediately without touching a
        // (nonexistent) widget tree.
        controller.onInit();
        controller.onReady();
        await pumpEventQueue();

        // Simulates GetX tearing this controller down after the scorer
        // navigates away from this match's console — exactly what happens on
        // every route pop.
        controller.onClose();

        expect(controller.totalRuns.value, 0);

        // A LATER match's sync flush landing on the same, shared,
        // fenix-registered singleton — the only way this fires in
        // production, since OfflineSyncService is a GetxService, not scoped
        // per match.
        syncService.lastAppliedState.value = SyncState(
          inningsTotals: InningsTotals(
            totalRuns: 999,
            wickets: 9,
            legalBalls: 118,
            totalBalls: 120,
            oversCompleted: 19,
            extras: ExtrasBreakdown(),
          ),
          overs: '19.6',
        );

        expect(
          controller.totalRuns.value,
          0,
          reason:
              'before the fix, the undisposed ever(lastAppliedState, ...) '
              'worker registered in onReady() would still fire here and '
              'overwrite this dead controller\'s totals with a completely '
              'unrelated match\'s',
        );

        await db.close();
      },
    );
  });

  group('cold-restart seed vs. a concurrent flush of the same queue', () {
    test(
      'does not repaint the console with a stale offline snapshot once the '
      'queue it describes has already been flushed for real',
      () async {
        final repo = _OfflineMatchRepository();
        final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
        final dao = ScoringQueueDao(db);
        final syncService = _RaceyOfflineSyncService(
          dao: dao,
          syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
        );
        final controller = ScoreBallController(
          scoreBallUseCase: ScoreBallUseCase(matchRepository: repo),
          startInningsUseCase: StartInningsUseCase(matchRepository: repo),
          selectBowlerUseCase: SelectBowlerUseCase(matchRepository: repo),
          undoBallUseCase: UndoBallUseCase(matchRepository: repo),
          abandonMatchUseCase: AbandonMatchUseCase(matchRepository: repo),
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

        // A queued ball from before the app was killed — exactly what
        // `_seedProvisionalStateIfQueued` exists to resume from.
        await dao.enqueueBall(
          matchId: 'match-1',
          inningsNumber: 1,
          req: ScoreBallReq(runs: 4, idempotencyKey: 'k1'),
          pre: const PreEventState(
            totalRuns: 0,
            wickets: 0,
            legalBalls: 0,
            totalBalls: 0,
            oversCompleted: 0,
            overTotalRuns: 0,
            overLegalDeliveries: 0,
          ),
        );

        controller.onInit();
        // _RaceyOfflineSyncService clears the queue for real from inside
        // the seed's own read, before that read even returns — by the time
        // onInit's async chain finishes, the race has already happened.
        await pumpEventQueue();

        expect(
          controller.isProvisional.value,
          isFalse,
          reason:
              'before the fix, this unconditionally applied the stale '
              'snapshot the read had already captured, regardless of the '
              'queue having been flushed out from under it in the meantime',
        );
        expect(controller.totalRuns.value, 0);

        await db.close();
      },
    );
  });
}
