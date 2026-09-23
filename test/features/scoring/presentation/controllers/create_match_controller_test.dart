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

/// Never actually called by these tests — SelectTeamScreen owns its own
/// GetMyTeamsUseCase call now; CreateMatchController only reacts to
/// whatever that screen hands back via Get.back(result: ...).
class _UnusedGetMyTeamsUseCase implements GetMyTeamsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late CreateMatchController controller;

  setUp(() {
    Get.testMode = true;
    controller = CreateMatchController(
      createMatchUseCase: _UnusedCreateMatchUseCase(),
      getMyTeamsUseCase: _UnusedGetMyTeamsUseCase(),
    );
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  test('overs defaults to the 5-over preset on init', () {
    expect(controller.oversController.text, '5');
    expect(controller.selectedOversPreset.value, OversPreset.five);
  });

  test('selecting a team sets its id, logo and fills the name field', () async {
    final team = TeamSummary(
      id: 'team-1',
      name: 'Mumbai Indians',
      logoUrl: 'https://example.com/mi.png',
    );

    controller.selectTeamA(team);

    expect(controller.selectedTeamAId.value, 'team-1');
    expect(controller.teamAController.text, 'Mumbai Indians');
    expect(controller.selectedTeamALogoUrl, 'https://example.com/mi.png');
  });

  test('retyping the field after a selection clears the selected id and logo', () async {
    controller.selectTeamA(
      TeamSummary(id: 'team-1', name: 'Mumbai Indians', logoUrl: 'x'),
    );
    controller.teamAController.text = 'Something else';

    expect(controller.selectedTeamAId.value, isNull);
    expect(controller.selectedTeamALogoUrl, isNull);
  });

  test('selecting a second team replaces the first selection', () async {
    controller.selectTeamA(TeamSummary(id: 'team-1', name: 'Mumbai Indians'));
    controller.selectTeamA(TeamSummary(id: 'team-2', name: 'Chennai Super Kings'));

    expect(controller.selectedTeamAId.value, 'team-2');
    expect(controller.teamAController.text, 'Chennai Super Kings');
  });

  test('setTeamAFreeText clears any selection and sets the typed name', () {
    controller.selectTeamA(TeamSummary(id: 'team-1', name: 'Mumbai Indians'));

    controller.setTeamAFreeText('Brand New Team');

    expect(controller.selectedTeamAId.value, isNull);
    expect(controller.selectedTeamALogoUrl, isNull);
    expect(controller.teamAController.text, 'Brand New Team');
  });

  group('swapTeams', () {
    test('trades typed names between two free-text sides', () {
      controller.setTeamAFreeText('Alpha');
      controller.setTeamBFreeText('Bravo');

      controller.swapTeams();

      expect(controller.teamAController.text, 'Bravo');
      expect(controller.teamBController.text, 'Alpha');
    });

    test('trades selected-team ids and logos along with the names', () {
      controller.selectTeamA(
        TeamSummary(id: 'team-1', name: 'Mumbai Indians', logoUrl: 'mi.png'),
      );
      controller.setTeamBFreeText('New Opponent');

      controller.swapTeams();

      expect(controller.teamAController.text, 'New Opponent');
      expect(controller.selectedTeamAId.value, isNull);
      expect(controller.selectedTeamALogoUrl, isNull);

      expect(controller.teamBController.text, 'Mumbai Indians');
      expect(controller.selectedTeamBId.value, 'team-1');
      expect(controller.selectedTeamBLogoUrl, 'mi.png');
    });

    test('a swapped-in selection survives its own text-changed listener', () {
      // Regression guard: swapTeams sets id/name/logo *before* the
      // controller text, specifically so the text-changed listener (which
      // clears a selection the moment the field stops matching it) sees the
      // new text already matching the new name and leaves it alone.
      controller.selectTeamA(TeamSummary(id: 'team-1', name: 'Mumbai Indians'));
      controller.selectTeamB(TeamSummary(id: 'team-2', name: 'Chennai Super Kings'));

      controller.swapTeams();

      expect(controller.selectedTeamAId.value, 'team-2');
      expect(controller.selectedTeamBId.value, 'team-1');
    });
  });

  group('overs presets', () {
    test('tapping T20 sets the field to 20 and marks the preset selected', () {
      controller.selectOversPreset(OversPreset.t20);

      expect(controller.oversController.text, '20');
      expect(controller.selectedOversPreset.value, OversPreset.t20);
    });

    test('tapping Custom leaves the field as-is for manual entry', () {
      controller.oversController.text = '15';

      controller.selectOversPreset(OversPreset.custom);

      expect(controller.oversController.text, '15');
      expect(controller.selectedOversPreset.value, OversPreset.custom);
    });

    test('editing the field away from the selected preset falls back to custom', () {
      controller.selectOversPreset(OversPreset.t20);

      controller.oversController.text = '18';

      expect(controller.selectedOversPreset.value, OversPreset.custom);
    });
  });

  group('onTapTeamA/onTapTeamB navigation', () {
    Widget wrap({required VoidCallback onTap, required GetPageBuilder pickerPage}) {
      return GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: TextButton(onPressed: onTap, child: const Text('open picker')),
        ),
        getPages: [GetPage(name: AppRoutes.selectTeam, page: pickerPage)],
      );
    }

    testWidgets('applies an existing team the picker returns', (tester) async {
      final picked = TeamSummary(id: 'team-9', name: 'Picked FC', logoUrl: 'p.png');
      await tester.pumpWidget(
        wrap(
          onTap: controller.onTapTeamA,
          pickerPage: () {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => Get.back(result: picked),
            );
            return const Scaffold(body: SizedBox());
          },
        ),
      );

      await tester.tap(find.text('open picker'));
      await tester.pumpAndSettle();

      expect(controller.selectedTeamAId.value, 'team-9');
      expect(controller.teamAController.text, 'Picked FC');
      expect(controller.selectedTeamALogoUrl, 'p.png');
    });

    testWidgets('treats a returned String as a confirmed new team name', (tester) async {
      await tester.pumpWidget(
        wrap(
          onTap: controller.onTapTeamB,
          pickerPage: () {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => Get.back(result: 'Brand New XI'),
            );
            return const Scaffold(body: SizedBox());
          },
        ),
      );

      await tester.tap(find.text('open picker'));
      await tester.pumpAndSettle();

      expect(controller.selectedTeamBId.value, isNull);
      expect(controller.teamBController.text, 'Brand New XI');
    });

    testWidgets('backing out with no result leaves the field untouched', (tester) async {
      controller.setTeamAFreeText('Already Here');
      await tester.pumpWidget(
        wrap(
          onTap: controller.onTapTeamA,
          pickerPage: () {
            WidgetsBinding.instance.addPostFrameCallback((_) => Get.back<dynamic>());
            return const Scaffold(body: SizedBox());
          },
        ),
      );

      await tester.tap(find.text('open picker'));
      await tester.pumpAndSettle();

      expect(controller.teamAController.text, 'Already Here');
    });
  });

  group('createMatch() team-name validation', () {
    testWidgets('an empty Team A blocks submission with the required message', (
      tester,
    ) async {
      final recordingUseCase = _RecordingCreateMatchUseCase();
      final widgetController = CreateMatchController(
        createMatchUseCase: recordingUseCase,
        getMyTeamsUseCase: _UnusedGetMyTeamsUseCase(),
      );
      widgetController.onInit();
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Form(key: widgetController.formKey, child: const SizedBox()),
        ),
      );
      await tester.pump();

      widgetController.setTeamBFreeText('Chennai Super Kings');
      // Team A left blank.

      unawaited(widgetController.createMatch());
      await tester.pumpAndSettle();

      expect(recordingUseCase.lastRequest, isNull);
      widgetController.onClose();
    });
  });

  // This is the one integration seam the unit tests above don't cover: that
  // a selected team's id actually reaches the outgoing request, not just
  // the local selection state. createMatch() reads formKey.currentState, so
  // this needs a real mounted Form rather than a bare unit test.
  testWidgets(
    'createMatch() sends the selected team\'s id, not its typed name, as teamAId',
    (tester) async {
      final recordingUseCase = _RecordingCreateMatchUseCase();
      final widgetController = CreateMatchController(
        createMatchUseCase: recordingUseCase,
        getMyTeamsUseCase: _UnusedGetMyTeamsUseCase(),
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

      widgetController.selectTeamA(
        TeamSummary(id: 'team-1', name: 'Mumbai Indians'),
      );
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
