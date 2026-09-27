import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/add_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/set_team_leadership.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_logo.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/remove_team_player.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import '../helpers/picker_fakes.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/add_player_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/edit_roster_player_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _Unused {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedMatches extends _Unused implements GetTeamMatchesUseCase {}

class _UnusedCandidates extends _Unused implements GetScorerCandidatesUseCase {}

class _UnusedAssign extends _Unused implements AssignScorerUseCase {}

class _UnusedLogo extends _Unused implements UpdateTeamLogoUseCase {}

class _UnusedUpdateTeam extends _Unused implements UpdateTeamUseCase {}

class _UnusedDelete extends _Unused implements DeleteTeamUseCase {}

class _FakeProfile extends _Unused implements GetTeamProfileUseCase {
  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) async => Either.result(
    CricketResponse(
      message: 'ok',
      data: TeamProfileRes(
        teamId: 'team-1',
        name: 'Mumbai Indians',
        canManage: true,
        roster: const [],
      ),
    ),
  );
}

class _FakeAdd extends _Unused implements AddTeamPlayerUseCase {
  AddTeamPlayerParams? lastParams;
  Either<CricketResponse<TeamRosterPlayer>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> call({
    AddTeamPlayerParams? params,
  }) async {
    lastParams = params;
    return response ??
        Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamRosterPlayer(
              playerId: 'p1',
              playerName: params!.req.name!,
              role: 'unknown',
            ),
          ),
        );
  }
}

class _FakeRemovePlayer extends _Unused implements RemoveTeamPlayerUseCase {}

class _FakeUpdatePlayer extends _Unused implements UpdateTeamPlayerUseCase {
  UpdateTeamPlayerParams? lastParams;
  String? failWith;

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> call({
    UpdateTeamPlayerParams? params,
  }) async {
    lastParams = params;
    final failure = failWith;
    if (failure != null) {
      return Either.fallback(
        CricketForbiddenErrorFailure(statusCode: 403, message: failure),
      );
    }
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: TeamRosterPlayer(
          playerId: params!.playerId,
          playerName: 'Rohit',
          role: params.req.role ?? 'unknown',
        ),
      ),
    );
  }
}

