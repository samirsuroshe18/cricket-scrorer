import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/squad_screen.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/invite_by_email_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/picker_fakes.dart';
import '../helpers/squad_fakes.dart';

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
  late FakeGetTeamInvites teamInvites;
  late FakeCancelTeamInvite cancelInvite;

  Future<void> pump(
    WidgetTester tester, {
    MatchSquadRes? squad,
    Map<String, List<TeamInviteItemRes>> invites = const {},
    int? minPlayingXi,
    int? maxPlayingXi,
  }) async {
    save = _Save();
    teamInvites = FakeGetTeamInvites({...invites});
    cancelInvite = FakeCancelTeamInvite();
    errors = [];
    openedCount = 0;
    controller = Get.put<SquadController>(
      SquadController(
        match: CreateMatchRes(
          matchId: 'm1',
          teamA: TeamRef(id: 'ta', name: 'Mumbai Indians'),
          teamB: TeamRef(id: 'tb', name: 'Chennai Kings'),
          totalOvers: 5,
          minPlayingXi: minPlayingXi,
          maxPlayingXi: maxPlayingXi,
          status: 'upcoming',
          syncStatus: 'local',
          createdAt: '2026-09-26T00:00:00.000Z',
        ),
        getTeamProfileUseCase: _EmptyProfile(),
        saveSquadUseCase: save,
        getMatchSquadUseCase: FakeGetMatchSquad()..squad = squad,
        savePlayingXiUseCase: FakeSavePlayingXi(),
        getTeamInvitesUseCase: teamInvites,
        cancelTeamInviteUseCase: cancelInvite,
        acknowledgeSquadUseCase: FakeAcknowledgeSquad(),
        lookupUserByEmailUseCase: FakeLookupUserByEmailUseCase(),
        inviteTeamPlayerUseCase: FakeInviteTeamPlayerUseCase(),
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

  testWidgets('shows no Playing XI size hint when the match carries no range', (
    tester,
  ) async {
    await pump(tester);

    expect(
      find.text(
        TranslationKeys.squadPlayingXiSizeHint.trParams({
          'min': '2',
          'max': '11',
        }),
      ),
      findsNothing,
    );
  });

  testWidgets('shows the Playing XI size hint when the match carries a range', (
    tester,
  ) async {
    await pump(tester, minPlayingXi: 6, maxPlayingXi: 8);

    expect(
      find.text(
        TranslationKeys.squadPlayingXiSizeHint.trParams({
          'min': '6',
          'max': '8',
        }),
      ),
      findsOneWidget,
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

  testWidgets(
    'the C badge is reachable through semantics and names its player',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      await addPlayer(tester, 'Rohit');

      final label = '${TranslationKeys.captain.tr}, Rohit';
      expect(find.bySemanticsLabel(label), findsOneWidget);

      tester.semantics.tap(find.semantics.byLabel(label));
      await tester.pump();

      expect(controller.current.captain, 'Rohit');
      handle.dispose();
    },
  );

  group('Playing XI, Bench and Invitations', () {
    SquadSidePlayerRes sp(String id, String name) =>
        SquadSidePlayerRes(playerId: id, name: name, role: 'batsman');

    MatchSquadRes squad({bool inningsStarted = false}) => MatchSquadRes(
      matchId: 'm1',
      inningsStarted: inningsStarted,
      teamA: SquadSideRes(
        teamId: 'ta',
        players: [sp('p1', 'Rohit'), sp('p2', 'Pant'), sp('p3', 'Bumrah')],
        playingXI: ['p1', 'p2'],
        savedAt: '2026-09-28T10:00:00.000Z',
      ),
      teamB: SquadSideRes(teamId: 'tb'),
    );

    TeamInviteItemRes invite(String id, String status, String name) =>
        TeamInviteItemRes(
          inviteId: id,
          status: status,
          respondedAt: status == 'pending' ? null : '2026-09-28T09:00:00.000Z',
          player: InvitedPlayerRes(playerId: 'p-$id', playerName: name),
          invitee: InviteeUserRes(userId: 'u-$id', fullName: name),
        );

    // A ListView only builds what is on screen; these tests look at both
    // sections and the invitations, so give them room.
    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(1000, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    String headerText(WidgetTester tester, String key) => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(Text),
          ),
        )
        .single
        .data!;

    testWidgets('players sit under Playing XI and Bench with their counts', (
      tester,
    ) async {
      tall(tester);
      await pump(tester, squad: squad());
      await tester.pump();

      expect(
        headerText(tester, 'squad_section_xi'),
        '${TranslationKeys.squadPlayingXi} (2)',
      );
      expect(
        headerText(tester, 'squad_section_bench'),
        '${TranslationKeys.squadBench} (1)',
      );
      expect(find.byKey(const Key('squad_toBench_Rohit')), findsOneWidget);
      expect(find.byKey(const Key('squad_toBench_Pant')), findsOneWidget);
      expect(find.byKey(const Key('squad_toXi_Bumrah')), findsOneWidget);
      expect(find.byKey(const Key('squad_toXi_Rohit')), findsNothing);
    });

    testWidgets('moving a player between the sections updates both counts', (
      tester,
    ) async {
      tall(tester);
      await pump(tester, squad: squad());
      await tester.pump();

      await tester.tap(find.byKey(const Key('squad_toXi_Bumrah')));
      await tester.pump();
      expect(
        headerText(tester, 'squad_section_xi'),
        '${TranslationKeys.squadPlayingXi} (3)',
      );
      expect(find.byKey(const Key('squad_toBench_Bumrah')), findsOneWidget);

      await tester.tap(find.byKey(const Key('squad_toBench_Rohit')));
      await tester.pump();
      expect(
        headerText(tester, 'squad_section_xi'),
        '${TranslationKeys.squadPlayingXi} (2)',
      );
      expect(
        headerText(tester, 'squad_section_bench'),
        '${TranslationKeys.squadBench} (1)',
      );
      expect(find.byKey(const Key('squad_toXi_Rohit')), findsOneWidget);
    });

    testWidgets('Invite by email opens the invite panel', (tester) async {
      tall(tester);
      await pump(tester);

      await tester.tap(find.byKey(const Key('squad_inviteButton')));
      await tester.pumpAndSettle();

      expect(find.byType(InviteByEmailPanel), findsOneWidget);
    });

    testWidgets(
      'once the innings has started only XI moves and invites are offered',
      (
        tester,
      ) async {
        await pump(tester, squad: squad(inningsStarted: true));
        await tester.pump();

        expect(find.byKey(const Key('squad_nameField')), findsNothing);
        expect(find.byKey(const Key('squad_addButton')), findsNothing);
        expect(find.byKey(const Key('squad_c_Rohit')), findsNothing);
        expect(find.byKey(const Key('squad_role_Rohit_batsman')), findsNothing);
        expect(find.byKey(const Key('squad_remove_Rohit')), findsNothing);
        expect(find.byKey(const Key('squad_toBench_Rohit')), findsOneWidget);
        expect(find.byKey(const Key('squad_toXi_Bumrah')), findsOneWidget);
        expect(find.byKey(const Key('squad_inviteButton')), findsOneWidget);
      },
    );

    testWidgets(
      'invitations show their status and Cancel asks the controller',
      (
        tester,
      ) async {
        await pump(
          tester,
          invites: {
            'ta': [
              invite('i1', 'pending', 'Pia'),
              invite('i2', 'declined', 'Dev'),
            ],
          },
        );
        await tester.pump();

        expect(find.byKey(const Key('squad_section_invites')), findsOneWidget);
        expect(find.text(TranslationKeys.inviteStatusWaiting), findsOneWidget);
        expect(find.text(TranslationKeys.inviteStatusDeclined), findsOneWidget);

        await tester.tap(find.byKey(const Key('invite_cancel_i1')));
        await tester.pump();

        expect(cancelInvite.calls.single.inviteId, 'i1');
        expect(cancelInvite.calls.single.teamId, 'ta');
      },
    );

    testWidgets('the other team shows its own invitations', (tester) async {
      tall(tester);
      await pump(
        tester,
        invites: {
          'tb': [invite('i9', 'pending', 'Other Side')],
        },
      );
      await tester.pump();
      expect(find.text('Other Side'), findsNothing);

      await tester.tap(find.byKey(const Key('squad_side_teamB')));
      await tester.pump();

      expect(find.text('Other Side'), findsOneWidget);
    });

    testWidgets('pulling down re-reads the invitations', (tester) async {
      tall(tester);
      await pump(tester);
      await tester.pump();
      final before = teamInvites.asked.length;

      // RefreshIndicator wants a pull of about a quarter of the viewport.
      await tester.drag(
        find.byType(ListView).first,
        const Offset(0, 1200),
        touchSlopY: 0,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(teamInvites.asked.length, greaterThan(before));
    });
  });
}
