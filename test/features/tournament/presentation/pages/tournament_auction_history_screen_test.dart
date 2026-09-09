import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_report_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_history.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_squad.dart';
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
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_auction_history_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _GetAuctionHistoryUseCase implements GetAuctionHistoryUseCase {
  Either<CricketResponse<AuctionHistoryRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<AuctionHistoryRes>, CricketFailure>> call({
    GetAuctionHistoryParams? params,
  }) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

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

class _UnusedRegisterPoolPlayerUseCase implements RegisterPoolPlayerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetPoolUseCase implements GetPoolUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedUpdatePoolEntryUseCase implements UpdatePoolEntryUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedRemovePoolEntryUseCase implements RemovePoolEntryUseCase {
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

class _UnusedGetAuctionSquadUseCase implements GetAuctionSquadUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _GetAuctionHistoryUseCase getAuctionHistoryUseCase;

  setUp(() {
    Get.testMode = true;
    getAuctionHistoryUseCase = _GetAuctionHistoryUseCase();
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
        registerPoolPlayerUseCase: _UnusedRegisterPoolPlayerUseCase(),
        getPoolUseCase: _UnusedGetPoolUseCase(),
        updatePoolEntryUseCase: _UnusedUpdatePoolEntryUseCase(),
        removePoolEntryUseCase: _UnusedRemovePoolEntryUseCase(),
        setAuctionSetupUseCase: _UnusedSetAuctionSetupUseCase(),
        getAuctionSetupUseCase: _UnusedGetAuctionSetupUseCase(),
        getAuctionSquadUseCase: _UnusedGetAuctionSquadUseCase(),
        getAuctionHistoryUseCase: getAuctionHistoryUseCase,
      ),
      tag: 'tournament-1',
    );
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.tournamentAuctionHistoryPath('tournament-1'),
        getPages: [
          GetPage(
            name: AppRoutes.tournamentAuctionHistory,
            page: () => const TournamentAuctionHistoryScreen(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows sold and unsold entries with their outcome', (tester) async {
    getAuctionHistoryUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: AuctionHistoryRes(
          tournamentId: 'tournament-1',
          entries: [
            AuctionHistoryEntryRes(
              lotId: 'lot-1',
              playerId: 'p1',
              playerName: 'Virat Kohli',
              role: 'batsman',
              basePrice: 6000,
              outcome: 'unsold',
              resolvedAt: DateTime.parse('2026-09-08T10:00:00.000Z'),
            ),
            AuctionHistoryEntryRes(
              lotId: 'lot-2',
              playerId: 'p2',
              playerName: 'Rohit Sharma',
              role: 'batsman',
              basePrice: 5000,
              outcome: 'sold',
              soldPrice: 6500,
              teamId: 'team-1',
              teamName: 'Riverside U19',
              resolvedAt: DateTime.parse('2026-09-08T10:01:00.000Z'),
            ),
          ],
        ),
      ),
    );

    await pumpScreen(tester);

    expect(find.text('Virat Kohli'), findsOneWidget);
    expect(find.text('unsold'), findsOneWidget);
    expect(find.text('Rohit Sharma'), findsOneWidget);
    expect(find.text('sold'), findsOneWidget);
    expect(find.text('Riverside U19'), findsOneWidget);
    expect(find.text('₹6500'), findsOneWidget);
  });

  testWidgets('shows the empty state when nothing has resolved yet', (tester) async {
    getAuctionHistoryUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: AuctionHistoryRes(tournamentId: 'tournament-1', entries: const []),
      ),
    );

    await pumpScreen(tester);

    expect(find.text('no_auction_history_yet'), findsOneWidget);
  });

  testWidgets('shows the backend error message and a retry button on failure', (tester) async {
    getAuctionHistoryUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'No auction has been started for this tournament'),
    );

    await pumpScreen(tester);

    expect(find.text('No auction has been started for this tournament'), findsOneWidget);
    expect(find.text('retry'), findsOneWidget);
  });
}
