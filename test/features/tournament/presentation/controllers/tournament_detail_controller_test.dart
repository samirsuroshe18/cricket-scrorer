import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

TournamentDetailRes _tournament({List<TournamentTeamRef> teams = const []}) =>
    TournamentDetailRes(
      id: 'tournament-1',
      name: 'Summer T20',
      format: 'knockout',
      status: 'upcoming',
      organization: TournamentOrganizationRef(id: 'org-1', name: 'Riverside CC'),
      teams: teams,
      createdAt: DateTime.parse('2026-09-05T10:00:00.000Z'),
    );

OrganizationDetailRes _org({List<OrganizationTeamRef> teams = const []}) =>
    OrganizationDetailRes(
      id: 'org-1',
      name: 'Riverside CC',
      owner: OrganizationUserRef(id: 'owner-1', name: 'Asha'),
      members: const [],
      teams: teams,
      tournaments: const [],
    );

class _FakeGetTournamentUseCase implements GetTournamentUseCase {
  Either<CricketResponse<TournamentDetailRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>> call({
    GetTournamentParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetOrganizationUseCase implements GetOrganizationUseCase {
  Either<CricketResponse<OrganizationDetailRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    GetOrganizationParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeUpdateTournamentUseCase implements UpdateTournamentUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  UpdateTournamentParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    UpdateTournamentParams? params,
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

class _FakeDeleteTournamentUseCase implements DeleteTournamentUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteTournamentParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeEnrollTournamentTeamUseCase implements EnrollTournamentTeamUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  EnrollTournamentTeamParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    EnrollTournamentTeamParams? params,
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

class _FakeRemoveTournamentTeamUseCase implements RemoveTournamentTeamUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveTournamentTeamParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetTournamentUseCase getTournamentUseCase;
  late _FakeGetOrganizationUseCase getOrganizationUseCase;
  late _FakeUpdateTournamentUseCase updateTournamentUseCase;
  late _FakeDeleteTournamentUseCase deleteTournamentUseCase;
  late _FakeEnrollTournamentTeamUseCase enrollTeamUseCase;
  late _FakeRemoveTournamentTeamUseCase removeTeamUseCase;
  late TournamentDetailController controller;

  TournamentDetailController build(String userId) => TournamentDetailController(
    tournamentId: 'tournament-1',
    currentUserId: userId,
    getTournamentUseCase: getTournamentUseCase,
    getOrganizationUseCase: getOrganizationUseCase,
    updateTournamentUseCase: updateTournamentUseCase,
    deleteTournamentUseCase: deleteTournamentUseCase,
    enrollTournamentTeamUseCase: enrollTeamUseCase,
    removeTournamentTeamUseCase: removeTeamUseCase,
  );

  setUp(() {
    Get.testMode = true;
    getTournamentUseCase = _FakeGetTournamentUseCase();
    getOrganizationUseCase = _FakeGetOrganizationUseCase();
    updateTournamentUseCase = _FakeUpdateTournamentUseCase();
    deleteTournamentUseCase = _FakeDeleteTournamentUseCase();
    enrollTeamUseCase = _FakeEnrollTournamentTeamUseCase();
    removeTeamUseCase = _FakeRemoveTournamentTeamUseCase();
    controller = build('owner-1');
  });

  tearDown(Get.reset);

  test(
    'loadDetail populates detail and organizationDetail, isOwner true for the owner',
    () async {
      getTournamentUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: _tournament()),
      );
      getOrganizationUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: _org()),
      );

      await controller.loadDetail();

      expect(controller.detail.value?.name, 'Summer T20');
      expect(controller.organizationDetail.value?.name, 'Riverside CC');
      expect(controller.isOwner, isTrue);
    },
  );

  test('isOwner is false for a non-owner member viewer', () async {
    controller = build('member-1');
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );

    await controller.loadDetail();

    expect(controller.isOwner, isFalse);
  });

  test('eligibleTeams excludes teams already enrolled in the tournament', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: _tournament(
          teams: [
            TournamentTeamRef(
              id: 'team-1',
              name: 'Riverside U19',
              joinedAt: DateTime.now(),
            ),
          ],
        ),
      ),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: _org(
          teams: [
            OrganizationTeamRef(id: 'team-1', name: 'Riverside U19'),
            OrganizationTeamRef(id: 'team-2', name: 'Riverside U16'),
          ],
        ),
      ),
    );

    await controller.loadDetail();

    expect(controller.eligibleTeams.map((t) => t.id), ['team-2']);
  });

  test('updateTournament sends only the changed fields and refreshes', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );
    await controller.loadDetail();

    updateTournamentUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );

    final result = await controller.updateTournament(status: 'ongoing');

    expect(result, isTrue);
    expect(updateTournamentUseCase.lastParams?.req.status, 'ongoing');
    expect(updateTournamentUseCase.lastParams?.req.name, isNull);
  });

  test('deleteTournament returns the use case result directly', () async {
    deleteTournamentUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );

    final result = await controller.deleteTournament();

    expect(result, isTrue);
  });

  test('enrollTeam sends teamId and refreshes on success', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );
    await controller.loadDetail();

    enrollTeamUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );

    final result = await controller.enrollTeam('team-2');

    expect(result, isTrue);
    expect(enrollTeamUseCase.lastParams?.teamId, 'team-2');
  });

  test('removeTeam returns false on failure without refreshing', () async {
    removeTeamUseCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'Server error'),
    );

    final result = await controller.removeTeam('team-1');

    expect(result, isFalse);
  });
}
