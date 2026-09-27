import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_player_view.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/team_player_view_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/team_player_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/player_view_fakes.dart';

void main() {
  late FakeGetTeamPlayerMatches matches;

  setUp(() {
    Get.testMode = true;
    matches = FakeGetTeamPlayerMatches();
    Get.put<GetTeamPlayerViewUseCase>(FakeGetTeamPlayerView());
    Get.put<GetTeamPlayerMatchesUseCase>(matches);
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.teamPlayerViewPath('t1'),
        getPages: [
          GetPage<dynamic>(
            name: AppRoutes.teamPlayerView,
            page: () => const TeamPlayerViewScreen(),
            binding: TeamPlayerViewBinding(),
          ),
          GetPage<dynamic>(
            name: AppRoutes.spectator,
            page: () => const Scaffold(body: Text('spectating')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the team, roster and read-only note', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Mumbai Indians'), findsWidgets);
    expect(find.text('Mohit Zatu'), findsOneWidget);
    expect(find.text('Captain Cool'), findsOneWidget);
    expect(find.text('#7'), findsOneWidget);
    expect(find.text(TranslationKeys.readOnlyTeamNote.tr), findsOneWidget);
  });

  testWidgets('offers none of the manage controls', (tester) async {
    await pumpScreen(tester);

    expect(find.text(TranslationKeys.addPlayer.tr), findsNothing);
    expect(find.text(TranslationKeys.updateTeamLogo.tr), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.person_add_alt_1_outlined), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('the chips filter matches by status', (tester) async {
    matches.byStatus['live'] = [sampleMatch('m1')];
    await pumpScreen(tester);

    await tester.tap(find.text(TranslationKeys.statusLive.tr));
    await tester.pumpAndSettle();

    expect(matches.statuses.last, 'live');
  });

  testWidgets(
    'tapping a live match with a join code opens the spectator view',
    (
      tester,
    ) async {
      matches.byStatus['all'] = [sampleMatch('m1')];
      await pumpScreen(tester);

      await tester.tap(find.text('vs Chennai Kings'));
      await tester.pumpAndSettle();

      expect(find.text('spectating'), findsOneWidget);
    },
  );

  testWidgets('team names on a match are not links to the scorer\'s profile', (
    tester,
  ) async {
    matches.byStatus['all'] = [sampleMatch('m1', status: 'completed')];
    await pumpScreen(tester);

    final name = tester.widget<Text>(find.text('vs Chennai Kings'));

    expect(
      find.ancestor(
        of: find.text('vs Chennai Kings'),
        matching: find.byWidgetPredicate(
          (w) => w is InkWell && w.onTap != null && w.borderRadius != null,
        ),
      ),
      findsNothing,
    );
    expect(name.data, 'vs Chennai Kings');
  });

  testWidgets('a match that cannot be watched does nothing when tapped', (
    tester,
  ) async {
    matches.byStatus['all'] = [sampleMatch('m1', status: 'completed')];
    await pumpScreen(tester);

    await tester.tap(find.text('vs Chennai Kings'));
    await tester.pumpAndSettle();

    expect(find.text('spectating'), findsNothing);
    expect(find.text('Mohit Zatu'), findsOneWidget);
  });
}
