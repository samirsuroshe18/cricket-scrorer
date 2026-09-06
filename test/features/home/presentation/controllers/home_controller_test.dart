import 'dart:async';
import 'dart:io';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
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
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_organization_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorer_candidates_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/assign_scorer_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_history.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

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

/// `logout` is controllable per test (a canned result, or made to throw);
/// every other method throws — nothing else on `AuthRepository` is exercised
/// by `HomeController.logout`.
class _FakeAuthRepository implements AuthRepository {
  Either<CricketResponse<Map<String, dynamic>>, CricketFailure>?
  logoutResponse;
  Object? logoutThrows;

  @override
  Future<Either<CricketResponse<Map<String, dynamic>>, CricketFailure>>
  logout({required String? refreshToken}) async {
    final throwable = logoutThrows;
    if (throwable != null) throw throwable;
    final response = logoutResponse;
    if (response == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return response;
  }

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
}

/// Never touches the real `flutter_secure_storage` platform channel.
class _FakeSecureStorageService extends SecureStorageService {
  bool clearForLogoutCalled = false;

  @override
  Future<String?> get(String key) async => 'a-refresh-token';

  @override
  Future<void> clearForLogout() async {
    clearForLogoutCalled = true;
  }
}

/// Never touches the real `SharedPreferences` platform channel.
class _FakeSharedPreferenceService extends SharedPreferenceService {
  bool clearForLogoutCalled = false;

  @override
  Future<void> clearForLogout() async {
    clearForLogoutCalled = true;
  }
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
  Future<Either<CricketResponse<CareerStatsRes>, CricketFailure>>
  getCareerStats({required String playerId}) =>
      throw UnimplementedError('Not exercised in this test.');

  @override
  Future<Either<CricketResponse<PlayerProfileRes>, CricketFailure>>
  updatePlayer({required String playerId, required UpdatePlayerReq params}) =>
      throw UnimplementedError('Not exercised in this test.');

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

  @override
  Future<Either<CricketResponse<TeamOrganizationRes>, CricketFailure>>
  updateTeamOrganization({
    required String teamId,
    required String? organizationId,
  }) => throw UnimplementedError('Not exercised in this test.');

  Either<CricketResponse<ScorerCandidatesRes>, CricketFailure>?
  scorerCandidatesResponse;
  Either<CricketResponse<AssignScorerRes>, CricketFailure>?
  assignScorerResponse;

  @override
  Future<Either<CricketResponse<ScorerCandidatesRes>, CricketFailure>>
  getScorerCandidates({required String matchId}) async {
    final response = scorerCandidatesResponse;
    if (response == null) throw UnimplementedError('Not exercised in this test.');
    return response;
  }

  @override
  Future<Either<CricketResponse<AssignScorerRes>, CricketFailure>>
  assignScorer({required String matchId, required String? scorerId}) async {
    final response = assignScorerResponse;
    if (response == null) throw UnimplementedError('Not exercised in this test.');
    return response;
  }
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
      getScorerCandidatesUseCase: GetScorerCandidatesUseCase(
        matchRepository: repo,
      ),
      assignScorerUseCase: AssignScorerUseCase(matchRepository: repo),
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

  // A refresh's GET can be sent while a delete's request hasn't yet
  // committed server-side. If that refresh's own response — a snapshot from
  // before the delete landed — arrives while the delete is still in
  // flight, loadHistory's plain matches.assignAll(...) used to resurrect
  // the card the scorer just asked to delete, until the delete itself
  // settled (removing it again) or the next refresh corrected it. Not
  // data-corrupting, but a visible flicker/regression.
  test(
    'loadHistory does not resurrect a card whose delete is still in flight',
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

      final deleteCompleter = Completer<
        Either<CricketResponse<DeleteMatchRes>, CricketFailure>
      >();
      repo.deleteCompleter = deleteCompleter;
      final deleteFuture = controller.deleteMatch(_item('match-1'));
      await Future<void>.delayed(Duration.zero);
      expect(controller.deletingMatchIds, contains('match-1'));

      // A refresh landing while that delete is still unsettled — its own
      // response still lists match-1, exactly what a request sent before
      // the delete committed would look like.
      await controller.loadHistory();

      expect(
        controller.matches.map((m) => m.matchId),
        isNot(contains('match-1')),
        reason:
            'a card actively being deleted must not reappear just because '
            'a concurrent refresh has not caught up yet',
      );

      deleteCompleter.complete(
        Either.result(
          CricketResponse(
            message: 'ok',
            data: DeleteMatchRes(matchId: 'match-1'),
          ),
        ),
      );
      await deleteFuture;

      expect(controller.deletingMatchIds, isEmpty);
      expect(controller.matches.map((m) => m.matchId), isNot(contains('match-1')));
    },
  );

