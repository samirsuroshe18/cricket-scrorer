import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorer_candidates_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/assign_scorer_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetTeamProfileUseCase implements GetTeamProfileUseCase {
  Either<CricketResponse<TeamProfileRes>, CricketFailure>? response;
  Object? throwOnCall;
  String? lastTeamId;

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) async {
    lastTeamId = params!.teamId;
    final error = throwOnCall;
    if (error != null) throw error;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetTeamMatchesUseCase implements GetTeamMatchesUseCase {
  Either<CricketResponse<MatchHistoryRes>, CricketFailure>? response;
  Object? throwOnCall;
  int callCount = 0;
  int? lastPage;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) async {
    callCount += 1;
    lastPage = params!.page;
    final error = throwOnCall;
    if (error != null) throw error;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetScorerCandidatesUseCase implements GetScorerCandidatesUseCase {
  Either<CricketResponse<ScorerCandidatesRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<ScorerCandidatesRes>, CricketFailure>> call({
    GetScorerCandidatesParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeAssignScorerUseCase implements AssignScorerUseCase {
  Either<CricketResponse<AssignScorerRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<AssignScorerRes>, CricketFailure>> call({
    AssignScorerParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

MatchHistoryItem _item(String matchId) => MatchHistoryItem(
  matchId: matchId,
  teamA: TeamRef(id: 'team-1', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 'team-2', name: 'Chennai Super Kings'),
  totalOvers: 20,
  status: 'completed',
  createdAt: '2026-08-20T10:15:00.000Z',
  syncStatus: 'synced',
);

void main() {
  late _FakeGetTeamProfileUseCase profileUseCase;
  late _FakeGetTeamMatchesUseCase matchesUseCase;
  late _FakeGetScorerCandidatesUseCase scorerCandidatesUseCase;
  late _FakeAssignScorerUseCase assignScorerUseCase;
  late TeamProfileController controller;

  setUp(() {
    Get.testMode = true;
    profileUseCase = _FakeGetTeamProfileUseCase();
    matchesUseCase = _FakeGetTeamMatchesUseCase();
    scorerCandidatesUseCase = _FakeGetScorerCandidatesUseCase();
    assignScorerUseCase = _FakeAssignScorerUseCase();
    controller = TeamProfileController(
      teamId: 'team-1',
      getTeamProfileUseCase: profileUseCase,
      getTeamMatchesUseCase: matchesUseCase,
      getScorerCandidatesUseCase: scorerCandidatesUseCase,
      assignScorerUseCase: assignScorerUseCase,
    );
  });

  tearDown(Get.reset);

  test('loadProfile populates profile on success', () async {
    profileUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: TeamProfileRes(
          teamId: 'team-1',
          name: 'Mumbai Indians',
          roster: const [],
        ),
      ),
    );

    await controller.loadProfile();

    expect(controller.profile.value?.name, 'Mumbai Indians');
    expect(controller.isLoadingProfile.value, isFalse);
    expect(controller.profileError.value, isNull);
  });

  test('loadProfile sets profileError on failure', () async {
    profileUseCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
    );

    await controller.loadProfile();

    expect(controller.profile.value, isNull);
    expect(controller.profileError.value, 'Server error');
  });

  test(
    'loadProfile ends the loading state and sets profileError when the '
    'response cannot be parsed, and can be retried',
    () async {
      profileUseCase.throwOnCall = TypeError();

      await controller.loadProfile();

      expect(controller.isLoadingProfile.value, isFalse);
      expect(controller.profileError.value, isNotNull);

      profileUseCase
        ..throwOnCall = null
        ..response = Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamProfileRes(
              teamId: 'team-1',
              name: 'Mumbai Indians',
              roster: const [],
            ),
          ),
        );
      await controller.loadProfile();

      expect(controller.profileError.value, isNull);
      expect(controller.profile.value?.name, 'Mumbai Indians');
    },
  );

  test('loadMatches populates the first page', () async {
    matchesUseCase.response = Either.result(
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

    await controller.loadMatches();

    expect(controller.matches.length, 1);
    expect(controller.hasMore.value, isFalse);
    expect(matchesUseCase.lastPage, 1);
  });

  test(
    'loadMatches ends the loading state and sets matchesError when the '
    'response cannot be parsed (regression: list spun forever)',
    () async {
      matchesUseCase.throwOnCall = TypeError();

      await controller.loadMatches();

      expect(controller.isLoadingMatches.value, isFalse);
      expect(controller.matchesError.value, isNotNull);
      expect(controller.matches, isEmpty);
    },
  );

  test('loadMatches can be retried after a parse failure', () async {
    matchesUseCase.throwOnCall = TypeError();
    await controller.loadMatches();

    matchesUseCase
      ..throwOnCall = null
      ..response = Either.result(
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
    await controller.loadMatches();

    expect(matchesUseCase.callCount, 2);
    expect(controller.matchesError.value, isNull);
    expect(controller.matches.length, 1);
  });

  test(
    'loadMoreMatches appends the next page and advances the cursor',
    () async {
      matchesUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MatchHistoryRes(
            matches: [_item('match-1')],
            page: 1,
            limit: 1,
            total: 2,
          ),
        ),
      );
      await controller.loadMatches();
      expect(controller.hasMore.value, isTrue);

      matchesUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MatchHistoryRes(
            matches: [_item('match-2')],
            page: 2,
            limit: 1,
            total: 2,
          ),
        ),
      );
      await controller.loadMoreMatches();

      expect(controller.matches.length, 2);
      expect(controller.hasMore.value, isFalse);
      expect(matchesUseCase.lastPage, 2);
    },
  );

  testWidgets(
    'loadMoreMatches clears isLoadingMore when the page cannot be parsed, '
    'and can be retried',
    (tester) async {
      // CricketSnackbar needs a real Overlay to show the failure.
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: SizedBox()),
        ),
      );

      matchesUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MatchHistoryRes(
            matches: [_item('match-1')],
            page: 1,
            limit: 1,
            total: 2,
          ),
        ),
      );
      await controller.loadMatches();

      matchesUseCase.throwOnCall = TypeError();
      await controller.loadMoreMatches();
      await tester.pump();

      expect(controller.isLoadingMore.value, isFalse);
      expect(find.text('something_went_wrong'), findsOneWidget);
      expect(controller.matches.length, 1);
      expect(controller.hasMore.value, isTrue);

      matchesUseCase
        ..throwOnCall = null
        ..response = Either.result(
          CricketResponse(
            message: 'ok',
            data: MatchHistoryRes(
              matches: [_item('match-2')],
              page: 2,
              limit: 1,
              total: 2,
            ),
          ),
        );
      await controller.loadMoreMatches();

      expect(controller.matches.length, 2);
      expect(matchesUseCase.lastPage, 2);

      // Let the error snackbar finish dismissing before the tree is torn down.
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
    },
  );

  test(
    'two controllers for different teams keep independent profile state '
    '(regression for GetX lazyPut singleton reuse across teams)',
    () async {
      final profileUseCaseA = _FakeGetTeamProfileUseCase();
      final matchesUseCaseA = _FakeGetTeamMatchesUseCase();
      final controllerA = TeamProfileController(
        teamId: 'team-1',
        getTeamProfileUseCase: profileUseCaseA,
        getTeamMatchesUseCase: matchesUseCaseA,
        getScorerCandidatesUseCase: _FakeGetScorerCandidatesUseCase(),
        assignScorerUseCase: _FakeAssignScorerUseCase(),
      );
      profileUseCaseA.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamProfileRes(
            teamId: 'team-1',
            name: 'Mumbai Indians',
            roster: const [],
          ),
        ),
      );

      final profileUseCaseB = _FakeGetTeamProfileUseCase();
      final matchesUseCaseB = _FakeGetTeamMatchesUseCase();
      final controllerB = TeamProfileController(
        teamId: 'team-2',
        getTeamProfileUseCase: profileUseCaseB,
        getTeamMatchesUseCase: matchesUseCaseB,
        getScorerCandidatesUseCase: _FakeGetScorerCandidatesUseCase(),
        assignScorerUseCase: _FakeAssignScorerUseCase(),
      );
      profileUseCaseB.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamProfileRes(
            teamId: 'team-2',
            name: 'Chennai Super Kings',
            roster: const [],
          ),
        ),
      );

      await controllerA.loadProfile();
      await controllerB.loadProfile();

      expect(controllerA.teamId, 'team-1');
      expect(controllerA.profile.value?.name, 'Mumbai Indians');
      expect(controllerB.teamId, 'team-2');
      expect(controllerB.profile.value?.name, 'Chennai Super Kings');
    },
  );

  test('loadScorerCandidates returns the candidate list on success', () async {
    scorerCandidatesUseCase.response = Either.result(
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
    matchesUseCase.response = Either.result(
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
    await controller.loadMatches();
    assignScorerUseCase.response = Either.result(
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
}
