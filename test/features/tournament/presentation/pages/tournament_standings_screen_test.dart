import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/standings_row_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_standings.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_standings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _GetStandingsUseCase implements GetStandingsUseCase {
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
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// TournamentDetailController.onInit() always calls loadDetail(), even
// though this screen only cares about standings — these two need a working
// (not throwing) response so that automatic call succeeds harmlessly.
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

void main() {
  late _GetStandingsUseCase getStandingsUseCase;

  setUp(() {
    Get.testMode = true;
    getStandingsUseCase = _GetStandingsUseCase();
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
        getStandingsUseCase: getStandingsUseCase,
      ),
      tag: 'tournament-1',
    );
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.tournamentStandingsPath('tournament-1'),
        getPages: [
          GetPage(
            name: AppRoutes.tournamentStandings,
            page: () => const TournamentStandingsScreen(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders every row in the order the backend returned, with points and NRR shown',
    (tester) async {
      getStandingsUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: [
            StandingsRowRes(
              teamId: 'team-1', teamName: 'Harbor CC',
              played: 3, won: 2, lost: 1, tied: 0, noResult: 0, points: 4, nrr: 0.85,
            ),
            StandingsRowRes(
              teamId: 'team-2', teamName: 'Lakeside XI',
              played: 3, won: 1, lost: 2, tied: 0, noResult: 0, points: 2, nrr: -0.85,
            ),
          ],
        ),
      );

      await pumpScreen(tester);

      expect(find.text('Harbor CC'), findsOneWidget);
      expect(find.text('Lakeside XI'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // played=2 for row 2's "lost" plus points=2, harmless duplication
      expect(find.text('+0.850'), findsOneWidget);
      expect(find.text('-0.850'), findsOneWidget);

      // Row order follows the backend's sort exactly — the higher-points
      // team's name appears above the other's.
      final harborY = tester.getTopLeft(find.text('Harbor CC')).dy;
      final lakesideY = tester.getTopLeft(find.text('Lakeside XI')).dy;
      expect(harborY, lessThan(lakesideY));
    },
  );

  testWidgets('shows the empty state when no teams are enrolled', (tester) async {
    getStandingsUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: <StandingsRowRes>[]),
    );

    await pumpScreen(tester);

    expect(find.text('no_standings_yet'), findsOneWidget);
  });

  testWidgets('shows the backend error message and a retry button on failure', (tester) async {
    getStandingsUseCase.response = Either.fallback(
      CricketBadRequestFailure(statusCode: 400, message: "Standings aren't available for a knockout tournament"),
    );

    await pumpScreen(tester);

    expect(find.text("Standings aren't available for a knockout tournament"), findsOneWidget);
    expect(find.text('retry'), findsOneWidget);
  });
}
