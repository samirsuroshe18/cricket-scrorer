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
}
