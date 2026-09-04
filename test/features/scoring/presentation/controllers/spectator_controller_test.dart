import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/abandon_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/delete_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_abandoned_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_public_match.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/spectator_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

/// `getPublicMatch` is controllable per test; `watchScoreUpdates` hands out a
/// fresh, independently-controlled stream on every call, so a test can
/// observe whether an *earlier* call's stream is still being listened to.
/// Every other method throws — nothing else here is exercised by
/// [SpectatorController].
class _FakeMatchRepository implements MatchRepository {
  Either<CricketResponse<PublicMatchRes>, CricketFailure>? publicMatchResponse;

  final scoreUpdateControllers =
      <StreamController<Either<LiveScoreRes, CricketFailure>>>[];

  @override
  Future<Either<CricketResponse<PublicMatchRes>, CricketFailure>>
  getPublicMatch({required String code}) async {
    final response = publicMatchResponse;
    if (response == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return response;
  }

  @override
  Stream<Either<LiveScoreRes, CricketFailure>> watchScoreUpdates({
    required String matchId,
  }) {
    final controller =
        StreamController<Either<LiveScoreRes, CricketFailure>>();
    scoreUpdateControllers.add(controller);
    return controller.stream;
  }

  @override
  Stream<Either<OverCompleteRes, CricketFailure>> watchOverComplete({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<ScoreUndoRes, CricketFailure>> watchScoreUndo({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> createMatch({
    required CreateMatchReq? createMatchReq,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>>
  startInnings({
    required String matchId,
    required StartInningsReq? startInningsReq,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>>
  selectBowler({
    required String matchId,
    required SelectBowlerReq? selectBowlerReq,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<ScoreBallRes>, CricketFailure>> scoreBall({
    required String matchId,
    required ScoreBallReq? scoreBallReq,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? undoBallReq,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> syncMatch({
    required String matchId,
    required SyncReq? syncReq,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<CareerStatsRes>, CricketFailure>>
  getCareerStats({required String playerId}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>> deleteMatch({
    required String matchId,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> getMyTeams() =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>>
  getTeamProfile({required String teamId}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamMatches({
    required String teamId,
    required int page,
    required int limit,
  }) => throw UnimplementedError('Not exercised in this test.');
}

PublicMatchInfo _matchInfo() => PublicMatchInfo(
  matchId: 'match-1',
  teamA: PublicTeamRef(name: 'Team A'),
  teamB: PublicTeamRef(name: 'Team B'),
  totalOvers: 5,
  status: 'live',
  currentInnings: 1,
);

LiveScoreRes _liveEvent({required int totalRuns}) => LiveScoreRes(
  matchId: 'match-1',
  inningsNumber: 1,
  totalRuns: totalRuns,
  wickets: 0,
  overs: '0.0',
);

void main() {
  // _subscribeToLiveUpdates (called from _load, on both onInit and a
  // successful retry()) reassigned _scoreSub/etc with no cancel() of
  // whatever was there before. Only ever reachable via retry() after a
  // FAILED load given today's UI wiring (subscriptions are only created
  // after a successful load) — but nothing at the controller level
  // prevents a second successful load from creating a second, independent
  // set of subscriptions, leaking the first.
  test(
    'a second successful load stops listening to the first load\'s score stream',
    () async {
      final repo = _FakeMatchRepository();
      repo.publicMatchResponse = Either.result(
        CricketResponse(
          message: 'ok',
          data: PublicMatchRes(match: _matchInfo(), innings: null),
        ),
      );

      final controller = SpectatorController(
        getPublicMatchUseCase: GetPublicMatchUseCase(matchRepository: repo),
        matchRepository: repo,
      );

      Get.testMode = true;
      Get.parameters = {'code': 'ABC123'};

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      expect(repo.scoreUpdateControllers.length, 1);

      // A second successful load — not reachable via today's UI (retry()
      // only shows after a failure), but not prevented at this level either.
      await controller.retry();
      expect(repo.scoreUpdateControllers.length, 2);

      final firstStream = repo.scoreUpdateControllers[0];
      final secondStream = repo.scoreUpdateControllers[1];

      // The first subscription must be gone — proven by checking Dart's own
      // stream-controller bookkeeping, not just this controller's Rx state,
      // so the assertion holds regardless of what either handler does.
      expect(
        firstStream.hasListener,
        isFalse,
        reason:
            'the earlier subscription must be cancelled once a new one is '
            'created, or the controller leaks a listener on every reload',
      );
      expect(secondStream.hasListener, isTrue);

      firstStream.add(Either.result(_liveEvent(totalRuns: 999)));
      await Future<void>.delayed(Duration.zero);
      expect(
        controller.totalRuns.value,
        isNot(999),
        reason: 'a stale, uncancelled subscription must not still drive state',
      );

      secondStream.add(Either.result(_liveEvent(totalRuns: 42)));
      await Future<void>.delayed(Duration.zero);
      expect(controller.totalRuns.value, 42);

      await firstStream.close();
      await secondStream.close();
    },
  );
}
