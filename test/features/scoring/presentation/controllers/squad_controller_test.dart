import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/cancel_team_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_squad.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_invites.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/invite_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/lookup_user_by_email.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_playing_xi.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/squad_fakes.dart';

class _FakeGetTeamProfile implements GetTeamProfileUseCase {
  final Map<String, List<TeamRosterPlayer>> rosters;
  final List<String> asked = [];

  _FakeGetTeamProfile(this.rosters);

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) async {
    asked.add(params!.teamId);
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: TeamProfileRes(
          teamId: params.teamId,
          name: 'T',
          canManage: true,
          roster: rosters[params.teamId] ?? const [],
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeSaveSquad implements SaveSquadUseCase {
  final List<SaveSquadParams> calls = [];
  bool fail = false;

  /// When set, the next call waits on it — lets a test hold a save in flight.
  Completer<void>? gate;

  @override
  Future<Either<CricketResponse<SquadRes>, CricketFailure>> call({
    SaveSquadParams? params,
  }) async {
    calls.add(params!);
    final wait = gate;
    gate = null;
    if (wait != null) await wait.future;
    if (fail) {
      return Either.fallback(CricketFailure(message: 'server said no'));
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

class _FakeInviteTeamPlayer implements InviteTeamPlayerUseCase {
  final List<InviteTeamPlayerParams> calls = [];
  Either<CricketResponse<TeamInviteRes>, CricketFailure>? response;

  @override
  Future<Either<CricketResponse<TeamInviteRes>, CricketFailure>> call({
    InviteTeamPlayerParams? params,
  }) async {
    calls.add(params!);
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeLookup implements LookupUserByEmailUseCase {
  @override
  Future<Either<CricketResponse<LookedUpUserRes>, CricketFailure>> call({
    LookupUserParams? params,
  }) async => Either.result(
    CricketResponse(
      message: 'ok',
      data: LookedUpUserRes(userId: 'u1', fullName: 'Rahul'),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

CreateMatchRes _match() => CreateMatchRes(
  matchId: 'm1',
  teamA: TeamRef(id: 'ta', name: 'Team A'),
  teamB: TeamRef(id: 'tb', name: 'Team B'),
  totalOvers: 5,
  status: 'upcoming',
  syncStatus: 'local',
  createdAt: '2026-09-26T00:00:00.000Z',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeGetTeamProfile profile;
  late _FakeSaveSquad save;
  late FakeGetMatchSquad matchSquad;
  late FakeSavePlayingXi savePlayingXi;
  late FakeGetTeamInvites teamInvites;
  late FakeCancelTeamInvite cancelInvite;
  late _FakeInviteTeamPlayer inviteTeamPlayer;
  late List<String> errors;
  late List<CreateMatchRes> opened;
  late int closed;

  SquadController build({
    Map<String, List<TeamRosterPlayer>>? rosters,
    MatchSquadRes? squad,
    Map<String, List<TeamInviteItemRes>>? invites,
    bool returnToScoring = false,
    RxInt? tick,
  }) {
    profile = _FakeGetTeamProfile(rosters ?? {});
    save = _FakeSaveSquad();
    matchSquad = FakeGetMatchSquad()..squad = squad;
    savePlayingXi = FakeSavePlayingXi();
    teamInvites = FakeGetTeamInvites(invites ?? {});
    cancelInvite = FakeCancelTeamInvite();
    inviteTeamPlayer = _FakeInviteTeamPlayer();
    errors = [];
    opened = [];
    closed = 0;
    return SquadController(
      match: _match(),
      returnToScoring: returnToScoring,
      getTeamProfileUseCase: profile,
      saveSquadUseCase: save,
      getMatchSquadUseCase: matchSquad,
      savePlayingXiUseCase: savePlayingXi,
      getTeamInvitesUseCase: teamInvites,
      cancelTeamInviteUseCase: cancelInvite,
      lookupUserByEmailUseCase: _FakeLookup(),
      inviteTeamPlayerUseCase: inviteTeamPlayer,
      inviteResponseTick: tick,
      showError: errors.add,
      openScoring: opened.add,
      close: () => closed++,
    );
  }

  SquadSidePlayerRes sp(String id, String name) =>
      SquadSidePlayerRes(playerId: id, name: name, role: 'batsman');

  SquadSideRes side(
    String teamId, {
    List<SquadSidePlayerRes> players = const [],
    List<String>? xi,
    String? captainId,
    String? savedAt,
  }) => SquadSideRes(
    teamId: teamId,
    players: players,
    playingXI: xi,
    captainId: captainId,
    savedAt: savedAt,
  );

  MatchSquadRes squadOf(
    SquadSideRes a, {
    SquadSideRes? b,
    bool inningsStarted = false,
  }) => MatchSquadRes(
    matchId: 'm1',
    inningsStarted: inningsStarted,
    teamA: a,
    teamB: b ?? side('tb'),
  );

  TeamInviteItemRes invite(
    String id,
    String status, {
    String playerId = 'pi',
    String name = 'Invitee',
    String? respondedAt,
  }) => TeamInviteItemRes(
    inviteId: id,
    status: status,
    respondedAt: respondedAt,
    player: InvitedPlayerRes(playerId: playerId, playerName: name),
    invitee: InviteeUserRes(userId: 'u-$id', fullName: name),
  );

  setUp(() => Get.testMode = true);

  test(
    'seeds each side from its team roster, leaving an unsupported role unset',
    () async {
      final controller = build(
        rosters: {
          'ta': [
            TeamRosterPlayer(
              playerId: 'p1',
              playerName: 'Rohit',
              role: 'bowler',
            ),
            TeamRosterPlayer(
              playerId: 'p2',
              playerName: 'Pant',
              role: 'wicketkeeper',
            ),
          ],
        },
      );

      await controller.loadRosters();

      expect(profile.asked, ['ta', 'tb']);
      final rows = controller.teamA.value.rows;
      expect(rows.map((r) => r.name), ['Rohit', 'Pant']);
      expect(rows.map((r) => r.role), ['bowler', null]);
      expect(rows.first.playerId, 'p1');
      expect(controller.teamB.value.rows, isEmpty);
    },
  );

  test('switching side keeps both drafts', () async {
    final controller = build();
    controller.addPlayer('Rohit');
    await controller.selectSide('teamB');
    controller.addPlayer('Dhoni');

    expect(controller.teamA.value.rows.single.name, 'Rohit');
    expect(controller.teamB.value.rows.single.name, 'Dhoni');
    expect(controller.side.value, 'teamB');
  });

  test(
    'switching away from an edited side saves it first; an untouched side is not saved',
    () async {
      final controller = build();

      await controller.selectSide('teamB');
      expect(save.calls, isEmpty);

      await controller.selectSide('teamA');
      controller.addPlayer('Rohit');
      await controller.selectSide('teamB');

      expect(save.calls.single.req.side, 'teamA');
      expect(save.calls.single.matchId, 'm1');
    },
  );

  test('a failed save on switch keeps the draft and still switches', () async {
    final controller = build();
    controller.addPlayer('Rohit');
    save.fail = true;

    await controller.selectSide('teamB');

    expect(controller.side.value, 'teamB');
    expect(controller.teamA.value.rows.single.name, 'Rohit');
  });

  test('saveAndContinue saves edited sides then opens scoring', () async {
    final controller = build();
    controller.addPlayer('Rohit');

    await controller.saveAndContinue();

    expect(save.calls.map((c) => c.req.side), ['teamA']);
    expect(opened.single.matchId, 'm1');
    expect(errors, isEmpty);
  });

  test(
    'a failed save shows the server message and stays on the screen',
    () async {
      final controller = build();
      controller.addPlayer('Rohit');
      save.fail = true;

      await controller.saveAndContinue();

      expect(errors, ['server said no']);
      expect(opened, isEmpty);
      expect(controller.isSaving.value, isFalse);
      expect(controller.teamA.value.rows.single.name, 'Rohit');
    },
  );

  test('skip opens scoring without calling the server', () async {
    final controller = build();
    controller.addPlayer('Rohit');

    controller.skip();

    expect(save.calls, isEmpty);
    expect(opened.single.matchId, 'm1');
  });

  test(
    'saveAndContinue persists a prefilled side the scorer never edited',
    () async {
      final controller = build(
        rosters: {
          'ta': [
            TeamRosterPlayer(
              playerId: 'p1',
              playerName: 'Rohit',
              role: 'batsman',
            ),
          ],
        },
      );
      await controller.loadRosters();

      await controller.saveAndContinue();

      expect(save.calls.map((c) => c.req.side), ['teamA']);
      expect(save.calls.single.req.players.single.playerId, 'p1');
    },
  );

  test(
    'an edit made while a save is in flight is still sent by Save & continue',
    () async {
      final controller = build();
      controller.addPlayer('Rohit');
      final gate = Completer<void>();
      save.gate = gate;

      // Switching away starts the quiet save of side A; the gate holds it in
      // flight after the request (Rohit only) has been built.
      final leaving = controller.selectSide('teamB');
      await Future<void>.delayed(Duration.zero);
      final returning = controller.selectSide('teamA');
      controller.addPlayer('Zaheer');
      gate.complete();
      await leaving;
      await returning;

      await controller.saveAndContinue();

      expect(save.calls.first.req.players.map((p) => p.name), ['Rohit']);
      final lastForA = save.calls.lastWhere((c) => c.req.side == 'teamA');
      expect(lastForA.req.players.map((p) => p.name), ['Rohit', 'Zaheer']);
    },
  );

  group('Playing XI, invitations and mid-match mode', () {
    test(
      'a saved side seeds from GET squad, with its XI and designations',
      () async {
        final controller = build(
          squad: squadOf(
            side(
              'ta',
              players: [
                sp('p1', 'Rohit'),
                sp('p2', 'Bumrah'),
                sp('p3', 'Pant'),
              ],
              xi: ['p1', 'p3'],
              captainId: 'p1',
              savedAt: '2026-09-28T10:00:00.000Z',
            ),
          ),
          rosters: {
            'tb': [
              TeamRosterPlayer(
                playerId: 'q1',
                playerName: 'Kohli',
                role: 'batsman',
              ),
            ],
          },
        );

        await controller.loadRosters();

        final a = controller.teamA.value;
        expect(a.rows.map((r) => r.name), ['Rohit', 'Bumrah', 'Pant']);
        expect(a.rows.first.playerId, 'p1');
        expect(a.xiRows.map((r) => r.name), ['Rohit', 'Pant']);
        expect(a.benchRows.map((r) => r.name), ['Bumrah']);
        expect(a.captain, 'Rohit');
        expect(controller.teamB.value.rows.map((r) => r.name), ['Kohli']);
        expect(controller.midMatch.value, isFalse);
      },
    );

    test(
      'a saved side with no XI gets the first-11 rule and is saved on Save & continue',
      () async {
        final players = [for (var i = 1; i <= 12; i++) sp('p$i', 'Player $i')];
        final controller = build(
          squad: squadOf(
            side('ta', players: players, savedAt: '2026-09-28T10:00:00.000Z'),
          ),
        );
        await controller.loadRosters();

        expect(controller.teamA.value.xiRows, hasLength(11));
        expect(controller.teamA.value.benchRows.single.name, 'Player 12');

        await controller.saveAndContinue();

        expect(save.calls.single.req.playingXI, hasLength(11));
      },
    );

    test(
      'a failed GET squad falls back to rosters and stays in pre-innings mode',
      () async {
        final controller = build(
          rosters: {
            'ta': [
              TeamRosterPlayer(
                playerId: 'p1',
                playerName: 'Rohit',
                role: 'batsman',
              ),
            ],
          },
        );

        await controller.loadRosters();

        expect(controller.teamA.value.rows.single.name, 'Rohit');
        expect(controller.midMatch.value, isFalse);
      },
    );

    test(
      'moves are saved through PUT with the XI names before the innings starts',
      () async {
        final controller = build(
          squad: squadOf(
            side(
              'ta',
              players: [sp('p1', 'Rohit'), sp('p2', 'Bumrah')],
              xi: ['p1'],
              savedAt: '2026-09-28T10:00:00.000Z',
            ),
          ),
        );
        await controller.loadRosters();

        controller.moveToXi('Bumrah');
        controller.moveToBench('Rohit');
        await controller.saveAndContinue();

        expect(save.calls.single.req.playingXI, ['Bumrah']);
        expect(savePlayingXi.calls, isEmpty);
      },
    );

    test(
      'once the innings has started, moves go through PATCH with ids and never PUT',
      () async {
        final controller = build(
          squad: squadOf(
            side(
              'ta',
              players: [sp('p1', 'Rohit'), sp('p2', 'Bumrah')],
              xi: ['p1'],
              savedAt: '2026-09-28T10:00:00.000Z',
            ),
            inningsStarted: true,
          ),
          returnToScoring: true,
        );
        await controller.loadRosters();
        expect(controller.midMatch.value, isTrue);

        controller.moveToXi('Bumrah');
        await controller.saveAndContinue();

        expect(save.calls, isEmpty);
        expect(savePlayingXi.calls.single.matchId, 'm1');
        expect(savePlayingXi.calls.single.req.side, 'teamA');
        expect(savePlayingXi.calls.single.req.playingXI, ['p1', 'p2']);
        expect(closed, 1);
        expect(opened, isEmpty);
      },
    );

    test(
      'a failed PATCH reports, keeps the side dirty and does not close',
      () async {
        final controller = build(
          squad: squadOf(
            side(
              'ta',
              players: [sp('p1', 'Rohit')],
              xi: ['p1'],
              savedAt: '2026-09-28T10:00:00.000Z',
            ),
            inningsStarted: true,
          ),
          returnToScoring: true,
        );
        await controller.loadRosters();
        controller.moveToBench('Rohit');
        savePlayingXi.fail = true;

        await controller.saveAndContinue();

        expect(errors, ['xi refused']);
        expect(closed, 0);
        savePlayingXi.fail = false;
        await controller.saveAndContinue();
        expect(savePlayingXi.calls, hasLength(2));
        expect(closed, 1);
      },
    );

    test('Skip while returning to scoring closes without saving', () async {
      final controller = build(returnToScoring: true);

      controller.skip();

      expect(closed, 1);
      expect(opened, isEmpty);
      expect(save.calls, isEmpty);
      expect(savePlayingXi.calls, isEmpty);
    });

    test(
      'an invitee who accepted after the last save is appended to the Bench without disturbing unsaved edits',
      () async {
        final saved = squadOf(
          side(
            'ta',
            players: [sp('p1', 'Rohit'), sp('p2', 'Bumrah')],
            xi: ['p1'],
            captainId: 'p1',
            savedAt: '2026-09-28T10:00:00.000Z',
          ),
        );
        final controller = build(squad: saved);
        await controller.loadRosters();
        controller.moveToXi('Bumrah');
        controller.addPlayer('Typed Name');

        final accepted = invite(
          'i1',
          'accepted',
          playerId: 'pn',
          name: 'New Guy',
          respondedAt: '2026-09-28T11:00:00.000Z',
        );
        teamInvites.byTeam['ta'] = [accepted];
        await controller.refreshFromServer();
        await controller.refreshFromServer();

        final a = controller.teamA.value;
        expect(a.rows.where((r) => r.name == 'New Guy'), hasLength(1));
        expect(a.benchRows.map((r) => r.name), contains('New Guy'));
        expect(
          a.xiRows.map((r) => r.name),
          containsAll(['Rohit', 'Bumrah', 'Typed Name']),
        );
        expect(a.captain, 'Rohit');
        expect(a.rows.firstWhere((r) => r.name == 'New Guy').playerId, 'pn');
      },
    );

    test(
      'an invitee who accepted before the last save and is absent from the squad is not re-added',
      () async {
        final controller = build(
          squad: squadOf(
            side(
              'ta',
              players: [sp('p1', 'Rohit')],
              xi: ['p1'],
              savedAt: '2026-09-28T10:00:00.000Z',
            ),
          ),
          invites: {
            'ta': [
              invite(
                'i1',
                'accepted',
                playerId: 'pn',
                name: 'Dropped',
                respondedAt: '2026-09-28T09:00:00.000Z',
              ),
            ],
          },
        );

        await controller.loadRosters();

        expect(controller.teamA.value.rows.map((r) => r.name), ['Rohit']);
      },
    );

    test('waiting and declined invitees never enter the draft', () async {
      final controller = build(
        squad: squadOf(
          side(
            'ta',
            players: [sp('p1', 'Rohit')],
            savedAt: '2026-09-28T10:00:00.000Z',
          ),
        ),
        invites: {
          'ta': [
            invite(
              'i1',
              'pending',
              playerId: 'pa',
              name: 'Waiting',
              respondedAt: null,
            ),
            invite(
              'i2',
              'declined',
              playerId: 'pb',
              name: 'Declined',
              respondedAt: '2026-09-28T11:00:00.000Z',
            ),
          ],
        },
      );

      await controller.loadRosters();

      expect(controller.teamA.value.rows.map((r) => r.name), ['Rohit']);
      expect(controller.teamAInvites, hasLength(2));
    });

    test(
      'inviteUser invites into the current side\'s team and refreshes the invites',
      () async {
        final controller = build();
        await controller.loadRosters();
        await controller.selectSide('teamB');
        inviteTeamPlayer.response = Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamInviteRes(
              inviteId: 'i1',
              status: 'pending',
              player: TeamRosterPlayer(
                playerId: 'p9',
                playerName: 'Rahul',
                role: 'unknown',
              ),
            ),
          ),
        );
        teamInvites.asked.clear();

        final error = await controller.inviteUser('u1');

        expect(error, isNull);
        expect(inviteTeamPlayer.calls.single.teamId, 'tb');
        expect(inviteTeamPlayer.calls.single.userId, 'u1');
        expect(teamInvites.asked, contains('tb'));
      },
    );

    test('inviteUser returns the server message on failure', () async {
      final controller = build();
      await controller.loadRosters();
      inviteTeamPlayer.response = Either.fallback(
        CricketFailure(message: 'Already claimed'),
      );

      expect(await controller.inviteUser('u1'), 'Already claimed');
    });

    test(
      'inviting someone already linked to that account puts them straight on the Bench',
      () async {
        final controller = build();
        await controller.loadRosters();
        inviteTeamPlayer.response = Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamInviteRes(
              inviteId: null,
              status: 'accepted',
              player: TeamRosterPlayer(
                playerId: 'p9',
                playerName: 'Rahul',
                role: 'unknown',
              ),
            ),
          ),
        );

        await controller.inviteUser('u1');

        expect(controller.teamA.value.benchRows.map((r) => r.name), ['Rahul']);
        expect(controller.teamA.value.benchRows.single.playerId, 'p9');
      },
    );

    test(
      'cancelInvite calls the server, then refreshes; a failure is reported',
      () async {
        final controller = build(
          invites: {
            'ta': [invite('i1', 'pending')],
          },
        );
        await controller.loadRosters();
        cancelInvite.onSuccess = () => teamInvites.byTeam['ta'] = [];

        await controller.cancelInvite(controller.teamAInvites.single);

        expect(cancelInvite.calls.single.teamId, 'ta');
        expect(cancelInvite.calls.single.inviteId, 'i1');
        expect(controller.teamAInvites, isEmpty);

        teamInvites.byTeam['ta'] = [invite('i2', 'pending')];
        await controller.refreshFromServer();
        cancelInvite.fail = true;
        await controller.cancelInvite(controller.teamAInvites.single);
        expect(errors, ['cancel refused']);
        expect(controller.teamAInvites, hasLength(1));
      },
    );

    test('a foreground invite-response tick refreshes the invites', () async {
      final tick = 0.obs;
      final controller = build(tick: tick);
      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      teamInvites.asked.clear();

      tick.value++;
      await Future<void>.delayed(Duration.zero);

      expect(teamInvites.asked, containsAll(['ta', 'tb']));
      controller.onClose();
    });
  });
}
