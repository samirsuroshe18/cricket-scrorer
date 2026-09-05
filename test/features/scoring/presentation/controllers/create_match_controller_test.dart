import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _UnusedCreateMatchUseCase implements CreateMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// Records the request it was called with, rather than asserting anything
/// itself — the test decides what to check about the captured request.
class _RecordingCreateMatchUseCase implements CreateMatchUseCase {
  CreateMatchReq? lastRequest;

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> call({
    CreateMatchReq? params,
  }) async {
    lastRequest = params;
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: CreateMatchRes(
          matchId: 'match-1',
          joinCode: 'ABC123',
          teamA: TeamRef(id: 'team-1', name: 'Mumbai Indians'),
          teamB: TeamRef(id: 'team-b', name: params!.teamBName),
          totalOvers: params.totalOvers,
          status: 'upcoming',
          syncStatus: 'local',
          createdAt: '2026-08-20T10:15:00.000Z',
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetMyTeamsUseCase implements GetMyTeamsUseCase {
  List<TeamSummary> teams = const [];

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) async => Either.result(
    CricketResponse(message: 'ok', data: MyTeamsRes(teams: teams)),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetMyTeamsUseCase getMyTeamsUseCase;
  late CreateMatchController controller;

  setUp(() {
    Get.testMode = true;
    getMyTeamsUseCase = _FakeGetMyTeamsUseCase()
      ..teams = [
        TeamSummary(id: 'team-1', name: 'Mumbai Indians'),
        TeamSummary(id: 'team-2', name: 'Chennai Super Kings'),
      ];
    controller = CreateMatchController(
      createMatchUseCase: _UnusedCreateMatchUseCase(),
      getMyTeamsUseCase: getMyTeamsUseCase,
    );
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  test('onInit loads the caller\'s own teams', () async {
    await Future<void>.delayed(Duration.zero);
    expect(controller.myTeams.map((t) => t.id), ['team-1', 'team-2']);
  });

  test('selecting a team sets its id and fills the name field', () async {
    await Future<void>.delayed(Duration.zero);

    controller.selectTeamA(controller.myTeams.first);

    expect(controller.selectedTeamAId.value, 'team-1');
    expect(controller.teamAController.text, 'Mumbai Indians');
  });

  test('retyping the field after a selection clears the selected id', () async {
    await Future<void>.delayed(Duration.zero);

    controller.selectTeamA(controller.myTeams.first);
    controller.teamAController.text = 'Something else';

    expect(controller.selectedTeamAId.value, isNull);
  });

  test('tapping the same chip again clears the selection and the field', () async {
    await Future<void>.delayed(Duration.zero);

    final team = controller.myTeams.first;
    controller.selectTeamA(team);
    controller.selectTeamA(team);

    expect(controller.selectedTeamAId.value, isNull);
    expect(controller.teamAController.text, isEmpty);
  });

  // Neither of the two tests above ever calls createMatch() — the fake
  // there always throws. This is the one integration seam those tests
  // don't cover: that a selected chip's id actually reaches the outgoing
  // request, not just the local selection state. createMatch() reads
  // formKey.currentState, so this needs a real mounted Form rather than a
  // bare unit test.
  testWidgets(
    'createMatch() sends the selected team\'s id, not its typed name, as teamAId',
    (tester) async {
      final recordingUseCase = _RecordingCreateMatchUseCase();
      final widgetController = CreateMatchController(
        createMatchUseCase: recordingUseCase,
        getMyTeamsUseCase: _FakeGetMyTeamsUseCase()
          ..teams = [TeamSummary(id: 'team-1', name: 'Mumbai Indians')],
      );
      widgetController.onInit();
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Form(key: widgetController.formKey, child: const SizedBox()),
          // createMatch() navigates to AppRoutes.scoreBall on success — give
          // it somewhere real to land rather than hanging on an unresolved
          // route.
          getPages: [
            GetPage(
              name: AppRoutes.scoreBall,
              page: () => const Scaffold(body: Text('score ball')),
            ),
          ],
        ),
      );
      // NOT Future.delayed: inside testWidgets() the whole body runs in a
      // fake-async zone, so a real delayed Future never fires on its own —
      // it needs a pump() to advance the fake clock, or it hangs forever.
      await tester.pump();

      widgetController.selectTeamA(widgetController.myTeams.first);
      widgetController.teamBController.text = 'Chennai Super Kings';
      widgetController.oversController.text = '20';

      unawaited(widgetController.createMatch());
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 10),
      );

      final sent = recordingUseCase.lastRequest;
      expect(sent, isNotNull);
      expect(sent!.teamAId, 'team-1');
      expect(sent.teamAName, 'Mumbai Indians');
      expect(sent.teamBId, isNull);
      expect(sent.teamBName, 'Chennai Super Kings');

      widgetController.onClose();
    },
  );
}
