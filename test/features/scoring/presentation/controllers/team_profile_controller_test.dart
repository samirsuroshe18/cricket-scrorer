import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/remove_team_player.dart';
import 'dart:async';
import 'dart:io';

import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorer_candidates_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/assign_scorer_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/add_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/set_team_leadership.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_logo.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import '../helpers/picker_fakes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import '../helpers/squad_fakes.dart';

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
  String? lastStatus;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) async {
    callCount += 1;
    lastPage = params!.page;
    lastStatus = params.status;
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

class _FakeUpdateTeamLogoUseCase implements UpdateTeamLogoUseCase {
  Either<CricketResponse<String>, CricketFailure>? response;
  UpdateTeamLogoParams? lastParams;

  @override
  Future<Either<CricketResponse<String>, CricketFailure>> call({
    UpdateTeamLogoParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeUpdateTeamUseCase implements UpdateTeamUseCase {
  Either<CricketResponse<CreatedTeamRes>, CricketFailure>? response;
  UpdateTeamParams? lastParams;

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    UpdateTeamParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeDeleteTeamUseCase implements DeleteTeamUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  DeleteTeamParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteTeamParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// Every call waits on its own completer, so a test decides the order in
/// which responses come back.
class _GatedGetTeamMatchesUseCase implements GetTeamMatchesUseCase {
  final statuses = <String>[];
  final _completers =
      <Completer<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>>[];

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) {
    statuses.add(params!.status);
    final completer =
        Completer<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>();
    _completers.add(completer);
    return completer.future;
  }

  void complete(int call, List<MatchHistoryItem> items) {
    _completers[call].complete(
      Either.result(
        CricketResponse(
          message: 'ok',
          data: MatchHistoryRes(
            matches: items,
            page: 1,
            limit: 20,
            total: items.length,
          ),
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeAddTeamPlayerUseCase implements AddTeamPlayerUseCase {
  Either<CricketResponse<TeamRosterPlayer>, CricketFailure>? response;
  AddTeamPlayerParams? lastParams;

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> call({
    AddTeamPlayerParams? params,
  }) async {
    lastParams = params;
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeUpdateTeamPlayerUseCase implements UpdateTeamPlayerUseCase {
  Either<CricketResponse<TeamRosterPlayer>, CricketFailure>? response;
  UpdateTeamPlayerParams? lastParams;

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> call({
    UpdateTeamPlayerParams? params,
  }) async {
    lastParams = params;
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeRemoveTeamPlayerUseCase implements RemoveTeamPlayerUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  RemoveTeamPlayerParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveTeamPlayerParams? params,
  }) async {
    lastParams = params;
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeSetTeamLeadershipUseCase implements SetTeamLeadershipUseCase {
  Either<CricketResponse<CreatedTeamRes>, CricketFailure>? response;
  SetTeamLeadershipParams? lastParams;

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    SetTeamLeadershipParams? params,
  }) async {
    lastParams = params;
    return response!;
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
  late _FakeUpdateTeamLogoUseCase updateTeamLogoUseCase;
  late _FakeUpdateTeamUseCase updateTeamUseCase;
  late _FakeDeleteTeamUseCase deleteTeamUseCase;
  late _FakeAddTeamPlayerUseCase addTeamPlayerUseCase;
  late _FakeUpdateTeamPlayerUseCase updateTeamPlayerUseCase;
  late _FakeRemoveTeamPlayerUseCase removeTeamPlayerUseCase;
  late _FakeSetTeamLeadershipUseCase setTeamLeadershipUseCase;
  late FakeGetMyPlayersUseCase getMyPlayersUseCase;
  late FakeLookupUserByEmailUseCase lookupUserByEmailUseCase;
  late FakeInviteTeamPlayerUseCase inviteTeamPlayerUseCase;
  late FakeGetTeamInvites teamInvites;
  late FakeCancelTeamInvite cancelInvite;
  late TeamProfileController controller;

  TeamProfileController makeController({GetTeamMatchesUseCase? matches}) =>
      TeamProfileController(
        teamId: 'team-1',
        getTeamProfileUseCase: profileUseCase,
        getTeamMatchesUseCase: matches ?? matchesUseCase,
        getScorerCandidatesUseCase: scorerCandidatesUseCase,
        assignScorerUseCase: assignScorerUseCase,
        updateTeamLogoUseCase: updateTeamLogoUseCase,
        updateTeamUseCase: updateTeamUseCase,
        deleteTeamUseCase: deleteTeamUseCase,
        addTeamPlayerUseCase: addTeamPlayerUseCase,
        updateTeamPlayerUseCase: updateTeamPlayerUseCase,
        removeTeamPlayerUseCase: removeTeamPlayerUseCase,
        setTeamLeadershipUseCase: setTeamLeadershipUseCase,
        getMyPlayersUseCase: getMyPlayersUseCase,
        lookupUserByEmailUseCase: lookupUserByEmailUseCase,
        inviteTeamPlayerUseCase: inviteTeamPlayerUseCase,
        getTeamInvitesUseCase: teamInvites,
        cancelTeamInviteUseCase: cancelInvite,
      );

  setUp(() {
    Get.testMode = true;
    profileUseCase = _FakeGetTeamProfileUseCase();
    matchesUseCase = _FakeGetTeamMatchesUseCase();
    scorerCandidatesUseCase = _FakeGetScorerCandidatesUseCase();
    assignScorerUseCase = _FakeAssignScorerUseCase();
    updateTeamLogoUseCase = _FakeUpdateTeamLogoUseCase();
    updateTeamUseCase = _FakeUpdateTeamUseCase();
    deleteTeamUseCase = _FakeDeleteTeamUseCase();
    addTeamPlayerUseCase = _FakeAddTeamPlayerUseCase();
    updateTeamPlayerUseCase = _FakeUpdateTeamPlayerUseCase();
    removeTeamPlayerUseCase = _FakeRemoveTeamPlayerUseCase();
    setTeamLeadershipUseCase = _FakeSetTeamLeadershipUseCase();
    getMyPlayersUseCase = FakeGetMyPlayersUseCase();
    lookupUserByEmailUseCase = FakeLookupUserByEmailUseCase();
    inviteTeamPlayerUseCase = FakeInviteTeamPlayerUseCase();
    teamInvites = FakeGetTeamInvites({});
    cancelInvite = FakeCancelTeamInvite();
    controller = TeamProfileController(
      teamId: 'team-1',
      getTeamProfileUseCase: profileUseCase,
      getTeamMatchesUseCase: matchesUseCase,
      getScorerCandidatesUseCase: scorerCandidatesUseCase,
      assignScorerUseCase: assignScorerUseCase,
      updateTeamLogoUseCase: updateTeamLogoUseCase,
      updateTeamUseCase: updateTeamUseCase,
      deleteTeamUseCase: deleteTeamUseCase,
      addTeamPlayerUseCase: addTeamPlayerUseCase,
      updateTeamPlayerUseCase: updateTeamPlayerUseCase,
      setTeamLeadershipUseCase: setTeamLeadershipUseCase,
      getMyPlayersUseCase: getMyPlayersUseCase,
      lookupUserByEmailUseCase: lookupUserByEmailUseCase,
      inviteTeamPlayerUseCase: inviteTeamPlayerUseCase,
      getTeamInvitesUseCase: teamInvites,
      cancelTeamInviteUseCase: cancelInvite,
      removeTeamPlayerUseCase: removeTeamPlayerUseCase,
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
          canManage: true,
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
              canManage: true,
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
        updateTeamLogoUseCase: _FakeUpdateTeamLogoUseCase(),
        updateTeamUseCase: _FakeUpdateTeamUseCase(),
        deleteTeamUseCase: _FakeDeleteTeamUseCase(),
        addTeamPlayerUseCase: _FakeAddTeamPlayerUseCase(),
        updateTeamPlayerUseCase: _FakeUpdateTeamPlayerUseCase(),
        setTeamLeadershipUseCase: _FakeSetTeamLeadershipUseCase(),
        getMyPlayersUseCase: FakeGetMyPlayersUseCase(),
        lookupUserByEmailUseCase: FakeLookupUserByEmailUseCase(),
        inviteTeamPlayerUseCase: FakeInviteTeamPlayerUseCase(),
        getTeamInvitesUseCase: FakeGetTeamInvites({}),
        cancelTeamInviteUseCase: FakeCancelTeamInvite(),
        removeTeamPlayerUseCase: _FakeRemoveTeamPlayerUseCase(),
      );
      profileUseCaseA.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamProfileRes(
            teamId: 'team-1',
            name: 'Mumbai Indians',
            canManage: true,
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
        updateTeamLogoUseCase: _FakeUpdateTeamLogoUseCase(),
        updateTeamUseCase: _FakeUpdateTeamUseCase(),
        deleteTeamUseCase: _FakeDeleteTeamUseCase(),
        addTeamPlayerUseCase: _FakeAddTeamPlayerUseCase(),
        updateTeamPlayerUseCase: _FakeUpdateTeamPlayerUseCase(),
        setTeamLeadershipUseCase: _FakeSetTeamLeadershipUseCase(),
        getMyPlayersUseCase: FakeGetMyPlayersUseCase(),
        lookupUserByEmailUseCase: FakeLookupUserByEmailUseCase(),
        inviteTeamPlayerUseCase: FakeInviteTeamPlayerUseCase(),
        getTeamInvitesUseCase: FakeGetTeamInvites({}),
        cancelTeamInviteUseCase: FakeCancelTeamInvite(),
        removeTeamPlayerUseCase: _FakeRemoveTeamPlayerUseCase(),
      );
      profileUseCaseB.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamProfileRes(
            teamId: 'team-2',
            name: 'Chennai Super Kings',
            canManage: true,
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

  group('updateLogo', () {
    TeamProfileRes profileWith(String? logoUrl) => TeamProfileRes(
      teamId: 'team-1',
      name: 'Mumbai Indians',
      logoUrl: logoUrl,
      canManage: true,
      roster: const [],
    );

    test('uploads, then reloads the profile so the new logo shows', () async {
      profileUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: profileWith(null)),
      );
      await controller.loadProfile();
      expect(controller.profile.value?.logoUrl, isNull);

      updateTeamLogoUseCase.response = Either.result(
        const CricketResponse(message: 'ok', data: 'https://x/new.png'),
      );
      profileUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: profileWith('https://x/new.png')),
      );

      final file = File('logo.png');
      final ok = await controller.updateLogo(file);

      expect(ok, isTrue);
      expect(updateTeamLogoUseCase.lastParams?.teamId, 'team-1');
      expect(updateTeamLogoUseCase.lastParams?.file, file);
      expect(controller.profile.value?.logoUrl, 'https://x/new.png');
    });

    // CricketSnackbar reads Get.theme and needs a mounted overlay, so the
    // failure path runs inside a real GetMaterialApp and drains the
    // snackbar's timers before the test ends.
    testWidgets(
      'returns false and leaves the profile alone when the upload fails',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: SizedBox()),
          ),
        );

        profileUseCase.response = Either.result(
          CricketResponse(message: 'ok', data: profileWith(null)),
        );
        await controller.loadProfile();

        updateTeamLogoUseCase.response = Either.fallback(
          CricketForbiddenErrorFailure(statusCode: 403, message: 'Not yours'),
        );

        final ok = await controller.updateLogo(File('logo.png'));
        for (var i = 0; i < 220; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(ok, isFalse);
        expect(controller.profile.value?.logoUrl, isNull);
      },
    );
  });

  group('updateTeam', () {
    test('reloads the profile and returns null on success', () async {
      profileUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamProfileRes(
            teamId: 'team-1',
            name: 'Old Name',
            canManage: true,
            roster: const [],
          ),
        ),
      );
      await controller.loadProfile();

      updateTeamUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: CreatedTeamRes(id: 'team-1', name: 'New Name'),
        ),
      );
      profileUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamProfileRes(
            teamId: 'team-1',
            name: 'New Name',
            canManage: true,
            roster: const [],
          ),
        ),
      );

      final error = await controller.updateTeam(name: 'New Name');

      expect(error, isNull);
      expect(updateTeamUseCase.lastParams?.teamId, 'team-1');
      expect(updateTeamUseCase.lastParams?.req.name, 'New Name');
      expect(controller.profile.value?.name, 'New Name');
    });

    test(
      'returns the server message and leaves the profile alone on failure',
      () async {
        profileUseCase.response = Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamProfileRes(
              teamId: 'team-1',
              name: 'Old Name',
              canManage: true,
              roster: const [],
            ),
          ),
        );
        await controller.loadProfile();

        updateTeamUseCase.response = Either.fallback(
          CricketForbiddenErrorFailure(
            statusCode: 403,
            message: "You can't manage that team",
          ),
        );

        final error = await controller.updateTeam(name: 'New Name');

        expect(error, "You can't manage that team");
        expect(controller.profile.value?.name, 'Old Name');
      },
    );
  });

  group('deleteTeam', () {
    test('returns null on success', () async {
      deleteTeamUseCase.response = Either.result(
        const CricketResponse(message: 'ok', data: null),
      );

      final error = await controller.deleteTeam();

      expect(error, isNull);
      expect(deleteTeamUseCase.lastParams?.teamId, 'team-1');
    });

    test('returns the server message on a 409 refusal', () async {
      deleteTeamUseCase.response = Either.fallback(
        CricketConflictFailure(
          statusCode: 409,
          message: 'That team is in an upcoming or live match',
        ),
      );

      final error = await controller.deleteTeam();

      expect(error, 'That team is in an upcoming or live match');
    });
  });

  Either<CricketResponse<MatchHistoryRes>, CricketFailure> matchesPage(
    List<MatchHistoryItem> items,
  ) => Either.result(
    CricketResponse(
      message: 'ok',
      data: MatchHistoryRes(
        matches: items,
        page: 1,
        limit: 20,
        total: items.length,
      ),
    ),
  );

  Either<CricketResponse<TeamProfileRes>, CricketFailure> profileWith({
    String? captainId,
    String? viceCaptainId,
  }) => Either.result(
    CricketResponse(
      message: 'ok',
      data: TeamProfileRes(
        teamId: 'team-1',
        name: 'Mumbai Indians',
        shortName: 'MI',
        canManage: true,
        roster: const [],
        captainId: captainId,
        viceCaptainId: viceCaptainId,
      ),
    ),
  );

  final rosterRow = TeamRosterPlayer(
    playerId: 'p1',
    playerName: 'Rohit',
    role: 'batsman',
  );

  test('statusFilter starts at all', () {
    expect(controller.statusFilter.value, 'all');
  });

  test(
    'setStatusFilter reloads page 1 with the new status and resets hasMore',
    () async {
      matchesUseCase.response = matchesPage([_item('match-1')]);
      await controller.loadMatches();

      matchesUseCase.response = matchesPage([_item('live-1')]);
      await controller.setStatusFilter('live');

      expect(controller.statusFilter.value, 'live');
      expect(matchesUseCase.lastStatus, 'live');
      expect(matchesUseCase.lastPage, 1);
      expect(controller.matches.map((m) => m.matchId), ['live-1']);
      expect(controller.hasMore.value, isFalse);
    },
  );

  test('setStatusFilter with the same value does not refetch', () async {
    matchesUseCase.response = matchesPage([_item('match-1')]);
    await controller.loadMatches();
    final calls = matchesUseCase.callCount;

    await controller.setStatusFilter('all');

    expect(matchesUseCase.callCount, calls);
  });

  test('loadMoreMatches keeps the active status filter', () async {
    matchesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(
          matches: [_item('a')],
          page: 1,
          limit: 1,
          total: 2,
        ),
      ),
    );
    await controller.setStatusFilter('completed');
    await controller.loadMoreMatches();

    expect(matchesUseCase.lastStatus, 'completed');
    expect(matchesUseCase.lastPage, 2);
  });

  test(
    'a slow response for the previous filter does not overwrite the list '
    'after a newer filter loads',
    () async {
      final gated = _GatedGetTeamMatchesUseCase();
      final c = makeController(matches: gated);

      final first = c.loadMatches(); // status all -> call 0
      final second = c.setStatusFilter('live'); // -> call 1, while 0 in flight
      expect(gated.statuses, ['all', 'live']);

      gated.complete(1, [_item('live-1')]);
      await second;
      gated.complete(0, [_item('all-1'), _item('all-2')]);
      await first;

      expect(c.matches.map((m) => m.matchId), ['live-1']);
      expect(c.isLoadingMatches.value, isFalse);
    },
  );

  test(
    'loadMoreMatches does nothing while the first page is still loading',
    () async {
      final gated = _GatedGetTeamMatchesUseCase();
      final c = makeController(matches: gated);

      final first = c.loadMatches();
      await c.loadMoreMatches(); // hasMore is still true from construction

      expect(gated.statuses, ['all']);

      gated.complete(0, [_item('a')]);
      await first;
    },
  );

  test('addPlayer refetches the profile and returns no error', () async {
    addTeamPlayerUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: rosterRow),
    );
    profileUseCase.response = profileWith();

    final error = await controller.addPlayer(
      name: 'Rohit',
      role: 'batsman',
      jerseyNumber: 45,
    );

    expect(error, isNull);
    expect(addTeamPlayerUseCase.lastParams?.teamId, 'team-1');
    expect(addTeamPlayerUseCase.lastParams?.req.name, 'Rohit');
    expect(addTeamPlayerUseCase.lastParams?.req.role, 'batsman');
    expect(addTeamPlayerUseCase.lastParams?.req.jerseyNumber, 45);
    expect(profileUseCase.lastTeamId, 'team-1');
    expect(controller.profile.value?.name, 'Mumbai Indians');
  });

  test(
    'addPlayer failure returns the server message and leaves the profile '
    'untouched',
    () async {
      profileUseCase.response = profileWith();
      await controller.loadProfile();
      addTeamPlayerUseCase.response = Either.fallback(
        CricketBadRequestFailure(statusCode: 400, message: 'Bad name'),
      );

      final error = await controller.addPlayer(name: 'x');

      expect(error, 'Bad name');
      expect(controller.profile.value?.name, 'Mumbai Indians');
    },
  );

  group('add-player picker actions', () {
    MyPlayersRes myPlayers({int page = 1, int total = 1}) => MyPlayersRes(
      players: [MyPlayerRow(playerId: 'p1', playerName: 'Rohit')],
      page: page,
      limit: 20,
      total: total,
    );

    test(
      'addExistingPlayer sends the playerId (no name) and refetches',
      () async {
        addTeamPlayerUseCase.response = Either.result(
          CricketResponse(message: 'ok', data: rosterRow),
        );
        profileUseCase.response = profileWith();

        final error = await controller.addExistingPlayer('p1');

        expect(error, isNull);
        expect(addTeamPlayerUseCase.lastParams?.teamId, 'team-1');
        expect(addTeamPlayerUseCase.lastParams?.req.playerId, 'p1');
        expect(addTeamPlayerUseCase.lastParams?.req.name, isNull);
        expect(profileUseCase.lastTeamId, 'team-1');
        expect(controller.profile.value?.name, 'Mumbai Indians');
      },
    );

    test(
      'addExistingPlayer returns the server message and does not refetch',
      () async {
        addTeamPlayerUseCase.response = Either.fallback(
          CricketNotFoundErrorFailure(
            statusCode: 404,
            message: 'No such player',
          ),
        );

        final error = await controller.addExistingPlayer('p1');

        expect(error, 'No such player');
        expect(profileUseCase.lastTeamId, isNull);
      },
    );

    test(
      'inviteUser invites the user on this team and refetches the profile',
      () async {
        inviteTeamPlayerUseCase.response = Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamInviteRes(
              inviteId: 'i1',
              status: 'pending',
              player: rosterRow,
            ),
          ),
        );
        profileUseCase.response = profileWith();

        final error = await controller.inviteUser('u1');

        expect(error, isNull);
        expect(inviteTeamPlayerUseCase.calls.single.teamId, 'team-1');
        expect(inviteTeamPlayerUseCase.calls.single.userId, 'u1');
        expect(profileUseCase.lastTeamId, 'team-1');
      },
    );

    test('inviteUser returns the server message on failure', () async {
      inviteTeamPlayerUseCase.response = Either.fallback(
        CricketBadRequestFailure(statusCode: 409, message: 'Already claimed'),
      );

      final error = await controller.inviteUser('u1');

      expect(error, 'Already claimed');
      expect(profileUseCase.lastTeamId, isNull);
    });

    test('lookupUserByEmail returns the user, trimming the address', () async {
      lookupUserByEmailUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: LookedUpUserRes(userId: 'u1', fullName: 'Rahul Sharma'),
        ),
      );

      final (user, error) = await controller.lookupUserByEmail(
        '  rahul@example.com ',
      );

      expect(error, isNull);
      expect(user?.fullName, 'Rahul Sharma');
      expect(lookupUserByEmailUseCase.calls.single.email, 'rahul@example.com');
    });

    test(
      'lookupUserByEmail returns the server message when not found',
      () async {
        lookupUserByEmailUseCase.response = Either.fallback(
          CricketNotFoundErrorFailure(
            statusCode: 404,
            message: 'User not found',
          ),
        );

        final (user, error) = await controller.lookupUserByEmail('a@b.co');

        expect(user, isNull);
        expect(error, 'User not found');
      },
    );

    test('loadMyPlayers passes teamId, q and page through', () async {
      getMyPlayersUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: myPlayers(page: 2, total: 21)),
      );

      final (res, error) = await controller.loadMyPlayers(q: 'roh', page: 2);

      expect(error, isNull);
      expect(res?.hasMore, isFalse);
      final call = getMyPlayersUseCase.calls.single;
      expect(call.teamId, 'team-1');
      expect(call.q, 'roh');
      expect(call.page, 2);
    });

    test('loadMyPlayers returns the server message on failure', () async {
      getMyPlayersUseCase.response = Either.fallback(
        CricketForbiddenErrorFailure(statusCode: 403, message: 'Not yours'),
      );

      final (res, error) = await controller.loadMyPlayers();

      expect(res, isNull);
      expect(error, 'Not yours');
    });
  });

  test('updatePlayer sends the ids and refetches the profile', () async {
    updateTeamPlayerUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: rosterRow),
    );
    profileUseCase.response = profileWith();

    final error = await controller.updatePlayer(
      playerId: 'p1',
      role: 'bowler',
      jerseyNumber: 7,
    );

    expect(error, isNull);
    expect(updateTeamPlayerUseCase.lastParams?.teamId, 'team-1');
    expect(updateTeamPlayerUseCase.lastParams?.playerId, 'p1');
    expect(updateTeamPlayerUseCase.lastParams?.req.role, 'bowler');
    expect(updateTeamPlayerUseCase.lastParams?.req.jerseyNumber, 7);
    expect(profileUseCase.lastTeamId, 'team-1');
  });

  test('updatePlayer can clear the jersey number', () async {
    updateTeamPlayerUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: rosterRow),
    );
    profileUseCase.response = profileWith();

    await controller.updatePlayer(playerId: 'p1', clearJerseyNumber: true);

    final req = updateTeamPlayerUseCase.lastParams!.req;
    expect(req.clearJerseyNumber, isTrue);
    expect(req.toJson()['jerseyNumber'], isNull);
    expect(req.toJson().containsKey('jerseyNumber'), isTrue);
  });

  test(
    'removePlayer calls the use case and reloads the profile on success',
    () async {
      removeTeamPlayerUseCase.response = Either.result(
        const CricketResponse<void>(message: 'ok', data: null),
      );
      profileUseCase.response = profileWith();

      final error = await controller.removePlayer(playerId: 'p1');

      expect(error, isNull);
      expect(removeTeamPlayerUseCase.lastParams?.teamId, 'team-1');
      expect(removeTeamPlayerUseCase.lastParams?.playerId, 'p1');
      expect(profileUseCase.lastTeamId, 'team-1');
    },
  );

  test('removePlayer returns the server message on failure', () async {
    removeTeamPlayerUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(
        message: "That player isn't on this team's roster",
      ),
    );

    final error = await controller.removePlayer(playerId: 'p1');

    expect(error, "That player isn't on this team's roster");
  });

  test(
    'setLeader sends the current name and shortName plus both leader ids',
    () async {
      profileUseCase.response = profileWith(
        captainId: 'p1',
        viceCaptainId: 'p2',
      );
      await controller.loadProfile();
      setTeamLeadershipUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: CreatedTeamRes(id: 'team-1', name: 'Mumbai Indians'),
        ),
      );

      final error = await controller.setLeader(
        playerId: 'p3',
        viceCaptain: false,
      );

      final req = setTeamLeadershipUseCase.lastParams!.req;
      expect(error, isNull);
      expect(req.name, 'Mumbai Indians');
      expect(req.shortName, 'MI');
      expect(req.captainId, 'p3');
      expect(req.viceCaptainId, 'p2');
    },
  );

  test('clearLeader sends null for that slot and keeps the other', () async {
    profileUseCase.response = profileWith(captainId: 'p1', viceCaptainId: 'p2');
    await controller.loadProfile();
    setTeamLeadershipUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: CreatedTeamRes(id: 'team-1', name: 'Mumbai Indians'),
      ),
    );

    await controller.clearLeader(viceCaptain: true);

    final req = setTeamLeadershipUseCase.lastParams!.req;
    expect(req.captainId, 'p1');
    expect(req.viceCaptainId, isNull);
  });

  test(
    'setLeader clears the other slot when promoting the player who holds it '
    '(the server rejects the same player in both)',
    () async {
      profileUseCase.response = profileWith(
        captainId: 'p1',
        viceCaptainId: 'p2',
      );
      await controller.loadProfile();
      setTeamLeadershipUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: CreatedTeamRes(id: 'team-1', name: 'Mumbai Indians'),
        ),
      );

      await controller.setLeader(playerId: 'p2', viceCaptain: false);

      final req = setTeamLeadershipUseCase.lastParams!.req;
      expect(req.captainId, 'p2');
      expect(req.viceCaptainId, isNull);
    },
  );

  test(
    'setLeader without a loaded profile does nothing and reports an error',
    () async {
      final error = await controller.setLeader(
        playerId: 'p3',
        viceCaptain: false,
      );

      expect(error, isNotNull);
      expect(setTeamLeadershipUseCase.lastParams, isNull);
    },
  );

  group('invitations', () {
    void profileIs({required bool canManage}) {
      profileUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamProfileRes(
            teamId: 'team-1',
            name: 'Mumbai Indians',
            canManage: canManage,
            roster: const [],
          ),
        ),
      );
    }

    TeamInviteItemRes invite(String id, String status, {String user = 'u1'}) =>
        TeamInviteItemRes(
          inviteId: id,
          status: status,
          player: InvitedPlayerRes(playerId: 'p-$id', playerName: 'Rahul'),
          invitee: InviteeUserRes(userId: user, fullName: 'Rahul'),
        );

    test('a manager\'s profile load also loads the invitations', () async {
      profileIs(canManage: true);
      teamInvites.byTeam['team-1'] = [invite('i1', 'pending')];

      await controller.loadProfile();

      expect(teamInvites.asked, ['team-1']);
      expect(controller.invites.single.inviteId, 'i1');
    });

    test('a viewer who cannot manage never requests invitations', () async {
      profileIs(canManage: false);

      await controller.loadProfile();

      expect(teamInvites.asked, isEmpty);
      expect(controller.invites, isEmpty);
    });

    test('cancelInvite sends both ids, then refetches the list', () async {
      profileIs(canManage: true);
      teamInvites.byTeam['team-1'] = [invite('i1', 'pending')];
      await controller.loadProfile();
      cancelInvite.onSuccess = () => teamInvites.byTeam['team-1'] = [];

      final error = await controller.cancelInvite(controller.invites.single);

      expect(error, isNull);
      expect(cancelInvite.calls.single.teamId, 'team-1');
      expect(cancelInvite.calls.single.inviteId, 'i1');
      expect(controller.invites, isEmpty);
    });

    test(
      'a failed cancel returns the server message and keeps the row',
      () async {
        profileIs(canManage: true);
        teamInvites.byTeam['team-1'] = [invite('i1', 'pending')];
        await controller.loadProfile();
        cancelInvite.fail = true;

        final error = await controller.cancelInvite(controller.invites.single);

        expect(error, 'cancel refused');
        expect(controller.invites, hasLength(1));
      },
    );

    test(
      'inviteUser refreshes the invitations after a successful invite',
      () async {
        profileIs(canManage: true);
        await controller.loadProfile();
        teamInvites.byTeam['team-1'] = [invite('i2', 'pending')];
        inviteTeamPlayerUseCase.response = Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamInviteRes(
              inviteId: 'i2',
              status: 'pending',
              player: TeamRosterPlayer(
                playerId: 'p-i2',
                playerName: 'Rahul',
                role: 'unknown',
              ),
            ),
          ),
        );

        final error = await controller.inviteUser('u1');

        expect(error, isNull);
        expect(controller.invites.single.inviteId, 'i2');
      },
    );

    test('inviteAgain invites the same user once more', () async {
      profileIs(canManage: true);
      await controller.loadProfile();
      inviteTeamPlayerUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TeamInviteRes(
            inviteId: 'i3',
            status: 'pending',
            player: TeamRosterPlayer(
              playerId: 'p-i3',
              playerName: 'Rahul',
              role: 'unknown',
            ),
          ),
        ),
      );

      final error = await controller.inviteAgain(
        invite('i1', 'declined', user: 'u7'),
      );

      expect(error, isNull);
      expect(inviteTeamPlayerUseCase.calls.single.userId, 'u7');
      expect(inviteTeamPlayerUseCase.calls.single.teamId, 'team-1');
    });
  });
}
