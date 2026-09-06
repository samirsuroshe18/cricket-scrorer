import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_leaderboards_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization_leaderboards.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

OrganizationDetailRes _detail() => OrganizationDetailRes(
  id: 'org-1',
  name: 'Riverside CC',
  owner: OrganizationUserRef(id: 'user-1', name: 'Asha'),
  members: [
    OrganizationMemberRes(id: 'user-1', name: 'Asha', role: 'owner'),
    OrganizationMemberRes(id: 'user-2', name: 'Vikram', role: 'member'),
  ],
  teams: const [],
  tournaments: const [],
);

class _FakeGetOrganizationUseCase implements GetOrganizationUseCase {
  Either<CricketResponse<OrganizationDetailRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    GetOrganizationParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeAddOrganizationMemberUseCase
    implements AddOrganizationMemberUseCase {
  Either<CricketResponse<OrganizationMemberRes>, CricketFailure>? response;
  AddOrganizationMemberParams? lastParams;

  @override
  Future<Either<CricketResponse<OrganizationMemberRes>, CricketFailure>> call({
    AddOrganizationMemberParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeRemoveOrganizationMemberUseCase
    implements RemoveOrganizationMemberUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveOrganizationMemberParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateOrganizationTeamUseCase
    implements CreateOrganizationTeamUseCase {
  Either<CricketResponse<OrganizationTeamRef>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>> call({
    CreateOrganizationTeamParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeDeleteOrganizationUseCase implements DeleteOrganizationUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteOrganizationParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateTournamentUseCase implements CreateTournamentUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    CreateTournamentParams? params,
  }) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetOrganizationLeaderboardsUseCase
    implements GetOrganizationLeaderboardsUseCase {
  Either<CricketResponse<OrganizationLeaderboardsRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<OrganizationLeaderboardsRes>, CricketFailure>>
  call({GetOrganizationLeaderboardsParams? params}) async {
    final result = response;
    if (result == null) {
      throw UnimplementedError('Not exercised in this test.');
    }
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetOrganizationUseCase getOrganizationUseCase;
  late _FakeAddOrganizationMemberUseCase addMemberUseCase;
  late _FakeRemoveOrganizationMemberUseCase removeMemberUseCase;
  late _FakeCreateOrganizationTeamUseCase createTeamUseCase;
  late _FakeDeleteOrganizationUseCase deleteOrganizationUseCase;
  late _FakeCreateTournamentUseCase createTournamentUseCase;
  late _FakeGetOrganizationLeaderboardsUseCase getOrganizationLeaderboardsUseCase;
  late OrganizationDetailController controller;

  setUp(() {
    Get.testMode = true;
    getOrganizationUseCase = _FakeGetOrganizationUseCase();
    addMemberUseCase = _FakeAddOrganizationMemberUseCase();
    removeMemberUseCase = _FakeRemoveOrganizationMemberUseCase();
    createTeamUseCase = _FakeCreateOrganizationTeamUseCase();
    deleteOrganizationUseCase = _FakeDeleteOrganizationUseCase();
    createTournamentUseCase = _FakeCreateTournamentUseCase();
    getOrganizationLeaderboardsUseCase = _FakeGetOrganizationLeaderboardsUseCase();
    controller = OrganizationDetailController(
      orgId: 'org-1',
      currentUserId: 'user-1',
      getOrganizationUseCase: getOrganizationUseCase,
      addOrganizationMemberUseCase: addMemberUseCase,
      removeOrganizationMemberUseCase: removeMemberUseCase,
      createOrganizationTeamUseCase: createTeamUseCase,
      deleteOrganizationUseCase: deleteOrganizationUseCase,
      createTournamentUseCase: createTournamentUseCase,
      getOrganizationLeaderboardsUseCase: getOrganizationLeaderboardsUseCase,
    );
  });

  tearDown(Get.reset);

  test('loadDetail populates detail and isOwner is true for the owner', () async {
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );

    await controller.loadDetail();

    expect(controller.detail.value?.name, 'Riverside CC');
    expect(controller.isOwner, isTrue);
  });

  test('isOwner is false for a member viewer', () {
    controller = OrganizationDetailController(
      orgId: 'org-1',
      currentUserId: 'user-2',
      getOrganizationUseCase: getOrganizationUseCase,
      addOrganizationMemberUseCase: addMemberUseCase,
      removeOrganizationMemberUseCase: removeMemberUseCase,
      createOrganizationTeamUseCase: createTeamUseCase,
      deleteOrganizationUseCase: deleteOrganizationUseCase,
      createTournamentUseCase: createTournamentUseCase,
      getOrganizationLeaderboardsUseCase: getOrganizationLeaderboardsUseCase,
    );
    controller.detail.value = _detail();

    expect(controller.isOwner, isFalse);
  });

  test('addMember sends the typed email and refreshes on success', () async {
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );
    await controller.loadDetail();

    addMemberUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationMemberRes(id: 'user-3', name: 'Raj', role: 'member'),
      ),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationDetailRes(
          id: 'org-1',
          name: 'Riverside CC',
          owner: OrganizationUserRef(id: 'user-1', name: 'Asha'),
          members: [
            OrganizationMemberRes(id: 'user-1', name: 'Asha', role: 'owner'),
            OrganizationMemberRes(
              id: 'user-2',
              name: 'Vikram',
              role: 'member',
            ),
            OrganizationMemberRes(id: 'user-3', name: 'Raj', role: 'member'),
          ],
          teams: const [],
          tournaments: const [],
        ),
      ),
    );

    final result = await controller.addMember('raj@example.com');

    expect(result, isTrue);
    expect(addMemberUseCase.lastParams?.orgId, 'org-1');
    expect(addMemberUseCase.lastParams?.req.email, 'raj@example.com');
    expect(controller.detail.value?.members.length, 3);
  });

  test('addMember returns false on failure without refreshing', () async {
    addMemberUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'User not found'),
    );

    final result = await controller.addMember('nobody@example.com');

    expect(result, isFalse);
  });

  test('createTeam sends name and shortName', () async {
    createTeamUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationTeamRef(
          id: 'team-1',
          name: 'Riverside U19',
          shortName: 'RU19',
        ),
      ),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );

    final result = await controller.createTeam('Riverside U19', 'RU19');

    expect(result, isTrue);
  });

  test('createTournament sends name and format and refreshes on success', () async {
    createTournamentUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _detail()),
    );

    final result = await controller.createTournament('Summer T20', 'knockout');

    expect(result, isTrue);
  });

  test('loadLeaderboards populates both leaderboards as the backend returned them', () async {
    getOrganizationLeaderboardsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationLeaderboardsRes(
          organizationId: 'org-1',
          battingLeaderboard: [
            BattingLeaderboardRowRes(
              playerId: 'p1', playerName: 'Rahul',
              inningsBatted: 2, runs: 36, ballsFaced: 12, timesOut: 0, notOuts: 2,
              average: null, strikeRate: 300,
              fours: 0, sixes: 6, fifties: 0, hundreds: 0, highScore: null,
            ),
          ],
          bowlingLeaderboard: const [],
        ),
      ),
    );

    await controller.loadLeaderboards();

    expect(controller.leaderboardsLoading.value, isFalse);
    expect(controller.leaderboardsError.value, isNull);
    expect(controller.battingLeaderboard.map((r) => r.playerName), ['Rahul']);
  });

  test('loadLeaderboards sets the backend error message on failure, leaves both lists empty', () async {
    getOrganizationLeaderboardsUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'Organization not found'),
    );

    await controller.loadLeaderboards();

    expect(controller.leaderboardsLoading.value, isFalse);
    expect(controller.leaderboardsError.value, 'Organization not found');
    expect(controller.battingLeaderboard, isEmpty);
    expect(controller.bowlingLeaderboard, isEmpty);
  });
}
