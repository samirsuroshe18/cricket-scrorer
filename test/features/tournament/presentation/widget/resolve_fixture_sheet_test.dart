import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
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
import 'package:cricket_scorer/features/tournament/presentation/widget/resolve_fixture_sheet.dart';
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
        getStandingsUseCase: _UnusedGetStandingsUseCase(),
      );

  String? lastFixtureId;
  String? lastWinnerTeamId;
  String? errorMessage;

  @override
  Future<String?> resolveFixture(String fixtureId, String winnerTeamId) async {
    lastFixtureId = fixtureId;
    lastWinnerTeamId = winnerTeamId;
    return errorMessage;
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

class _UnusedGetStandingsUseCase implements GetStandingsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeTournamentDetailController controller;

  final fixture = FixtureRes(
    id: 'fixture-1',
    round: 2,
    order: 0,
    teamA: FixtureTeamRef(id: 'team-1', name: 'Harbor CC'),
    teamB: FixtureTeamRef(id: 'team-2', name: 'Lakeside XI'),
    isBye: false,
    status: 'unresolved',
  );

  Future<void> pumpOpenButton(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showResolveFixtureSheet(
                controller: controller,
                fixture: fixture,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> tapAndAwaitSnackbar(WidgetTester tester, Finder finder) async {
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

  testWidgets('shows both fixture teams as tappable rows', (tester) async {
    await pumpOpenButton(tester);

    expect(find.text('Harbor CC'), findsOneWidget);
    expect(find.text('Lakeside XI'), findsOneWidget);
  });

  testWidgets(
    "tapping a team resolves the fixture with that team's id and shows a success snackbar",
    (tester) async {
      await pumpOpenButton(tester);

      await tapAndAwaitSnackbar(tester, find.text('Lakeside XI'));

      expect(controller.lastFixtureId, 'fixture-1');
      expect(controller.lastWinnerTeamId, 'team-2');
      expect(find.text('fixture_resolved'), findsOneWidget);
      await drainSnackbar(tester);
    },
  );

  testWidgets('shows an error snackbar on failure', (tester) async {
    controller.errorMessage = "This fixture isn't awaiting manual resolution";
    await pumpOpenButton(tester);

    await tapAndAwaitSnackbar(tester, find.text('Harbor CC'));

    expect(find.text("This fixture isn't awaiting manual resolution"), findsOneWidget);
    await drainSnackbar(tester);
  });
}
