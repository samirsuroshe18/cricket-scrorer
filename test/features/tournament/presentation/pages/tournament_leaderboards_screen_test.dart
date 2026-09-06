import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
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
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_leaderboards_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _GetLeaderboardsUseCase implements GetLeaderboardsUseCase {
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
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// TournamentDetailController.onInit() always calls loadDetail(), even
// though this screen only cares about leaderboards — these three need a
// working (not throwing) response so that automatic call succeeds
// harmlessly. Same reasoning as tournament_standings_screen_test.dart.
class _StubGetTournamentUseCase implements GetTournamentUseCase {
  @override
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>> call({
    GetTournamentParams? params,
  }) async {
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: TournamentDetailRes(
          id: 'tournament-1',
          name: 'Summer Cup',
          format: 'round_robin',
          status: 'ongoing',
          organization: TournamentOrganizationRef(id: 'org-1', name: 'Riverside CC'),
          teams: const [],
          createdAt: DateTime.parse('2026-09-06T10:00:00.000Z'),
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StubGetOrganizationUseCase implements GetOrganizationUseCase {
  @override
  Future<Either<CricketResponse<OrganizationDetailRes>, CricketFailure>> call({
    GetOrganizationParams? params,
  }) async {
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationDetailRes(
          id: 'org-1',
          name: 'Riverside CC',
          owner: OrganizationUserRef(id: 'owner-1', name: 'Owner'),
          members: const [],
          teams: const [],
          tournaments: const [],
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _StubGetFixturesUseCase implements GetFixturesUseCase {
  @override
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>> call({
    GetFixturesParams? params,
  }) async {
    return Either.result(
      const CricketResponse(message: 'ok', data: <FixtureRes>[]),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedUpdateTournamentUseCase implements UpdateTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedDeleteTournamentUseCase implements DeleteTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedEnrollTournamentTeamUseCase implements EnrollTournamentTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedRemoveTournamentTeamUseCase implements RemoveTournamentTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGenerateFixturesUseCase implements GenerateFixturesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStartFixtureMatchUseCase implements StartFixtureMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedResolveFixtureUseCase implements ResolveFixtureUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetStandingsUseCase implements GetStandingsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _GetLeaderboardsUseCase getLeaderboardsUseCase;

  setUp(() {
    Get.testMode = true;
    getLeaderboardsUseCase = _GetLeaderboardsUseCase();
    Get.put<TournamentDetailController>(
      TournamentDetailController(
        tournamentId: 'tournament-1',
        currentUserId: 'owner-1',
        getTournamentUseCase: _StubGetTournamentUseCase(),
        getOrganizationUseCase: _StubGetOrganizationUseCase(),
        updateTournamentUseCase: _UnusedUpdateTournamentUseCase(),
        deleteTournamentUseCase: _UnusedDeleteTournamentUseCase(),
        enrollTournamentTeamUseCase: _UnusedEnrollTournamentTeamUseCase(),
        removeTournamentTeamUseCase: _UnusedRemoveTournamentTeamUseCase(),
        getFixturesUseCase: _StubGetFixturesUseCase(),
        generateFixturesUseCase: _UnusedGenerateFixturesUseCase(),
        startFixtureMatchUseCase: _UnusedStartFixtureMatchUseCase(),
        resolveFixtureUseCase: _UnusedResolveFixtureUseCase(),
        getStandingsUseCase: _UnusedGetStandingsUseCase(),
        getLeaderboardsUseCase: getLeaderboardsUseCase,
      ),
      tag: 'tournament-1',
    );
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.tournamentLeaderboardsPath('tournament-1'),
        getPages: [
          GetPage(
            name: AppRoutes.tournamentLeaderboards,
            page: () => const TournamentLeaderboardsScreen(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  BattingLeaderboardRowRes battingRow({
    required String playerId,
    required String playerName,
    required int runs,
  }) => BattingLeaderboardRowRes(
    playerId: playerId, playerName: playerName,
    inningsBatted: 2, runs: runs, ballsFaced: 70, timesOut: 1, notOuts: 1,
    average: null, strikeRate: 142.86,
    fours: 10, sixes: 3, fifties: 1, hundreds: 0, highScore: null,
  );

  BowlingLeaderboardRowRes bowlingRow({
    required String playerId,
    required String playerName,
    required int wickets,
  }) => BowlingLeaderboardRowRes(
    playerId: playerId, playerName: playerName,
    inningsBowled: 2, legalDeliveries: 42, runsConceded: 36, wickets: wickets, maidens: 0,
    economy: 5.14, bestBowling: null,
  );

  testWidgets(
    'shows the batting tab by default, and switches to bowling on tab tap',
    (tester) async {
      getLeaderboardsUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: TournamentLeaderboardsRes(
            tournamentId: 'tournament-1',
            battingLeaderboard: [
              battingRow(playerId: 'p1', playerName: 'Rahul', runs: 100),
            ],
            bowlingLeaderboard: [
              bowlingRow(playerId: 'p2', playerName: 'Vijay', wickets: 3),
            ],
          ),
        ),
      );

      await pumpScreen(tester);

      expect(find.text('Rahul'), findsOneWidget);
      expect(find.text('Vijay'), findsNothing);

      await tester.tap(find.text('bowling_figures'));
      await tester.pumpAndSettle();

      expect(find.text('Vijay'), findsOneWidget);
    },
  );

  testWidgets('shows the empty state on both tabs when no one has played yet', (tester) async {
    getLeaderboardsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: TournamentLeaderboardsRes(
          tournamentId: 'tournament-1',
          battingLeaderboard: const [],
          bowlingLeaderboard: const [],
        ),
      ),
    );

    await pumpScreen(tester);

    expect(find.text('no_leaderboards_yet'), findsOneWidget);

    await tester.tap(find.text('bowling_figures'));
    await tester.pumpAndSettle();

    expect(find.text('no_leaderboards_yet'), findsOneWidget);
  });

  testWidgets('shows the backend error message and a retry button on failure', (tester) async {
    getLeaderboardsUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'Tournament not found'),
    );

    await pumpScreen(tester);

    expect(find.text('Tournament not found'), findsOneWidget);
    expect(find.text('retry'), findsOneWidget);
  });
}