  test('loadScorerCandidates returns the candidate list on success', () async {
    repo.scorerCandidatesResponse = Either.result(
      CricketResponse(
        message: 'ok',
        data: ScorerCandidatesRes(
          candidates: [MatchUserRef(id: 'user-1', name: 'Raj')],
        ),
      ),
    );

    final candidates = await controller.loadScorerCandidates('match-1');

    expect(candidates?.length, 1);
    expect(candidates?.first.name, 'Raj');
  });

  test('assignScorer updates the cached match on success', () async {
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
    repo.assignScorerResponse = Either.result(
      CricketResponse(
        message: 'ok',
        data: AssignScorerRes(
          matchId: 'match-1',
          assignedScorer: MatchUserRef(id: 'user-1', name: 'Raj'),
        ),
      ),
    );

    final success = await controller.assignScorer('match-1', 'user-1');

    expect(success, isTrue);
    expect(controller.matches.first.assignedScorer?.name, 'Raj');
  });

  // logout used to only clear the local session and navigate to login on a
  // *successful* server response — a network hiccup, a server error, or the
  // call throwing outright all left the console apparently still signed in,
  // showing only an error snackbar. On a route that shares this device's
  // session with every other in-flight request, that could also land
  // alongside AuthInterceptor's own forced "session expired" redirect if the
  // access token happened to be expired at the same moment — a contradictory
  // "logout failed" toast next to a redirect that says the opposite. Signing
  // out is now unconditional: the local session clears and the console
  // returns to login regardless of what the server call did.
  group('logout', () {
    late _FakeAuthRepository authRepo;
    late _FakeSecureStorageService secureStorage;
    late _FakeSharedPreferenceService sharedPref;

    setUp(() {
      authRepo = _FakeAuthRepository();
      secureStorage = _FakeSecureStorageService();
      sharedPref = _FakeSharedPreferenceService();
      Get.put<SecureStorageService>(secureStorage);
      Get.put<SharedPreferenceService>(sharedPref);
    });

    tearDown(Get.reset);

    Future<HomeController> pumpHarness(WidgetTester tester) async {
      final homeController = HomeController(
        logoutUseCase: LogoutUseCase(authRepository: authRepo),
        getMatchHistoryUseCase: GetMatchHistoryUseCase(
          matchRepository: _FakeMatchRepository(),
        ),
        deleteMatchUseCase: DeleteMatchUseCase(
          matchRepository: _FakeMatchRepository(),
        ),
        getScorerCandidatesUseCase: GetScorerCandidatesUseCase(
          matchRepository: _FakeMatchRepository(),
        ),
        assignScorerUseCase: AssignScorerUseCase(
          matchRepository: _FakeMatchRepository(),
        ),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home',
          getPages: [
            GetPage(name: '/home', page: () => const SizedBox()),
            GetPage(name: AppRoutes.login, page: () => const SizedBox()),
          ],
        ),
      );

      return homeController;
    }

    testWidgets('clears the local session and returns to login on success', (
      tester,
    ) async {
      authRepo.logoutResponse = Either.result(
        const CricketResponse(message: 'Logged out', data: {}),
      );
      final homeController = await pumpHarness(tester);

      await homeController.logout();
      await tester.pumpAndSettle();

      expect(Get.currentRoute, AppRoutes.login);
      expect(secureStorage.clearForLogoutCalled, isTrue);
      expect(sharedPref.clearForLogoutCalled, isTrue);
    });

    testWidgets(
      'still clears the local session and returns to login when the server call fails',
      (tester) async {
        authRepo.logoutResponse = Either.fallback(
          CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
        );
        final homeController = await pumpHarness(tester);

        await homeController.logout();
        await tester.pumpAndSettle();

        expect(
          Get.currentRoute,
          AppRoutes.login,
          reason:
              'a failed server-side revocation must not leave the console '
              'apparently still signed in',
        );
        expect(secureStorage.clearForLogoutCalled, isTrue);
        expect(sharedPref.clearForLogoutCalled, isTrue);
      },
    );

    testWidgets(
      'still clears the local session and returns to login when the call throws outright',
      (tester) async {
        authRepo.logoutThrows = Exception('network down');
        final homeController = await pumpHarness(tester);

        await homeController.logout();
        await tester.pumpAndSettle();

        expect(Get.currentRoute, AppRoutes.login);
        expect(secureStorage.clearForLogoutCalled, isTrue);
        expect(sharedPref.clearForLogoutCalled, isTrue);
      },
    );
  });

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
