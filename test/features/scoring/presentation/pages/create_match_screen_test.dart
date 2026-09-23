import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/create_match_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Never actually invoked — these tests never tap submit.
class _UnusedCreateMatchUseCase implements CreateMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// Never actually invoked — the Teams banner no longer searches directly;
/// that moved to SelectTeamScreen's own controller.
class _UnusedGetMyTeamsUseCase implements GetMyTeamsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('shows a placeholder row for each side before anything is picked', (
    tester,
  ) async {
    Get.put<CreateMatchController>(
      CreateMatchController(
        createMatchUseCase: _UnusedCreateMatchUseCase(),
        getMyTeamsUseCase: _UnusedGetMyTeamsUseCase(),
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const CreateMatchScreen()),
    );

    // "Team A"/"Team B" also label the toss coin's faces elsewhere on this
    // screen, so these are scoped to the Teams-section rows specifically.
    expect(
      find.descendant(
        of: find.byKey(const Key('teamsSection_teamARow')),
        matching: find.text(TranslationKeys.teamA.tr),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('teamsSection_teamBRow')),
        matching: find.text(TranslationKeys.teamB.tr),
      ),
      findsOneWidget,
    );
    expect(find.text(TranslationKeys.tapToSelectTeam.tr), findsNWidgets(2));
  });

  testWidgets('the row reflects a team selected on the controller', (tester) async {
    final controller = Get.put<CreateMatchController>(
      CreateMatchController(
        createMatchUseCase: _UnusedCreateMatchUseCase(),
        getMyTeamsUseCase: _UnusedGetMyTeamsUseCase(),
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const CreateMatchScreen()),
    );

    controller.selectTeamA(TeamSummary(id: 'team-1', name: 'Mumbai Indians'));
    await tester.pump();

    // Also appears on the toss coin's face now that CoinFlip is fed the real
    // team names, so this is scoped to the Teams row specifically.
    expect(
      find.descendant(
        of: find.byKey(const Key('teamsSection_teamARow')),
        matching: find.text('Mumbai Indians'),
      ),
      findsOneWidget,
    );
    // Team A's placeholder is gone; Team B's is still there.
    expect(find.text(TranslationKeys.tapToSelectTeam.tr), findsOneWidget);
  });

  testWidgets('tapping the Team A row opens SelectTeamScreen', (tester) async {
    Get.put<CreateMatchController>(
      CreateMatchController(
        createMatchUseCase: _UnusedCreateMatchUseCase(),
        getMyTeamsUseCase: _UnusedGetMyTeamsUseCase(),
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const CreateMatchScreen(),
        getPages: [
          GetPage(
            name: AppRoutes.selectTeam,
            page: () => const Scaffold(body: Text('picker screen')),
          ),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('teamsSection_teamARow')));
    await tester.pumpAndSettle();

    expect(find.text('picker screen'), findsOneWidget);
  });

  testWidgets('swapping with only Team A filled moves it to Team B', (tester) async {
    final controller = Get.put<CreateMatchController>(
      CreateMatchController(
        createMatchUseCase: _UnusedCreateMatchUseCase(),
        getMyTeamsUseCase: _UnusedGetMyTeamsUseCase(),
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const CreateMatchScreen()),
    );

    controller.selectTeamA(TeamSummary(id: 'team-1', name: 'Mumbai Indians'));
    await tester.pump();

    await tester.tap(find.byTooltip(TranslationKeys.swapTeams.tr));
    await tester.pump();

    expect(find.text(TranslationKeys.tapToSelectTeam.tr), findsOneWidget);
    expect(find.text('Mumbai Indians'), findsOneWidget);
    expect(controller.selectedTeamBId.value, 'team-1');
  });
}
