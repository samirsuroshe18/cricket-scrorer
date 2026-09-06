import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_detail_res.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_leaderboards_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/add_organization_member.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/delete_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization_leaderboards.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organization_detail_controller.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organization_leaderboards_screen.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _GetOrganizationLeaderboardsUseCase
    implements GetOrganizationLeaderboardsUseCase {
  Either<CricketResponse<OrganizationLeaderboardsRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<OrganizationLeaderboardsRes>, CricketFailure>>
  call({GetOrganizationLeaderboardsParams? params}) async {
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// OrganizationDetailController.onInit() always calls loadDetail() — this
// needs a working (not throwing) response so that automatic call succeeds
// harmlessly. Same reasoning as tournament_leaderboards_screen_test.dart.
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

class _UnusedAddOrganizationMemberUseCase
    implements AddOrganizationMemberUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedRemoveOrganizationMemberUseCase
    implements RemoveOrganizationMemberUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedCreateOrganizationTeamUseCase
    implements CreateOrganizationTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedDeleteOrganizationUseCase implements DeleteOrganizationUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedCreateTournamentUseCase implements CreateTournamentUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _GetOrganizationLeaderboardsUseCase getOrganizationLeaderboardsUseCase;

  setUp(() {
    Get.testMode = true;
    getOrganizationLeaderboardsUseCase = _GetOrganizationLeaderboardsUseCase();
    Get.put<OrganizationDetailController>(
      OrganizationDetailController(
        orgId: 'org-1',
        currentUserId: 'owner-1',
        getOrganizationUseCase: _StubGetOrganizationUseCase(),
        addOrganizationMemberUseCase: _UnusedAddOrganizationMemberUseCase(),
        removeOrganizationMemberUseCase: _UnusedRemoveOrganizationMemberUseCase(),
        createOrganizationTeamUseCase: _UnusedCreateOrganizationTeamUseCase(),
        deleteOrganizationUseCase: _UnusedDeleteOrganizationUseCase(),
        createTournamentUseCase: _UnusedCreateTournamentUseCase(),
        getOrganizationLeaderboardsUseCase: getOrganizationLeaderboardsUseCase,
      ),
      tag: 'org-1',
    );
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.organizationLeaderboardsPath('org-1'),
        getPages: [
          GetPage(
            name: AppRoutes.organizationLeaderboards,
            page: () => const OrganizationLeaderboardsScreen(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows the batting tab by default, and switches to bowling on tab tap',
    (tester) async {
      getOrganizationLeaderboardsUseCase.response = Either.result(
        CricketResponse(
          message: 'ok',
          data: OrganizationLeaderboardsRes(
            organizationId: 'org-1',
            battingLeaderboard: [
              BattingLeaderboardRowRes(
                playerId: 'p1', playerName: 'Rahul',
                inningsBatted: 2, runs: 36, ballsFaced: 12, timesOut: 0, notOuts: 2,
                average: null, strikeRate: 300,
                fours: 0, sixes: 6, fifties: 0, hundreds: 0, highScore: null,
              ),
            ],
            bowlingLeaderboard: [
              BowlingLeaderboardRowRes(
                playerId: 'p2', playerName: 'Vijay',
                inningsBowled: 2, legalDeliveries: 12, runsConceded: 18, wickets: 0, maidens: 0,
                economy: 9, bestBowling: null,
              ),
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

  testWidgets('shows the empty state when the org has no leaderboard data yet', (tester) async {
    getOrganizationLeaderboardsUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: OrganizationLeaderboardsRes(
          organizationId: 'org-1',
          battingLeaderboard: const [],
          bowlingLeaderboard: const [],
        ),
      ),
    );

    await pumpScreen(tester);

    expect(find.text('no_leaderboards_yet'), findsOneWidget);
  });

  testWidgets('shows the backend error message and a retry button on failure', (tester) async {
    getOrganizationLeaderboardsUseCase.response = Either.fallback(
      CricketNotFoundErrorFailure(statusCode: 404, message: 'Organization not found'),
    );

    await pumpScreen(tester);

    expect(find.text('Organization not found'), findsOneWidget);
    expect(find.text('retry'), findsOneWidget);
  });
}