class _FakeLeadership extends _Unused implements SetTeamLeadershipUseCase {
  SetTeamLeadershipParams? lastParams;

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    SetTeamLeadershipParams? params,
  }) async {
    lastParams = params;
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: CreatedTeamRes(id: 'team-1', name: 'Mumbai Indians'),
      ),
    );
  }
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  late _FakeAdd add;
  late _FakeUpdatePlayer updatePlayer;
  late _FakeLeadership leadership;
  late TeamProfileController controller;

  Future<void> pumpOpener(
    WidgetTester tester,
    Future<void> Function() open, {
    TeamProfileRes? profile,
  }) async {
    add = _FakeAdd();
    updatePlayer = _FakeUpdatePlayer();
    leadership = _FakeLeadership();
    controller = TeamProfileController(
      teamId: 'team-1',
      getTeamProfileUseCase: _FakeProfile(),
      getTeamMatchesUseCase: _UnusedMatches(),
      getScorerCandidatesUseCase: _UnusedCandidates(),
      assignScorerUseCase: _UnusedAssign(),
      updateTeamLogoUseCase: _UnusedLogo(),
      updateTeamUseCase: _UnusedUpdateTeam(),
      deleteTeamUseCase: _UnusedDelete(),
      addTeamPlayerUseCase: add,
      updateTeamPlayerUseCase: updatePlayer,
      removeTeamPlayerUseCase: _FakeRemovePlayer(),
      setTeamLeadershipUseCase: leadership,
      getMyPlayersUseCase: emptyMyPlayers(),
      lookupUserByEmailUseCase: FakeLookupUserByEmailUseCase(),
      inviteTeamPlayerUseCase: FakeInviteTeamPlayerUseCase(),
    );
    controller.profile.value = profile;
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => open(),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  // `controller` is created inside pumpOpener; the closure reads it lazily,
  // at tap time.
  // The sheet opens on the picker; these tests are about the create-by-name
  // form, one tap away.
  Future<void> pumpAddSheet(WidgetTester tester) async {
    await pumpOpener(tester, () => showAddPlayerSheet(controller: controller));
    await tester.tap(find.text(TranslationKeys.createNewPlayer));
    await tester.pumpAndSettle();
  }

  group('add player sheet', () {
    testWidgets('rejects an empty name and does not submit', (tester) async {
      await pumpAddSheet(tester);

      await tester.tap(find.text(TranslationKeys.addPlayer).last);
      await tester.pump();

      expect(find.text(TranslationKeys.playerNameRequired), findsOneWidget);
      expect(add.lastParams, isNull);
    });

    testWidgets('rejects a jersey number that is not 0-999', (tester) async {
      await pumpAddSheet(tester);

      await tester.enterText(find.byType(TextField).first, 'Rohit');
      await tester.enterText(find.byType(TextField).last, '-1');
      await tester.tap(find.text(TranslationKeys.addPlayer).last);
      await tester.pump();

      expect(find.text(TranslationKeys.jerseyNumberInvalid), findsOneWidget);
      expect(add.lastParams, isNull);
    });

    testWidgets('submits the trimmed name, chosen role and jersey number', (
      tester,
    ) async {
      await pumpAddSheet(tester);

      await tester.enterText(find.byType(TextField).first, '  Rohit ');
      await tester.tap(find.text(TranslationKeys.roleBatsman));
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, '45');
      await tester.tap(find.text(TranslationKeys.addPlayer).last);
      await tester.pumpAndSettle();

      final req = add.lastParams!.req;
      expect(add.lastParams!.teamId, 'team-1');
      expect(req.name, 'Rohit');
      expect(req.role, 'batsman');
      expect(req.jerseyNumber, 45);
    });

    testWidgets(
      'a failure shows the server message inline, and a retry that succeeds '
      'closes the sheet',
      (tester) async {
        await pumpAddSheet(tester);
        add.response = Either.fallback(
          CricketBadRequestFailure(statusCode: 400, message: 'Bad name'),
        );

        await tester.enterText(find.byType(TextField).first, 'Rohit');
        await tester.tap(find.text(TranslationKeys.addPlayer).last);
        await tester.pumpAndSettle();

        expect(find.text('Bad name'), findsOneWidget);
        expect(find.byType(AddPlayerForm), findsOneWidget);

        add.response = null; // the retry succeeds
        // The inline error grows the form; scroll the button back into view.
        await tester.ensureVisible(find.text(TranslationKeys.addPlayer).last);
        await tester.pump();
        await tester.tap(find.text(TranslationKeys.addPlayer).last);
        await tester.pumpAndSettle();

        expect(find.byType(AddPlayerForm), findsNothing);
      },
    );

    testWidgets('an unset role and jersey number are omitted', (tester) async {
      await pumpAddSheet(tester);

      await tester.enterText(find.byType(TextField).first, 'Rohit');
      await tester.tap(find.text(TranslationKeys.addPlayer).last);
      await tester.pumpAndSettle();

      expect(add.lastParams!.req.role, isNull);
      expect(add.lastParams!.req.jerseyNumber, isNull);
    });
  });

  group('edit roster player sheet', () {
    final player = TeamRosterPlayer(
      playerId: 'p1',
      playerName: 'Rohit',
      jerseyNumber: 45,
      role: 'batsman',
    );

    Future<void> pumpEditSheet(
      WidgetTester tester, {
      TeamRosterPlayer? row,
      String? captainId,
      String? viceCaptainId,
    }) async {
      final row0 = row ?? player;
      await pumpOpener(
        tester,
        () => showEditRosterPlayerSheet(controller: controller, player: row0),
        profile: TeamProfileRes(
          teamId: 'team-1',
          name: 'Mumbai Indians',
          shortName: 'MI',
          canManage: true,
          roster: [row0],
          captainId: captainId,
          viceCaptainId: viceCaptainId,
        ),
      );
    }

    testWidgets('prefills the current jersey number', (tester) async {
      await pumpEditSheet(tester);

      expect(find.widgetWithText(TextField, '45'), findsOneWidget);
    });

    testWidgets('saves the changed role and jersey number', (tester) async {
      await pumpEditSheet(tester);

      await tester.tap(find.text(TranslationKeys.roleBowler));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, '45'), '7');
      await tester.tap(find.text(TranslationKeys.saveChanges).last);
      await tester.pumpAndSettle();

      expect(updatePlayer.lastParams?.playerId, 'p1');
      expect(updatePlayer.lastParams?.req.role, 'bowler');
      expect(updatePlayer.lastParams?.req.jerseyNumber, 7);
    });

    testWidgets(
      'clearing a previously set jersey number asks the server to remove it',
      (
        tester,
      ) async {
        await pumpEditSheet(tester);

        await tester.enterText(find.widgetWithText(TextField, '45'), '');
        await tester.tap(find.text(TranslationKeys.saveChanges).last);
        await tester.pumpAndSettle();

        expect(updatePlayer.lastParams?.req.clearJerseyNumber, isTrue);
      },
    );

    testWidgets('leaving the jersey number alone does not clear it', (
      tester,
    ) async {
      await pumpEditSheet(tester);

      await tester.tap(find.text(TranslationKeys.saveChanges).last);
      await tester.pumpAndSettle();

      expect(updatePlayer.lastParams?.req.clearJerseyNumber, isFalse);
      expect(updatePlayer.lastParams?.req.jerseyNumber, 45);
    });

    testWidgets('a failed save shows the server message inline', (
      tester,
    ) async {
      await pumpEditSheet(tester);
      updatePlayer.failWith = 'Not allowed';

      await tester.tap(find.text(TranslationKeys.saveChanges).last);
      await tester.pumpAndSettle();

      expect(find.text('Not allowed'), findsOneWidget);
      expect(find.byType(EditRosterPlayerForm), findsOneWidget);
    });

    testWidgets('offers make captain and make vice-captain for a non-leader', (
      tester,
    ) async {
      await pumpEditSheet(tester);

      expect(find.text(TranslationKeys.makeCaptain), findsOneWidget);
      expect(find.text(TranslationKeys.makeViceCaptain), findsOneWidget);
      expect(find.text(TranslationKeys.removeCaptain), findsNothing);
    });

    testWidgets('make captain writes the leadership and closes the sheet', (
      tester,
    ) async {
      await pumpEditSheet(tester);

      await tester.tap(find.text(TranslationKeys.makeCaptain));
      await tester.pumpAndSettle();

      expect(leadership.lastParams?.req.captainId, 'p1');
      expect(find.text(TranslationKeys.makeCaptain), findsNothing);
    });

    testWidgets('a current captain sees remove captain, not make captain', (
      tester,
    ) async {
      await pumpEditSheet(
        tester,
        row: TeamRosterPlayer(
          playerId: 'p1',
          playerName: 'Rohit',
          role: 'batsman',
          isCaptain: true,
        ),
        captainId: 'p1',
      );

      expect(find.text(TranslationKeys.removeCaptain), findsOneWidget);
      expect(find.text(TranslationKeys.makeCaptain), findsNothing);

      await tester.tap(find.text(TranslationKeys.removeCaptain));
      await tester.pumpAndSettle();

      expect(leadership.lastParams?.req.captainId, isNull);
    });
  });
}
