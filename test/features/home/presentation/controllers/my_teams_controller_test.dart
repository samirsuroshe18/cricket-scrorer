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
      data: MyTeamsRes(teams: [], page: 1, limit: 20, total: 0),
    ),
  );

  /// Overrides [response] for a specific page, keyed by
  /// `params.page ?? 1` — lets a test answer page 1 and page 2 differently
  /// without a stateful counter.
  final Map<int, Either<CricketResponse<MyTeamsRes>, CricketFailure>>
  responseByPage = {};

  int calls = 0;
  final List<GetMyTeamsParams?> paramsSeen = [];

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    GetMyTeamsParams? params,
  }) async {
    calls++;
    paramsSeen.add(params);
    return responseByPage[params?.page ?? 1] ?? response;
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
            page: 1,
            limit: 20,
            total: 1,
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

  group('createTeam after a create that succeeded', () {
    test(
      'the new team is in the list even when the reload after it fails',
      () async {
        getMyTeams.response = Either.fallback(
          CricketServerErrorFailure(statusCode: 500, message: 'down'),
        );

        final error = await controller.createTeam(name: 'Sunday Sixers');

        expect(error, isNull);
        expect(controller.teams.map((t) => t.id), ['t1']);
        expect(controller.loadError.value, 'down');
      },
    );

    test('it goes to the top and keeps the teams already there', () async {
      controller.teams.assignAll([TeamSummary(id: 'old', name: 'Office XI')]);
      getMyTeams.response = Either.fallback(
        CricketServerErrorFailure(statusCode: 500, message: 'down'),
      );

      await controller.createTeam(name: 'Sunday Sixers');

      expect(controller.teams.map((t) => t.id), ['t1', 'old']);
    });

    test('an organization team shows its organization until the reload '
        'arrives', () async {
      getMyTeams.response = Either.fallback(
        CricketServerErrorFailure(statusCode: 500, message: 'down'),
      );

      await controller.createTeam(
        name: 'Riverside U19',
        organizationId: 'org-1',
        organizationName: 'Riverside CC',
      );

      final team = controller.teams.single;
      expect(team.id, 't2');
      expect(team.organization?.id, 'org-1');
      expect(team.organization?.name, 'Riverside CC');
    });

    test('an organization team without a known organization name shows no '
        'organization rather than a blank one', () async {
      getMyTeams.response = Either.fallback(
        CricketServerErrorFailure(statusCode: 500, message: 'down'),
      );

      await controller.createTeam(name: 'Riverside U19', organizationId: 'o');

      expect(controller.teams.single.organization, isNull);
    });

    test(
      'the server list replaces the local copy when the reload works',
      () async {
        getMyTeams.response = Either.result(
          CricketResponse(
            message: 'ok',
            data: MyTeamsRes(
              teams: [
                TeamSummary(id: 't1', name: 'Sunday Sixers', shortName: 'SS'),
              ],
              page: 1,
              limit: 20,
              total: 1,
            ),
          ),
        );

        await controller.createTeam(name: 'Sunday Sixers');

        expect(controller.teams, hasLength(1));
        expect(controller.teams.single.shortName, 'SS');
      },
    );
  });

  group('createTeam after a failure', () {
    test('with no response from the server it reloads, so a retry sees a team '
        'the lost response may have created', () async {
      createTeam.response = Either.fallback(
        CricketNoInternetFailure(message: 'offline'),
      );

      final error = await controller.createTeam(name: 'Sunday Sixers');

      expect(error, 'offline');
      expect(getMyTeams.calls, 1);
    });

    test('a 5xx response reloads too', () async {
      createTeam.response = Either.fallback(
        CricketServerErrorFailure(statusCode: 503, message: 'busy'),
      );

      final error = await controller.createTeam(name: 'Sunday Sixers');

      expect(error, 'busy');
      expect(getMyTeams.calls, 1);
    });

    test('a 4xx response does not reload: the server said no', () async {
      createTeam.response = Either.fallback(
        CricketBadRequestFailure(statusCode: 400, message: 'bad'),
      );

      await controller.createTeam(name: 'x');

      expect(getMyTeams.calls, 0);
    });

    test('a failure adds nothing to the list', () async {
      createTeam.response = Either.fallback(
        CricketNoInternetFailure(message: 'offline'),
      );

      await controller.createTeam(name: 'Sunday Sixers');

      expect(controller.teams, isEmpty);
    });
  });

  group('loadMyTeams pagination', () {
    test('requests page 1 and reports hasMore from the response', () async {
      getMyTeams.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't1', name: 'Sunday Sixers')],
            page: 1,
            limit: 20,
            total: 21,
          ),
        ),
      );

      await controller.loadMyTeams();

      expect(getMyTeams.paramsSeen.last?.page, 1);
      expect(controller.hasMore.value, isTrue);
    });

    test('hasMore is false once every team is loaded', () async {
      getMyTeams.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't1', name: 'Sunday Sixers')],
            page: 1,
            limit: 20,
            total: 1,
          ),
        ),
      );

      await controller.loadMyTeams();

      expect(controller.hasMore.value, isFalse);
    });

    test('resets to page 1 after a previous loadMoreTeams', () async {
      getMyTeams.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't1', name: 'Sunday Sixers')],
            page: 1,
            limit: 20,
            total: 21,
          ),
        ),
      );
      await controller.loadMyTeams();
      getMyTeams.responseByPage[2] = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't2', name: 'Office XI')],
            page: 2,
            limit: 20,
            total: 21,
          ),
        ),
      );
      await controller.loadMoreTeams();
      expect(controller.teams.map((t) => t.id), ['t1', 't2']);

      await controller.loadMyTeams();

      expect(getMyTeams.paramsSeen.last?.page, 1);
      expect(controller.teams.map((t) => t.id), ['t1']);
    });
  });

  group('loadMoreTeams', () {
    test('appends the next page and advances past it', () async {
      getMyTeams.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't1', name: 'Sunday Sixers')],
            page: 1,
            limit: 20,
            total: 21,
          ),
        ),
      );
      await controller.loadMyTeams();
      getMyTeams.responseByPage[2] = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't2', name: 'Office XI')],
            page: 2,
            limit: 20,
            total: 21,
          ),
        ),
      );

      await controller.loadMoreTeams();

      expect(controller.teams.map((t) => t.id), ['t1', 't2']);
      expect(controller.hasMore.value, isFalse);
    });

    test('is a no-op with nothing left', () async {
      getMyTeams.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyTeamsRes(
            teams: [TeamSummary(id: 't1', name: 'Sunday Sixers')],
            page: 1,
            limit: 20,
            total: 1,
          ),
        ),
      );
      await controller.loadMyTeams();
      final calls = getMyTeams.calls;

      await controller.loadMoreTeams();

      expect(getMyTeams.calls, calls);
    });
  });
}
