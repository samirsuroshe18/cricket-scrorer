import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/select_team_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/select_team_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/select_team_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Returns [teams] for every search, and records the last params it was
/// asked with so a test can assert what the screen sent upstream.
class _FakeGetMyTeamsUseCase implements GetMyTeamsUseCase {
  List<TeamSummary> teams = const [];
  GetMyTeamsParams? lastParams;
  int calls = 0;

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    GetMyTeamsParams? params,
  }) async {
    calls++;
    lastParams = params;
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: MyTeamsRes(teams: teams, page: 1, limit: 20, total: teams.length),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetMyTeamsUseCase useCase;
  dynamic lastResult;

  setUp(() {
    lastResult = null;
    Get.testMode = true;
    useCase = _FakeGetMyTeamsUseCase();
    Get.put<GetMyTeamsUseCase>(useCase);
  });

  tearDown(Get.reset);

  // Reassigned by the host screen's TextButton callback below, which can't
  // return a value to the caller — declared before hostApp/openPicker so
  // both closures (defined below, but only ever called from inside a test
  // body, after this line has already run) can see it.

  /// A host screen that pushes SelectTeamScreen and captures whatever it
  /// pops back with — mirrors how CreateMatchController actually consumes
  /// this screen's result via `Get.toNamed<dynamic>`.
  Widget hostApp({
    String initialQuery = '',
    String? excludeTeamId,
    String? excludeName,
  }) {
    return GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Get.toNamed<dynamic>(
                AppRoutes.selectTeam,
                arguments: SelectTeamArgs(
                  title: 'Select Team A',
                  initialQuery: initialQuery,
                  excludeTeamId: excludeTeamId,
                  excludeName: excludeName,
                ),
              );
              lastResult = result;
            },
            child: const Text('open'),
          ),
        ),
      ),
      getPages: [
        GetPage(
          name: AppRoutes.selectTeam,
          page: () => const SelectTeamScreen(),
          binding: SelectTeamBinding(),
        ),
      ],
    );
  }

  Future<void> openPicker(
    WidgetTester tester, {
    String initialQuery = '',
  }) async {
    await tester.pumpWidget(hostApp(initialQuery: initialQuery));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('search field caps input at 50 characters, matching '
      'Team.name\'s backend maxlength', (tester) async {
    await openPicker(tester);

    final tooLongName = 'A' * 60;
    await tester.enterText(find.byType(TextFormField), tooLongName);
    await tester.pump();

    final controller = Get.find<SelectTeamController>();
    expect(controller.queryController.text.length, lessThanOrEqualTo(50));
  });

  testWidgets(
    'shows a hint, not an error, before anything is typed with no teams',
    (
      tester,
    ) async {
      await openPicker(tester);
      await tester.pumpAndSettle();

      expect(find.text(TranslationKeys.searchOrAddTeam.tr), findsWidgets);
    },
  );

  testWidgets('typing shows matching results after the debounce', (
    tester,
  ) async {
    useCase.teams = [TeamSummary(id: 't1', name: 'Mumbai Indians')];
    await openPicker(tester);

    await tester.enterText(find.byType(TextFormField), 'mumbai');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Mumbai Indians'), findsOneWidget);
  });

  testWidgets('no match shows the no-match message and a create-new row', (
    tester,
  ) async {
    useCase.teams = const [];
    await openPicker(tester);

    await tester.enterText(find.byType(TextFormField), 'zzz');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(TranslationKeys.teamSearchNoMatch.tr), findsOneWidget);
    expect(
      find.text(TranslationKeys.useAsNewTeam.trParams({'name': 'zzz'})),
      findsOneWidget,
    );
  });

  testWidgets('tapping a result pops back with the picked TeamSummary', (
    tester,
  ) async {
    final team = TeamSummary(id: 't1', name: 'Mumbai Indians');
    useCase.teams = [team];
    await openPicker(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mumbai Indians'));
    await tester.pumpAndSettle();

    expect(lastResult, isA<TeamSummary>());
    expect((lastResult as TeamSummary).id, 't1');
  });

  testWidgets('a team already picked for the other side is not selectable', (
    tester,
  ) async {
    useCase.teams = [
      TeamSummary(id: 't1', name: 'Mumbai Indians'),
      TeamSummary(id: 't2', name: 'Chennai'),
    ];
    await tester.pumpWidget(hostApp(excludeTeamId: 't1'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text(TranslationKeys.teamAlreadyPicked.tr), findsOneWidget);

    await tester.tap(find.text('Mumbai Indians'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(lastResult, isNull);

    await tester.tap(find.text('Chennai'));
    await tester.pumpAndSettle();
    expect((lastResult as TeamSummary).id, 't2');
  });

  testWidgets('typing the other side\'s name offers no "use as new team" row', (
    tester,
  ) async {
    useCase.teams = const [];
    await tester.pumpWidget(hostApp(excludeName: 'Alpha'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), ' alpha ');
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text(TranslationKeys.useAsNewTeam.trParams({'name': 'alpha'})),
      findsNothing,
    );
  });

  testWidgets('tapping "use as new team" pops back with the trimmed name', (
    tester,
  ) async {
    useCase.teams = const [];
    await openPicker(tester);

    await tester.enterText(find.byType(TextFormField), '  Newtown XI  ');
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(
      find.text(TranslationKeys.useAsNewTeam.trParams({'name': 'Newtown XI'})),
    );
    await tester.pumpAndSettle();

    expect(lastResult, 'Newtown XI');
  });

  testWidgets('picking a filter re-searches with that owner scope', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(TranslationKeys.filterYourTeams.tr));
    await tester.pump(const Duration(milliseconds: 500));

    expect(useCase.lastParams?.owner, TeamOwnerFilter.mine);
  });

  testWidgets('the app bar shows the title passed in via arguments', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.pumpAndSettle();

    expect(find.text('Select Team A'), findsOneWidget);
  });
}
