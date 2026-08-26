import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';

abstract class MatchRepository {
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> createMatch({
    required CreateMatchReq? createMatchReq,
  });

  /// Opens the innings and puts two batsmen at the crease. Must succeed before
  /// [scoreBall] will be accepted — the server rejects a delivery with
  /// `INNINGS_NOT_STARTED` until openers exist.
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>>
  startInnings({
    required String matchId,
    required StartInningsReq? startInningsReq,
  });

  /// Names the bowler for the over that has not started yet. Required after
  /// every over: completing one clears the server's bowler pointer, and
  /// [scoreBall] then rejects with `BOWLER_NOT_SELECTED` until this succeeds.
  ///
  /// Rejects the previous over's bowler with
  /// `BOWLER_CANNOT_BOWL_CONSECUTIVE_OVERS` (Law 17.6) and a name change after
  /// the over's first delivery with `OVER_ALREADY_STARTED`.
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>>
  selectBowler({
    required String matchId,
    required SelectBowlerReq? selectBowlerReq,
  });

  Future<Either<CricketResponse<ScoreBallRes>, CricketFailure>> scoreBall({
    required String matchId,
    required ScoreBallReq? scoreBallReq,
  });

  /// Removes the most recent delivery and returns the innings as it stood
  /// before it, restored server-side from the snapshot that ball carried.
  ///
  /// Only the latest ball is undoable — an older one is refused with
  /// `BALL_NOT_LATEST`. The named ball being already gone is **not** an error:
  /// it answers `200` with `alreadyUndone` and the current state, which is what
  /// makes a double tap on patchy signal safe.
  ///
  /// The response is a complete state snapshot. Nothing about the reversal is
  /// computed on this side.
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? undoBallReq,
  });

  /// Live score updates for [matchId], driven by the `match:state`/`score:update`
  /// socket events. No usecase wraps this — the base `UseCase<T, P>` contract is
  /// `Future<T> call(...)`, a bad fit for a stream, and there's no other
  /// streaming precedent in this codebase to extend.
  Stream<Either<LiveScoreRes, CricketFailure>> watchScoreUpdates({
    required String matchId,
  });

  /// The `over:complete` event. A separate stream rather than another case in
  /// [watchScoreUpdates] because the payload is a different shape — folding it
  /// into `LiveScoreRes` would mean making most of that model nullable to
  /// describe two unrelated events.
  ///
  /// For the scorer's console this is a recovery path, not the primary trigger:
  /// the REST ack already carries `nextBowler`. It matters when that ack is
  /// lost on patchy signal, which is the case this product exists for.
  Stream<Either<OverCompleteRes, CricketFailure>> watchOverComplete({
    required String matchId,
  });

  /// The `score:undo` event. For the spectator view this is not a recovery
  /// path — it is the ONLY way an undo reaches a spectator, since there is no
  /// REST ack to fall back on the way the scorer's console has.
  Stream<Either<ScoreUndoRes, CricketFailure>> watchScoreUndo({
    required String matchId,
  });

  /// `GET /v1/match/public/:code` — the entire unauthenticated read surface.
  /// Takes either half of a share link, told apart server-side by shape; see
  /// docs/api.md. No ownership check exists for this call because none is
  /// meant to: it is public by contract, not by omission.
  Future<Either<CricketResponse<PublicMatchRes>, CricketFailure>>
  getPublicMatch({required String code});

  /// `GET /v1/match/:matchId/scorecard` — both innings' finalized batting and
  /// bowling figures plus the match result. Reachable only once the match has
  /// actually completed; the server answers `SCORECARD_NOT_READY` otherwise.
  /// The single data source for the result screen, whether it was opened
  /// automatically on `match:complete` or by direct navigation later.
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  });

  /// The `match:complete` event — see [MatchSocketService.watchMatchComplete].
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  });
}
