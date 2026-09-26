import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/squad_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _EmptyProfile implements GetTeamProfileUseCase {
  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) async => Either.result(
    CricketResponse(
      message: 'ok',
      data: TeamProfileRes(
        teamId: params!.teamId,
        name: 'T',
        canManage: true,
        roster: const [],
      ),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _Save implements SaveSquadUseCase {
  final List<SaveSquadParams> calls = [];
  String? failWith;

  @override
  Future<Either<CricketResponse<SquadRes>, CricketFailure>> call({
    SaveSquadParams? params,
  }) async {
    calls.add(params!);
    if (failWith != null) {
      return Either.fallback(CricketFailure(message: failWith!));
    }
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: SquadRes(side: params.req.side, players: const []),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _Save save;
  late List<String> errors;
  var openedCount = 0;
  late SquadController controller;

  Future<void> pump(WidgetTester tester) async {
    save = _Save();
    errors = [];
    openedCount = 0;
    controller = Get.put<SquadController>(
      SquadController(
        match: CreateMatchRes(
          matchId: 'm1',
          teamA: TeamRef(id: 'ta', name: 'Mumbai Indians'),
          teamB: TeamRef(id: 'tb', name: 'Chennai Kings'),
          totalOvers: 5,
          status: 'upcoming',
          syncStatus: 'local',
          createdAt: '2026-09-26T00:00:00.000Z',
        ),
        getTeamProfileUseCase: _EmptyProfile(),
        saveSquadUseCase: save,
        showError: errors.add,
        openScoring: (_) => openedCount += 1,
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const SquadScreen()),
    );
    await tester.pump();
  }

  Future<void> addPlayer(WidgetTester tester, String name) async {
    await tester.enterText(find.byKey(const Key('squad_nameField')), name);
    await tester.tap(find.byKey(const Key('squad_addButton')));
    await tester.pump();
  }

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('adding a player shows a row and clears the field', (
    tester,
  ) async {
    await pump(tester);

    await addPlayer(tester, 'Rohit');

    expect(find.byKey(const Key('squad_row_Rohit')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('squad_nameField')))
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('the Team A / Team B toggle swaps the visible squad', (
    tester,
  ) async {
    await pump(tester);
    await addPlayer(tester, 'Rohit');

    await tester.tap(find.byKey(const Key('squad_side_teamB')));
    await tester.pump();

    expect(find.byKey(const Key('squad_row_Rohit')), findsNothing);
    expect(controller.side.value, 'teamB');

    await tester.tap(find.byKey(const Key('squad_side_teamA')));
    await tester.pump();
    expect(find.byKey(const Key('squad_row_Rohit')), findsOneWidget);
  });

  testWidgets('tapping C then VC on the same player leaves only VC', (
    tester,
  ) async {
    await pump(tester);
    await addPlayer(tester, 'Rohit');

    await tester.tap(find.byKey(const Key('squad_c_Rohit')));
    await tester.pump();
    expect(controller.current.captain, 'Rohit');

    await tester.tap(find.byKey(const Key('squad_vc_Rohit')));
    await tester.pump();
    expect(controller.current.captain, isNull);
    expect(controller.current.viceCaptain, 'Rohit');
  });

  testWidgets('tapping WK marks the keeper', (tester) async {
    await pump(tester);
    await addPlayer(tester, 'Pant');

    await tester.tap(find.byKey(const Key('squad_wk_Pant')));
    await tester.pump();

    expect(controller.current.keeper, 'Pant');
  });

  testWidgets('Skip opens scoring without a request', (tester) async {
    await pump(tester);
    await addPlayer(tester, 'Rohit');

    await tester.tap(find.byKey(const Key('squad_skip')));
    await tester.pump();

    expect(openedCount, 1);
    expect(save.calls, isEmpty);
  });

  testWidgets('Save & continue saves and opens scoring', (tester) async {
    await pump(tester);
    await addPlayer(tester, 'Rohit');

    await tester.tap(find.byKey(const Key('squad_save')));
    await tester.pump();

    expect(save.calls.single.req.side, 'teamA');
    expect(openedCount, 1);
  });

  testWidgets('a server error is shown and the screen stays usable', (
    tester,
  ) async {
    await pump(tester);
    save.failWith = 'nope';
    await addPlayer(tester, 'Rohit');

    await tester.tap(find.byKey(const Key('squad_save')));
    await tester.pump();

    expect(errors, ['nope']);
    expect(openedCount, 0);
    expect(find.byKey(const Key('squad_row_Rohit')), findsOneWidget);
    expect(find.text(TranslationKeys.skip.tr), findsOneWidget);
  });
}
