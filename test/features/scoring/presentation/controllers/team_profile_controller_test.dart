import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetTeamProfileUseCase implements GetTeamProfileUseCase {
  Either<CricketResponse<TeamProfileRes>, CricketFailure>? response;
  String? lastTeamId;

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) async {
    lastTeamId = params!.teamId;
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
  int callCount = 0;
  int? lastPage;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) async {
    callCount += 1;
    lastPage = params!.page;
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
);

void main() {
  late _FakeGetTeamProfileUseCase profileUseCase;
  late _FakeGetTeamMatchesUseCase matchesUseCase;
  late TeamProfileController controller;

  setUp(() {
    Get.testMode = true;
    profileUseCase = _FakeGetTeamProfileUseCase();
    matchesUseCase = _FakeGetTeamMatchesUseCase();
    controller = TeamProfileController(
      teamId: 'team-1',
      getTeamProfileUseCase: profileUseCase,
      getTeamMatchesUseCase: matchesUseCase,
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
}
