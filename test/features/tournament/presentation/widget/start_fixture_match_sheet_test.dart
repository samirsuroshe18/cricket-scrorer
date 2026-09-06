import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/coin_flip.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:cricket_scorer/features/tournament/presentation/controllers/tournament_detail_controller.dart';
import 'package:cricket_scorer/features/tournament/presentation/widget/start_fixture_match_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeTournamentDetailController extends TournamentDetailController {
  _FakeTournamentDetailController()
    : super(
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
      );

  String? lastFixtureId;
  int? lastTotalOvers;
  StartFixtureMatchOutcome outcome = const StartFixtureMatchOutcome.failure(
    'not configured',
  );

  @override
  Future<StartFixtureMatchOutcome> startFixtureMatch(
    String fixtureId, {
    required int totalOvers,
    String? tossWinner,
    String? tossDecision,
  }) async {
    lastFixtureId = fixtureId;
    lastTotalOvers = totalOvers;
    return outcome;
  }
}

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

void main() {
  late _FakeTournamentDetailController controller;

  final fixture = FixtureRes(
    id: 'fixture-1',
    round: 1,
    order: 0,
    teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
    teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
    isBye: false,
    status: 'scheduled',
  );

  Future<void> pumpOpenButton(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showStartFixtureMatchSheet(
                controller: controller,
                fixture: fixture,
              ),
              child: const Text('open'),
            ),
          ),
        ),
        // startFixtureMatch navigates to AppRoutes.scoreBall on success —
        // give it somewhere real to land, same as
        // create_match_controller_test.dart.
        getPages: [
          GetPage(
            name: AppRoutes.scoreBall,
            page: () => const Scaffold(body: Text('score ball')),
          ),
        ],
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  // Same GetX-snackbar-timing reasoning as edit_tournament_sheet_test.dart:
  // pump frame-by-frame, never pumpAndSettle(), across a tap that can
  // trigger a snackbar and/or a route change.
  Future<void> tapAndSettleFrames(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> drainSnackbar(WidgetTester tester) async {
    for (var i = 0; i < 220; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  setUp(() {
    Get.testMode = true;
    controller = _FakeTournamentDetailController();
  });

  tearDown(Get.reset);

  testWidgets('shows the overs field and the toss section', (tester) async {
    await pumpOpenButton(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('toss_optional'), findsOneWidget);
  });

  testWidgets(
    'submitting a valid overs value with no toss starts the match and navigates to scoring',
    (tester) async {
      controller.outcome = StartFixtureMatchOutcome.success(
        CreateMatchRes(
          matchId: 'match-1',
          joinCode: 'ABC123',
          teamA: TeamRef(id: 'team-1', name: 'Harbor CC'),
          teamB: TeamRef(id: 'team-2', name: 'Lakeside XI'),
          totalOvers: 20,
          status: 'upcoming',
          syncStatus: 'local',
          createdAt: '2026-09-06T10:00:00.000Z',
        ),
      );
      await pumpOpenButton(tester);

      await tester.enterText(find.byType(TextField), '20');
      await tapAndSettleFrames(tester, find.text('start_match').last);

      expect(controller.lastFixtureId, 'fixture-1');
      expect(controller.lastTotalOvers, 20);
      expect(find.text('score ball'), findsOneWidget);
    },
  );

  testWidgets(
    're-flipping the coin clears a previously picked toss decision',
    (tester) async {
      await pumpOpenButton(tester);

      // First flip: settle the animation, then pick "Bat".
      await tester.tap(find.byType(CoinFlip));
      await tester.pumpAndSettle();
      await tester.tap(find.text('bat'));
      await tester.pump();
      expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'bat')).selected, isTrue);

      // Re-flip without picking a decision again.
      await tester.tap(find.byType(CoinFlip));
      await tester.pumpAndSettle();

      // The stale "Bat" pick must not survive the re-flip — neither chip
      // reads as selected until the scorer picks again.
      expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'bat')).selected, isFalse);
      expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'bowl')).selected, isFalse);

      // Submitting now (winner set, decision cleared) must be treated as
      // an incomplete toss, not silently sent with the stale decision —
      // this is the end-to-end proof: before the fix, this would instead
      // call startFixtureMatch with the old 'bat' decision paired against
      // the new winner.
      await tester.enterText(find.byType(TextField), '20');
      await tapAndSettleFrames(tester, find.text('start_match').last);

      expect(controller.lastFixtureId, isNull);
      expect(find.text('toss_incomplete'), findsOneWidget);
      await drainSnackbar(tester);
    },
  );

  testWidgets('shows an alert message and stays open on failure', (tester) async {
    controller.outcome = const StartFixtureMatchOutcome.failure(
      'This fixture already has a match',
    );
    await pumpOpenButton(tester);

    await tester.enterText(find.byType(TextField), '20');
    await tapAndSettleFrames(tester, find.text('start_match').last);

    expect(find.text('This fixture already has a match'), findsOneWidget);
    await drainSnackbar(tester);
  });
}
