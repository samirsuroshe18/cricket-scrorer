import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetMyTeams implements GetMyTeamsUseCase {
  Either<CricketResponse<MyTeamsRes>, CricketFailure> response = Either.result(
    CricketResponse(
      message: 'ok',
      data: MyTeamsRes(teams: []),
    ),
  );
  int calls = 0;

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) async {
    calls++;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateTeam implements CreateTeamUseCase {
  Either<CricketResponse<CreatedTeamRes>, CricketFailure> response =
      Either.result(
        CricketResponse(
          message: 'ok',
          data: CreatedTeamRes(id: 't1', name: 'Sunday Sixers'),
        ),
      );
  CreateTeamReq? lastRequest;
  int calls = 0;

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    CreateTeamReq? params,
  }) async {
    calls++;
    lastRequest = params;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateOrganizationTeam implements CreateOrganizationTeamUseCase {
  Either<CricketResponse<OrganizationTeamRef>, CricketFailure> response =
      Either.result(
        CricketResponse(
          message: 'ok',
          data: OrganizationTeamRef(id: 't2', name: 'Riverside U19'),
        ),
      );
  CreateOrganizationTeamParams? lastParams;
  int calls = 0;

  @override
  Future<Either<CricketResponse<OrganizationTeamRef>, CricketFailure>> call({
    CreateOrganizationTeamParams? params,
  }) async {
    calls++;
    lastParams = params;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetMyTeams getMyTeams;
  late _FakeCreateTeam createTeam;
  late _FakeCreateOrganizationTeam createOrganizationTeam;
  late MyTeamsController controller;

  setUp(() {
    Get.testMode = true;
    getMyTeams = _FakeGetMyTeams();
    createTeam = _FakeCreateTeam();
    createOrganizationTeam = _FakeCreateOrganizationTeam();
    controller = MyTeamsController(
      getMyTeamsUseCase: getMyTeams,
      createTeamUseCase: createTeam,
      createOrganizationTeamUseCase: createOrganizationTeam,
    );
  });

  tearDown(Get.reset);

  group('createTeam', () {
    test('without an organization it uses the standalone usecase', () async {
      final error = await controller.createTeam(
        name: 'Sunday Sixers',
        shortName: 'SS',
      );

      expect(error, isNull);
      expect(createTeam.calls, 1);
      expect(createTeam.lastRequest?.name, 'Sunday Sixers');
      expect(createTeam.lastRequest?.shortName, 'SS');
      expect(createOrganizationTeam.calls, 0);
    });

    test('with an organization it uses the organization usecase', () async {
      final error = await controller.createTeam(
        name: 'Riverside U19',
        shortName: 'RU19',
        organizationId: 'org-1',
      );

      expect(error, isNull);
      expect(createOrganizationTeam.calls, 1);
      expect(createOrganizationTeam.lastParams?.orgId, 'org-1');
      expect(createOrganizationTeam.lastParams?.req.name, 'Riverside U19');
      expect(createOrganizationTeam.lastParams?.req.shortName, 'RU19');
      expect(createTeam.calls, 0);
    });

    test('passes an absent short name through as null', () async {
      await controller.createTeam(name: 'Office XI');

      expect(createTeam.lastRequest?.shortName, isNull);
    });

    test('reloads My teams after a successful create', () async {
      getMyTeams.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't1', name: 'Sunday Sixers')],
          ),
        ),
      );

      await controller.createTeam(name: 'Sunday Sixers');

      expect(getMyTeams.calls, 1);
      expect(controller.teams.map((t) => t.name), ['Sunday Sixers']);
    });

    test('reloads after a successful organization team too', () async {
      await controller.createTeam(name: 'Riverside U19', organizationId: 'o');

      expect(getMyTeams.calls, 1);
    });

    test('a standalone failure returns the server message and does not '
        'reload', () async {
      createTeam.response = Either.fallback(
        CricketServerErrorFailure(
          statusCode: 400,
          message: 'A team name can be at most 50 characters',
        ),
      );

      final error = await controller.createTeam(name: 'x');

      expect(error, 'A team name can be at most 50 characters');
      expect(getMyTeams.calls, 0);
    });

    test('an organization failure returns the server message and does not '
        'reload', () async {
      createOrganizationTeam.response = Either.fallback(
        CricketServerErrorFailure(
          statusCode: 403,
          message: "That organization doesn't belong to your account",
        ),
      );

      final error = await controller.createTeam(
        name: 'Riverside U19',
        organizationId: 'org-1',
      );

      expect(error, "That organization doesn't belong to your account");
      expect(getMyTeams.calls, 0);
    });
  });
}
