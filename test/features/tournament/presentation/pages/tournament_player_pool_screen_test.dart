import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_leaderboards.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_pool.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_standings.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/register_pool_player.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_pool_entry.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/set_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_pool_entry.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_player_pool_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _GetPoolUseCase implements GetPoolUseCase {
  Either<CricketResponse<List<PoolEntryRes>>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<List<PoolEntryRes>>, CricketFailure>> call({
    GetPoolParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _RegisterPoolPlayerUseCase implements RegisterPoolPlayerUseCase {
  Either<CricketResponse<PoolEntryRes>, CricketFailure>? response;
  RegisterPoolPlayerParams? lastParams;

  @override
  Future<Either<CricketResponse<PoolEntryRes>, CricketFailure>> call({
    RegisterPoolPlayerParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _RemovePoolEntryUseCase implements RemovePoolEntryUseCase {
  Either<CricketResponse<void>, CricketFailure>? response;
  RemovePoolEntryParams? lastParams;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemovePoolEntryParams? params,
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
// though this screen only cares about the pool — these three need a
// working (not throwing) response so that automatic call succeeds
// harmlessly. Same reasoning as the sibling standings/leaderboards tests.
// The org's owner is 'owner-1', matching currentUserId below, so isOwner
// is true and the add/edit/remove actions render.
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

class _UnusedGetLeaderboardsUseCase implements GetLeaderboardsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedUpdatePoolEntryUseCase implements UpdatePoolEntryUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedSetAuctionSetupUseCase implements SetAuctionSetupUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetAuctionSetupUseCase implements GetAuctionSetupUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _GetPoolUseCase getPoolUseCase;
  late _RegisterPoolPlayerUseCase registerPoolPlayerUseCase;
  late _RemovePoolEntryUseCase removePoolEntryUseCase;

  setUp(() {
    Get.testMode = true;
    getPoolUseCase = _GetPoolUseCase();
    registerPoolPlayerUseCase = _RegisterPoolPlayerUseCase();
    removePoolEntryUseCase = _RemovePoolEntryUseCase();
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
        registerPoolPlayerUseCase: registerPoolPlayerUseCase,
        getPoolUseCase: getPoolUseCase,
        updatePoolEntryUseCase: _UnusedUpdatePoolEntryUseCase(),
        removePoolEntryUseCase: removePoolEntryUseCase,
        setAuctionSetupUseCase: _UnusedSetAuctionSetupUseCase(),
        getAuctionSetupUseCase: _UnusedGetAuctionSetupUseCase(),
      ),
      tag: 'tournament-1',
    );
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.tournamentPoolPath('tournament-1'),
        getPages: [
          GetPage(
            name: AppRoutes.tournamentPool,
            page: () => const TournamentPlayerPoolScreen(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  PoolEntryRes poolEntry({
    String playerId = 'p1',
    String playerName = 'Rohit Sharma',
    int basePrice = 5000,
  }) => PoolEntryRes(
    playerId: playerId,
    playerName: playerName,
    role: 'batsman',
    basePrice: basePrice,
    registeredAt: '2026-09-07T10:00:00.000Z',
  );

  testWidgets('shows the registered pool entries', (tester) async {
    getPoolUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: [poolEntry()]),
    );

    await pumpScreen(tester);

    expect(find.text('Rohit Sharma'), findsOneWidget);
    expect(find.text('5000'), findsOneWidget);
  });

  testWidgets('shows the empty state when nothing is registered', (tester) async {
    getPoolUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: <PoolEntryRes>[]),
    );

    await pumpScreen(tester);

    expect(find.text('no_players_in_pool_yet'), findsOneWidget);
  });

  testWidgets('shows the backend error message and a retry button on failure', (tester) async {
    getPoolUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'Tournament not found'),
    );

    await pumpScreen(tester);

    expect(find.text('Tournament not found'), findsOneWidget);
    expect(find.text('retry'), findsOneWidget);
  });

  testWidgets('registering a player from the sheet reloads the pool', (tester) async {
    getPoolUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: <PoolEntryRes>[]),
    );
    await pumpScreen(tester);
    expect(find.text('no_players_in_pool_yet'), findsOneWidget);

    registerPoolPlayerUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: poolEntry()),
    );
    getPoolUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: [poolEntry()]),
    );

    await tester.tap(find.byIcon(Icons.person_add_alt_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Rohit Sharma');
    await tester.enterText(find.byType(TextFormField).last, '5000');
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    expect(registerPoolPlayerUseCase.lastParams?.playerName, 'Rohit Sharma');
    expect(registerPoolPlayerUseCase.lastParams?.basePrice, 5000);
    expect(find.text('Rohit Sharma'), findsOneWidget);
  });

  testWidgets('removing a player reloads the pool', (tester) async {
    getPoolUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: [poolEntry()]),
    );
    await pumpScreen(tester);
    expect(find.text('Rohit Sharma'), findsOneWidget);

    removePoolEntryUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: null),
    );
    getPoolUseCase.response = Either.result(
      const CricketResponse(message: 'ok', data: <PoolEntryRes>[]),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(removePoolEntryUseCase.lastParams?.playerId, 'p1');
    expect(find.text('no_players_in_pool_yet'), findsOneWidget);
  });
}
