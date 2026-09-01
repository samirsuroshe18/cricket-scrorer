import 'dart:async';
import 'dart:io';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/login_request_model.dart';
import 'package:cricket_scorer/features/auth/data/models/login_response.dart';
import 'package:cricket_scorer/features/auth/data/models/request/forgot_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/register_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/set_pass_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/update_profile_req.dart';
import 'package:cricket_scorer/features/auth/data/models/request/verify_otp_req.dart';
import 'package:cricket_scorer/features/auth/data/models/response/verify_otp_res.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/logout.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
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
import 'package:cricket_scorer/features/scoring/data/models/response/match_abandoned_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_history.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every method throws — `HomeController` needs a `LogoutUseCase` in its
/// constructor, but logout is never exercised by these tests.
class _UnusedAuthRepository implements AuthRepository {
  @override
  Future<Either<CricketResponse<LoginResponse>, CricketFailure>> login({
    required LoginModel? loginModel,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<User>, CricketFailure>> getUser() =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> forgotPassword({
    required ForgotPassReq? forgotPass,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<VerifyOtpRes>, CricketFailure>> verifyOtp({
    required VerifyOtpReq? verifyOtp,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  resendOtp({required VerifyOtpReq? resendOtp}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  register({required RegisterReq? registerParam}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  setPass({required SetPassReq? params}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  updateProfile({required UpdateProfileReq? params, File? file}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  logout({required String? refreshToken}) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// `getMatchHistory` and `deleteMatch` are controllable per test; every
/// other method throws — nothing else on `MatchRepository` is exercised by
/// `HomeController`.
class _FakeMatchRepository implements MatchRepository {
  Either<CricketResponse<MatchHistoryRes>, CricketFailure>? historyResponse;
  Either<CricketResponse<DeleteMatchRes>, CricketFailure>? deleteResponse;

  /// Set by a test that needs to observe the in-flight window instead of an
  /// instantaneous resolve — [getMatchHistory] awaits this future when
  /// present, checked ahead of [historyResponse].
  Completer<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>?
  historyCompleter;

  /// How many times [getMatchHistory] was actually invoked — the way a test
  /// proves a second overlapping call never reached the repository at all,
  /// not just that its result didn't win.
  int historyCallCount = 0;

  /// Set by a test that needs to observe the in-flight window instead of an
  /// instantaneous resolve — [deleteMatch] awaits this future when present,
  /// checked ahead of [deleteResponse].
  Completer<Either<CricketResponse<DeleteMatchRes>, CricketFailure>>?
  deleteCompleter;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getMatchHistory({required int page, required int limit}) async {
    historyCallCount += 1;
    final completer = historyCompleter;
    if (completer != null) return completer.future;
    final response = historyResponse;
    if (response == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return response;
  }

  @override
  Future<Either<CricketResponse<DeleteMatchRes>, CricketFailure>>
  deleteMatch({required String matchId}) async {
    final completer = deleteCompleter;
    if (completer != null) return completer.future;
    final response = deleteResponse;
    if (response == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return response;
  }

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
  getPublicMatch({required String code}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  }) => throw UnimplementedError('Not exercised in this test.');

  @override
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  }) => const Stream.empty();

  @override
  Stream<Either<MatchAbandonedRes, CricketFailure>> watchMatchAbandoned({
    required String matchId,
  }) => const Stream.empty();

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>>
  abandonMatch({required String matchId}) =>
      throw UnimplementedError('Not exercised in this test.');
}

MatchHistoryItem _item(String matchId, {String status = 'live'}) =>
    MatchHistoryItem(
      matchId: matchId,
      teamA: TeamRef(id: 'team-a', name: 'Team A'),
      teamB: TeamRef(id: 'team-b', name: 'Team B'),
      totalOvers: 5,
      status: status,
      createdAt: '2026-08-20T10:15:00.000Z',
    );

void main() {
  late _FakeMatchRepository repo;
  late HomeController controller;

  setUp(() {
    repo = _FakeMatchRepository();
    controller = HomeController(
      logoutUseCase: LogoutUseCase(authRepository: _UnusedAuthRepository()),
      getMatchHistoryUseCase: GetMatchHistoryUseCase(matchRepository: repo),
      deleteMatchUseCase: DeleteMatchUseCase(matchRepository: repo),
    );
  });

  test('loadHistory populates matches from the first page', () async {
    repo.historyResponse = Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(
          matches: [_item('match-1'), _item('match-2')],
          page: 1,
          limit: 20,
          total: 2,
        ),
      ),
    );

    await controller.loadHistory();

    expect(controller.matches.length, 2);
    expect(controller.isLoading.value, isFalse);
    expect(controller.hasMore.value, isFalse);
    expect(controller.loadError.value, isNull);
  });

  test(
    'loadHistory sets loadError and leaves matches empty on failure',
    () async {
      repo.historyResponse = Either.fallback(
        CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
      );

      await controller.loadHistory();

      expect(controller.matches, isEmpty);
      expect(controller.loadError.value, 'Server error');
    },
  );

  test(
    'deleteMatch removes the matching card from the list on success',
    () async {
      repo.historyResponse = Either.result(
        CricketResponse(
          message: 'ok',
          data: MatchHistoryRes(
            matches: [_item('match-1'), _item('match-2')],
            page: 1,
            limit: 20,
            total: 2,
          ),
        ),
      );
      await controller.loadHistory();
      expect(controller.matches.length, 2);

      repo.deleteResponse = Either.result(
        CricketResponse(
          message: 'ok',
          data: DeleteMatchRes(matchId: 'match-1'),
        ),
      );

      await controller.deleteMatch(_item('match-1'));

      expect(controller.matches.length, 1);
      expect(controller.matches.single.matchId, 'match-2');
      expect(
        controller.deletingMatchIds,
        isEmpty,
        reason: 'the in-flight marker must clear once the request settles',
      );
    },
  );

  test(
    'deleteMatch tracks the matchId as in-flight for the duration of the request',
    () async {
      final completer = Completer<
        Either<CricketResponse<DeleteMatchRes>, CricketFailure>
      >();
      repo.historyResponse = Either.result(
        CricketResponse(
          message: 'ok',
          data: MatchHistoryRes(
            matches: [_item('match-1')],
            page: 1,
            limit: 20,
            total: 1,
          ),
        ),
      );
      await controller.loadHistory();

      // Route deleteMatch through the completer instead of a canned Either,
      // so the in-flight window is observable rather than instantaneous.
      repo.deleteCompleter = completer;
      final future = controller.deleteMatch(_item('match-1'));

      await Future<void>.delayed(Duration.zero);
      expect(controller.deletingMatchIds, contains('match-1'));

      completer.complete(
        Either.result(
          CricketResponse(
            message: 'ok',
            data: DeleteMatchRes(matchId: 'match-1'),
          ),
        ),
      );
      await future;

      expect(controller.deletingMatchIds, isEmpty);
    },
  );

  // loadHistory had no in-flight guard, unlike loadMore — a rapid double
  // pull-to-refresh (or a refresh landing while the initial onInit load was
  // still going) fired two independent requests, and whichever RESOLVED
  // last won, not whichever was SENT last. A slower first response landing
  // after a faster, fresher second one would silently regress the list back
  // to stale data.
  test(
    'a second loadHistory call while one is already in flight is a no-op, '
    'same as loadMore',
    () async {
      final completer =
          Completer<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>();
      repo.historyCompleter = completer;

      final first = controller.loadHistory();
      await Future<void>.delayed(Duration.zero);
      expect(repo.historyCallCount, 1);

      // The second call must return immediately without ever reaching the
      // repository — proving the guard, not just that its result lost a race.
      final second = controller.loadHistory();
      await second;
      expect(repo.historyCallCount, 1);

      completer.complete(
        Either.result(
          CricketResponse(
            message: 'ok',
            data: MatchHistoryRes(
              matches: [_item('match-1')],
              page: 1,
              limit: 20,
              total: 1,
            ),
          ),
        ),
      );
      await first;

      expect(controller.matches.length, 1);
      expect(controller.isLoading.value, isFalse);
    },
  );
}
