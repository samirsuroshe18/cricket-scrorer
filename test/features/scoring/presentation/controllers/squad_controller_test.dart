import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_squad.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

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
  late _FakeGetTeamProfile profile;
  late _FakeSaveSquad save;
  late List<String> errors;
  late List<CreateMatchRes> opened;

  SquadController build({Map<String, List<TeamRosterPlayer>>? rosters}) {
    profile = _FakeGetTeamProfile(rosters ?? {});
    save = _FakeSaveSquad();
    errors = [];
    opened = [];
    return SquadController(
      match: _match(),
      getTeamProfileUseCase: profile,
      saveSquadUseCase: save,
      showError: errors.add,
      openScoring: opened.add,
    );
  }

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
}
