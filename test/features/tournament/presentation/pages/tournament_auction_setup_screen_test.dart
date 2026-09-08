import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_setup_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_leaderboards.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_standings.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/set_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_auction_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _GetAuctionSetupUseCase implements GetAuctionSetupUseCase {
  Either<CricketResponse<AuctionSetupRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<AuctionSetupRes>, CricketFailure>> call({
    GetAuctionSetupParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _SetAuctionSetupUseCase implements SetAuctionSetupUseCase {
  Either<CricketResponse<AuctionSetupRes>, CricketFailure>? response;
  SetAuctionSetupParams? lastParams;

  @override
  Future<Either<CricketResponse<AuctionSetupRes>, CricketFailure>> call({
    SetAuctionSetupParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// TournamentDetailController.onInit() always calls loadDetail(), even
// though this screen only cares about auction setup — these two need a
// working (not throwing) response so that automatic call succeeds
// harmlessly. Same reasoning as the standings/leaderboards screen tests.
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
          format: 'league',
          status: 'upcoming',
          organization: TournamentOrganizationRef(id: 'org-1', name: 'Riverside CC'),
          teams: [
            TournamentTeamRef(id: 'team-1', name: 'Harbor CC', joinedAt: DateTime.now()),
            TournamentTeamRef(id: 'team-2', name: 'Lakeside XI', joinedAt: DateTime.now()),
          ],
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
          members: [
            OrganizationMemberRes(id: 'owner-1', name: 'Asha', role: 'owner'),
            OrganizationMemberRes(id: 'member-1', name: 'Vijay', role: 'member'),
          ],
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

class _UnusedGetLeaderboardsUseCase implements GetLeaderboardsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _GetAuctionSetupUseCase getAuctionSetupUseCase;
  late _SetAuctionSetupUseCase setAuctionSetupUseCase;

  setUp(() {
    Get.testMode = true;
    getAuctionSetupUseCase = _GetAuctionSetupUseCase();
    setAuctionSetupUseCase = _SetAuctionSetupUseCase();
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
        getLeaderboardsUseCase: _UnusedGetLeaderboardsUseCase(),
        setAuctionSetupUseCase: setAuctionSetupUseCase,
        getAuctionSetupUseCase: getAuctionSetupUseCase,
      ),
      tag: 'tournament-1',
    );
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.tournamentAuctionSetupPath('tournament-1'),
        getPages: [
          GetPage(
            name: AppRoutes.tournamentAuctionSetup,
            page: () => const TournamentAuctionSetupScreen(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows a row for every enrolled team with the current owner and budget prefilled',
    (tester) async {
      getAuctionSetupUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: AuctionSetupRes(
            tournamentId: 'tournament-1',
            minSquadSize: null,
            maxSquadSize: null,
            categoryCaps: null,
            owners: [
              AuctionOwnerRes(
                teamId: 'team-1', teamName: 'Harbor CC',
                userId: 'member-1', userName: 'Vijay',
                budget: 100000,
              ),
            ],
          ),
        ),
      );

      await pumpScreen(tester);

      expect(find.text('Harbor CC'), findsOneWidget);
      expect(find.text('Lakeside XI'), findsOneWidget);
      expect(find.text('100000'), findsOneWidget);
    },
  );

  testWidgets('shows the squad-rules fields prefilled from the loaded setup', (tester) async {
    getAuctionSetupUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: AuctionSetupRes(
          tournamentId: 'tournament-1',
          minSquadSize: 15,
          maxSquadSize: 20,
          categoryCaps: null,
          owners: const [],
        ),
      ),
    );

    await pumpScreen(tester);

    expect(find.text('15'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('saving submits squad rules and the owners built from the visible rows', (tester) async {
    getAuctionSetupUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: AuctionSetupRes(
          tournamentId: 'tournament-1',
          minSquadSize: null,
          maxSquadSize: null,
          categoryCaps: null,
          owners: const [],
        ),
      ),
    );
    setAuctionSetupUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: AuctionSetupRes(
          tournamentId: 'tournament-1',
          minSquadSize: 15,
          maxSquadSize: null,
          categoryCaps: null,
          owners: const [],
        ),
      ),
    );

    await pumpScreen(tester);

    await tester.enterText(find.byKey(const Key('minSquadSizeField')), '15');
    await tester.tap(find.byKey(const Key('ownerDropdown_team-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vijay').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('budgetField_team-1')), '50000');
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    expect(setAuctionSetupUseCase.lastParams?.minSquadSize, 15);
    expect(setAuctionSetupUseCase.lastParams?.owners?.length, 1);
    expect(setAuctionSetupUseCase.lastParams?.owners?.first.teamId, 'team-1');
    expect(setAuctionSetupUseCase.lastParams?.owners?.first.userId, 'member-1');
    expect(setAuctionSetupUseCase.lastParams?.owners?.first.budget, 50000);
  });

  testWidgets('shows the backend error message and a retry button on failure', (tester) async {
    getAuctionSetupUseCase.response = Either.fallback(
      CricketBadRequestFailure(statusCode: 404, message: 'Tournament not found'),
    );

    await pumpScreen(tester);

    expect(find.text('Tournament not found'), findsOneWidget);
    expect(find.text('retry'), findsOneWidget);
  });
}
