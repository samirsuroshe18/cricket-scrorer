import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_leaderboards.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
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
import 'package:cricket_scorer/features/tournament/presentation/widget/pool_player_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

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

class _UpdatePoolEntryUseCase implements UpdatePoolEntryUseCase {
  Either<CricketResponse<PoolEntryRes>, CricketFailure>? response;
  UpdatePoolEntryParams? lastParams;

  @override
  Future<Either<CricketResponse<PoolEntryRes>, CricketFailure>> call({
    UpdatePoolEntryParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _GetPoolUseCase implements GetPoolUseCase {
  @override
  Future<Either<CricketResponse<List<PoolEntryRes>>, CricketFailure>> call({
    GetPoolParams? params,
  }) async => Either.result(
    const CricketResponse(message: 'ok', data: <PoolEntryRes>[]),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// Every other usecase this controller's constructor requires is genuinely
// unreachable from showPoolPlayerSheet's own code path (registerPoolPlayer/
// updatePoolEntry/loadPool are the only three it ever calls).
class _UnusedGetTournamentUseCase implements GetTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedGetOrganizationUseCase implements GetOrganizationUseCase {
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

class _UnusedGetFixturesUseCase implements GetFixturesUseCase {
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

void main() {
  late _RegisterPoolPlayerUseCase registerPoolPlayerUseCase;
  late _UpdatePoolEntryUseCase updatePoolEntryUseCase;
  late TournamentDetailController controller;

  setUp(() {
    Get.testMode = true;
    registerPoolPlayerUseCase = _RegisterPoolPlayerUseCase();
    updatePoolEntryUseCase = _UpdatePoolEntryUseCase();
    controller = TournamentDetailController(
      tournamentId: 'tournament-1',
      currentUserId: 'owner-1',
      getTournamentUseCase: _UnusedGetTournamentUseCase(),
      getOrganizationUseCase: _UnusedGetOrganizationUseCase(),
      updateTournamentUseCase: _UnusedUpdateTournamentUseCase(),
      deleteTournamentUseCase: _UnusedDeleteTournamentUseCase(),
      enrollTournamentTeamUseCase: _UnusedEnrollTournamentTeamUseCase(),
      removeTournamentTeamUseCase: _UnusedRemoveTournamentTeamUseCase(),
      getFixturesUseCase: _UnusedGetFixturesUseCase(),
      generateFixturesUseCase: _UnusedGenerateFixturesUseCase(),
      startFixtureMatchUseCase: _UnusedStartFixtureMatchUseCase(),
      resolveFixtureUseCase: _UnusedResolveFixtureUseCase(),
      getStandingsUseCase: _UnusedGetStandingsUseCase(),
      getLeaderboardsUseCase: _UnusedGetLeaderboardsUseCase(),
      registerPoolPlayerUseCase: registerPoolPlayerUseCase,
      getPoolUseCase: _GetPoolUseCase(),
      updatePoolEntryUseCase: updatePoolEntryUseCase,
      removePoolEntryUseCase: _UnusedRemovePoolEntryUseCase(),
      setAuctionSetupUseCase: _UnusedSetAuctionSetupUseCase(),
      getAuctionSetupUseCase: _UnusedGetAuctionSetupUseCase(),
    );
  });

  tearDown(Get.reset);

  Future<void> pumpSheetTrigger(WidgetTester tester, VoidCallback onPressed) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: onPressed,
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  PoolEntryRes poolEntry() => PoolEntryRes(
    playerId: 'p1',
    playerName: 'Rohit Sharma',
    role: 'batsman',
    basePrice: 5000,
    registeredAt: '2026-09-07T10:00:00.000Z',
  );

  testWidgets('registering submits the typed name and base price', (tester) async {
    registerPoolPlayerUseCase.response = Either.result(
      CricketResponse(message: 'ok', data: poolEntry()),
    );

    await pumpSheetTrigger(
      tester,
      () => showPoolPlayerSheet(controller: controller),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Rohit Sharma');
    await tester.enterText(find.byType(TextFormField).last, '5000');
    await tester.tap(find.byType(CricketButton));
    await tester.pumpAndSettle();

    expect(registerPoolPlayerUseCase.lastParams?.playerName, 'Rohit Sharma');
    expect(registerPoolPlayerUseCase.lastParams?.basePrice, 5000);
  });

  testWidgets('registering with an invalid base price does not submit', (tester) async {
    await pumpSheetTrigger(
      tester,
      () => showPoolPlayerSheet(controller: controller),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Rohit Sharma');
    await tester.enterText(find.byType(TextFormField).last, '0');
    await tester.tap(find.byType(CricketButton));
    await tester.pumpAndSettle();

    expect(registerPoolPlayerUseCase.lastParams, isNull);
    expect(find.text('invalid_base_price'), findsOneWidget);
  });

  testWidgets(
    'editing shows the existing player name read-only, and submits only the new price',
    (tester) async {
      updatePoolEntryUseCase.response = Either.result(
        CricketResponse(message: 'ok', data: poolEntry()),
      );

      await pumpSheetTrigger(
        tester,
        () => showPoolPlayerSheet(controller: controller, existingEntry: poolEntry()),
      );

      expect(find.text('Rohit Sharma'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '8000');
      await tester.tap(find.byType(CricketButton));
      await tester.pumpAndSettle();

      expect(updatePoolEntryUseCase.lastParams?.playerId, 'p1');
      expect(updatePoolEntryUseCase.lastParams?.basePrice, 8000);
    },
  );
}
