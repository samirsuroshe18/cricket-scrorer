import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/standings_row_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_leaderboards.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_standings.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
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

class _FakeGetFixturesUseCase implements GetFixturesUseCase {
  Either<CricketResponse<List<FixtureRes>>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>> call({
    GetFixturesParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGenerateFixturesUseCase implements GenerateFixturesUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    GenerateFixturesParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeStartFixtureMatchUseCase implements StartFixtureMatchUseCase {
  Either<CricketResponse<CreateMatchRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> call({
    StartFixtureMatchParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeResolveFixtureUseCase implements ResolveFixtureUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    ResolveFixtureParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetStandingsUseCase implements GetStandingsUseCase {
  Either<CricketResponse<List<StandingsRowRes>>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<List<StandingsRowRes>>, CricketFailure>> call({
    GetStandingsParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetLeaderboardsUseCase implements GetLeaderboardsUseCase {
  Either<CricketResponse<TournamentLeaderboardsRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<TournamentLeaderboardsRes>, CricketFailure>> call({
    GetLeaderboardsParams? params,
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
  late _FakeGetFixturesUseCase getFixturesUseCase;
  late _FakeGenerateFixturesUseCase generateFixturesUseCase;
  late _FakeStartFixtureMatchUseCase startFixtureMatchUseCase;
  late _FakeResolveFixtureUseCase resolveFixtureUseCase;
  late _FakeGetStandingsUseCase getStandingsUseCase;
  late _FakeGetLeaderboardsUseCase getLeaderboardsUseCase;
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
    getFixturesUseCase: getFixturesUseCase,
    generateFixturesUseCase: generateFixturesUseCase,
    startFixtureMatchUseCase: startFixtureMatchUseCase,
    resolveFixtureUseCase: resolveFixtureUseCase,
    getStandingsUseCase: getStandingsUseCase,
    getLeaderboardsUseCase: getLeaderboardsUseCase,
  );

  setUp(() {
    Get.testMode = true;
    getTournamentUseCase = _FakeGetTournamentUseCase();
    getOrganizationUseCase = _FakeGetOrganizationUseCase();
    updateTournamentUseCase = _FakeUpdateTournamentUseCase();
    deleteTournamentUseCase = _FakeDeleteTournamentUseCase();
    enrollTeamUseCase = _FakeEnrollTournamentTeamUseCase();
    removeTeamUseCase = _FakeRemoveTournamentTeamUseCase();
    // A default empty-list response so every existing test's loadDetail()
    // call — which now also calls the private _loadFixtures() — keeps
    // working unchanged; tests that care about fixtures override this.
    getFixturesUseCase = _FakeGetFixturesUseCase()
      ..response = Either.result(
        const CricketResponse(message: 'ok', data: <FixtureRes>[]),
      );
    generateFixturesUseCase = _FakeGenerateFixturesUseCase();
    startFixtureMatchUseCase = _FakeStartFixtureMatchUseCase();
    resolveFixtureUseCase = _FakeResolveFixtureUseCase();
    getStandingsUseCase = _FakeGetStandingsUseCase();
    getLeaderboardsUseCase = _FakeGetLeaderboardsUseCase();
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

  test('loadDetail also populates fixtures', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );
    getFixturesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: [
          FixtureRes(
            id: 'fixture-1',
            round: 1,
            order: 0,
            teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
            teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
            isBye: false,
            status: 'scheduled',
          ),
        ],
      ),
    );

    await controller.loadDetail();

    expect(controller.fixtures.length, 1);
    expect(controller.fixturesGenerated, isTrue);
  });

  test('generateFixtures returns null and refreshes fixtures on success', () async {
    getTournamentUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _tournament()),
    );
    getOrganizationUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: _org()),
    );
    await controller.loadDetail();

    generateFixturesUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );
    getFixturesUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: [
          FixtureRes(
            id: 'fixture-1',
            round: 1,
            order: 0,
            teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
            teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
            isBye: false,
            status: 'scheduled',
          ),
        ],
      ),
    );

    final errorMessage = await controller.generateFixtures();

    expect(errorMessage, isNull);
    expect(controller.fixtures.length, 1);
  });

  test('generateFixtures returns the backend message on failure', () async {
    generateFixturesUseCase.response = Either.fallback(
      CricketBadRequestFailure(
        statusCode: 400,
        message: 'Not enough teams enrolled for this tournament\'s format',
      ),
    );

    final errorMessage = await controller.generateFixtures();

    expect(errorMessage, 'Not enough teams enrolled for this tournament\'s format');
    expect(controller.fixtures, isEmpty);
  });

  test('startFixtureMatch returns a success outcome with the created match', () async {
    startFixtureMatchUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: CreateMatchRes(
          matchId: 'match-1',
          joinCode: 'ABC123',
          teamA: TeamRef(id: 'team-1', name: 'Harbor CC'),
          teamB: TeamRef(id: 'team-2', name: 'Lakeside XI'),
          totalOvers: 20,
          status: 'upcoming',
          syncStatus: 'local',
          createdAt: '2026-09-06T10:00:00.000Z',
        ),
      ),
    );
    getFixturesUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: <FixtureRes>[]),
    );

    final outcome = await controller.startFixtureMatch(
      'fixture-1',
      totalOvers: 20,
    );

    expect(outcome.errorMessage, isNull);
    expect(outcome.match?.matchId, 'match-1');
  });

  test('startFixtureMatch returns a failure outcome with the backend message', () async {
    startFixtureMatchUseCase.response = Either.fallback(
      CricketConflictFailure(statusCode: 409, message: 'This fixture already has a match'),
    );

    final outcome = await controller.startFixtureMatch(
      'fixture-1',
      totalOvers: 20,
    );

    expect(outcome.match, isNull);
    expect(outcome.errorMessage, 'This fixture already has a match');
  });

  test('resolveFixture returns null and refreshes fixtures on success', () async {
    resolveFixtureUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );
    getFixturesUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: <FixtureRes>[]),
    );

    final errorMessage = await controller.resolveFixture('fixture-1', 'team-1');

    expect(errorMessage, isNull);
  });

  test('loadStandings populates standings, sorted as the backend returned them', () async {
    getStandingsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: [
          StandingsRowRes(
            teamId: 'team-1', teamName: 'Harbor CC',
            played: 2, won: 2, lost: 0, tied: 0, noResult: 0, points: 4, nrr: 1.5,
          ),
          StandingsRowRes(
            teamId: 'team-2', teamName: 'Lakeside XI',
            played: 2, won: 0, lost: 2, tied: 0, noResult: 0, points: 0, nrr: -1.5,
          ),
        ],
      ),
    );

    await controller.loadStandings();

    expect(controller.standingsLoading.value, isFalse);
    expect(controller.standingsError.value, isNull);
    expect(controller.standings.map((r) => r.teamId), ['team-1', 'team-2']);
    expect(controller.standings.first.points, 4);
  });

  test('loadStandings sets the backend error message on failure, leaves standings empty', () async {
    getStandingsUseCase.response = Either.fallback(
      CricketBadRequestFailure(statusCode: 400, message: "Standings aren't available for a knockout tournament"),
    );

    await controller.loadStandings();

    expect(controller.standingsLoading.value, isFalse);
    expect(controller.standingsError.value, "Standings aren't available for a knockout tournament");
    expect(controller.standings, isEmpty);
  });

  test('loadLeaderboards populates both leaderboards as the backend returned them', () async {
    getLeaderboardsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: TournamentLeaderboardsRes(
          tournamentId: 'tournament-1',
          battingLeaderboard: [
            BattingLeaderboardRowRes(
              playerId: 'p1', playerName: 'Rahul',
              inningsBatted: 2, runs: 100, ballsFaced: 70, timesOut: 1, notOuts: 1,
              average: 100, strikeRate: 142.86,
              fours: 10, sixes: 3, fifties: 1, hundreds: 0,
              highScore: null,
            ),
          ],
          bowlingLeaderboard: [
            BowlingLeaderboardRowRes(
              playerId: 'p2', playerName: 'Vijay',
              inningsBowled: 2, legalDeliveries: 42, runsConceded: 36, wickets: 3, maidens: 0,
              economy: 5.14,
              bestBowling: null,
            ),
          ],
        ),
      ),
    );

    await controller.loadLeaderboards();

    expect(controller.leaderboardsLoading.value, isFalse);
    expect(controller.leaderboardsError.value, isNull);
    expect(controller.battingLeaderboard.map((r) => r.playerName), ['Rahul']);
    expect(controller.bowlingLeaderboard.map((r) => r.playerName), ['Vijay']);
  });

  test('loadLeaderboards sets the backend error message on failure, leaves both lists empty', () async {
    getLeaderboardsUseCase.response = Either.fallback(
      CricketBadRequestFailure(statusCode: 404, message: 'Tournament not found'),
    );

    await controller.loadLeaderboards();

    expect(controller.leaderboardsLoading.value, isFalse);
    expect(controller.leaderboardsError.value, 'Tournament not found');
    expect(controller.battingLeaderboard, isEmpty);
    expect(controller.bowlingLeaderboard, isEmpty);
  });
}
