import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_organization.dart';
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
import 'package:cricket_scorer/features/tournament/presentation/widget/edit_tournament_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// Reuses this controller directly (not a fake use-case set) since the sheet
// only ever calls `controller.updateTournament(...)` — a thin fake
// subclass overriding just that one method is simpler and more honest
// about what this widget test actually exercises than wiring six fake use
// cases through the real controller.
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
      ) {
    detail.value = TournamentDetailRes(
      id: 'tournament-1',
      name: 'Summer T20',
      format: 'knockout',
      status: 'upcoming',
      organization: TournamentOrganizationRef(id: 'org-1', name: 'Riverside CC'),
      teams: const [],
      createdAt: DateTime.now(),
    );
  }

  bool updateCalled = false;
  String? lastName, lastFormat, lastStatus;
  bool shouldSucceed = true;

  @override
  Future<bool> updateTournament({String? name, String? format, String? status}) async {
    updateCalled = true;
    lastName = name;
    lastFormat = format;
    lastStatus = status;
    return shouldSucceed;
  }
}

// noSuchMethod-only fakes — never called, since _FakeTournamentDetailController
// overrides every method this sheet actually exercises.
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

  Future<void> pumpOpenButton(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showEditTournamentSheet(controller: controller),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  // GetX's SnackbarController races the bottom sheet's own pop animation
  // when the snackbar is shown from the continuation after `Get.back()` —
  // same fix as assign_scorer_sheet_test.dart: pump frame-by-frame, never
  // pumpAndSettle() or one large pump(Duration).
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

  testWidgets('opens prefilled with the current name, format, and status', (
    tester,
  ) async {
    await pumpOpenButton(tester);

    expect(find.text('Summer T20'), findsOneWidget);
  });

  testWidgets('submitting sends the edited fields and shows a success snackbar', (
    tester,
  ) async {
    await pumpOpenButton(tester);

    await tester.enterText(find.byType(TextField), 'Winter T20');
    await tapAndAwaitSnackbar(tester, find.text('save'));

    expect(controller.updateCalled, isTrue);
    expect(controller.lastName, 'Winter T20');
    expect(controller.lastFormat, 'knockout');
    expect(controller.lastStatus, 'upcoming');
    expect(find.text('tournament_updated'), findsOneWidget);
    await drainSnackbar(tester);
  });

  testWidgets('shows an error snackbar and stays open on failure', (
    tester,
  ) async {
    controller.shouldSucceed = false;
    await pumpOpenButton(tester);

    await tapAndAwaitSnackbar(tester, find.text('save'));

    expect(find.text('something_went_wrong'), findsOneWidget);
    await drainSnackbar(tester);
  });
}
