import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/abandon_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_abandoned_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/delete_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_organization_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorer_candidates_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/assign_scorer_res.dart';

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

  /// Applies an ordered batch of events queued while offline. See
  /// docs/api.md's sync section — a lost response is safe to retry (its own
  /// keys are recognised and skipped), an individually-bad event stops the
  /// batch where it is (`failedAt`/`failedCode`) rather than rejecting
  /// everything, and a genuine conflict — the server holding deliveries this
  /// client never queued — refuses the batch whole via [CricketConflictFailure].
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> syncMatch({
    required String matchId,
    required SyncReq? syncReq,
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

  /// `GET /v1/player/:playerId/career-stats` — a Player's totals across
  /// every completed match its scorer has recorded. Not match-scoped; see
  /// `MatchEndpoint.careerStats`'s own comment on why this lives here anyway.
  Future<Either<CricketResponse<CareerStatsRes>, CricketFailure>>
  getCareerStats({required String playerId});

  /// The `match:complete` event — see [MatchSocketService.watchMatchComplete].
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  });

  /// The `match:abandoned` event — see
  /// [MatchSocketService.watchMatchAbandoned]. Only the spectator screen
  /// subscribes: the scorer's own console already learns this from
  /// `abandonMatch`'s REST ack.
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  });

  /// `GET /v1/match/history` — the caller's own matches, newest first,
  /// paginated. Feeds the history/home screen; a card's `status` is what
  /// decides whether tapping it reopens the scoring console or the result
  /// screen.
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit});

  /// `POST /v1/match/:matchId/abandon` — a live/innings-break match that will
  /// never finish (rain, a no-show). Generates a best-effort partial
  /// scorecard server-side and notifies any connected spectators via
  /// `match:abandoned`; see docs/api.md.
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId});

  /// `DELETE /v1/match/:matchId` — soft-delete, any status. No socket
  /// emission: a spectator on a deleted match just finds the next public
  /// read 404s, same as an unknown code.
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> deleteMatch({
    required String matchId,
  });

  /// `GET /v1/team` — the caller's own teams, source for the "reuse this
  /// team" picker on match creation.
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> getMyTeams();

  /// `GET /v1/team/:teamId` — display name plus the roster accumulated
  /// across every match this team has been attached to.
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>>
  getTeamProfile({required String teamId});

  /// `GET /v1/team/:teamId/matches` — byte-for-byte the same response shape
  /// as [getMatchHistory], scoped to one team instead of the caller.
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamMatches({required String teamId, required int page, required int limit});

  /// `PATCH /v1/team/:teamId/organization` — attach an existing standalone
  /// team the caller owns to an org the caller owns, or detach (pass
  /// `organizationId: null`) back to standalone.
  Future<Either<CricketResponse<TeamOrganizationRes>, CricketFailure>>
  updateTeamOrganization({
    required String teamId,
    required String? organizationId,
  });

  /// `GET /v1/match/:matchId/scorer-candidates` — see docs/api.md's
  /// delegated-scoring contract. Empty when neither team is org-linked;
  /// `CricketForbiddenErrorFailure` when the caller has no assign-authority
  /// at all on this match.
  Future<Either<CricketResponse<ScorerCandidatesRes>, CricketFailure>>
  getScorerCandidates({required String matchId});

  /// `PATCH /v1/match/:matchId/scorer` — assign/reassign (`scorerId`) or
  /// clear (`scorerId: null`) the match's delegated scorer.
  Future<Either<CricketResponse<AssignScorerRes>, CricketFailure>>
  assignScorer({required String matchId, required String? scorerId});
}
