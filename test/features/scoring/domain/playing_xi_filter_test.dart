import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';
import 'package:cricket_scorer/features/scoring/domain/playing_xi_filter.dart';
import 'package:flutter_test/flutter_test.dart';

SquadSidePlayerRes _sp(String id, String name) =>
    SquadSidePlayerRes(playerId: id, name: name, role: 'batsman');

MatchSquadRes _squad({List<String>? xiA, List<String>? xiB}) => MatchSquadRes(
  matchId: 'm1',
  teamA: SquadSideRes(
    teamId: 'ta',
    players: [_sp('a1', 'Rohit'), _sp('a2', 'Pant'), _sp('a3', 'Bench Bat')],
    playingXI: xiA,
  ),
  teamB: SquadSideRes(
    teamId: 'tb',
    players: [_sp('b1', 'Bumrah'), _sp('b2', 'Bench Bowl')],
    playingXI: xiB,
  ),
);

TeamRosterPlayer _r(String id, String name) =>
    TeamRosterPlayer(playerId: id, playerName: name, role: 'batsman');

void main() {
  final roster = [_r('a1', 'Rohit'), _r('a2', 'Pant'), _r('a3', 'Bench Bat')];

  test('a side with no XI set is not locked and keeps its whole roster', () {
    final filter = PlayingXiFilter(_squad());

    expect(filter.isLocked('ta'), isFalse);
    expect(filter.roster('ta', roster), roster);
  });

  test('with no squad at all nothing is locked', () {
    const filter = PlayingXiFilter(null);

    expect(filter.isLocked('ta'), isFalse);
    expect(filter.roster('ta', roster), roster);
  });

  test('a set XI locks that side and narrows its roster to the XI', () {
    final filter = PlayingXiFilter(_squad(xiA: ['a1', 'a2']));

    expect(filter.isLocked('ta'), isTrue);
    expect(filter.isLocked('tb'), isFalse);
    expect(filter.roster('ta', roster).map((p) => p.playerName), [
      'Rohit',
      'Pant',
    ]);
  });

  test('a set-but-empty XI is locked and offers nobody', () {
    final filter = PlayingXiFilter(_squad(xiA: []));

    expect(filter.isLocked('ta'), isTrue);
    expect(filter.roster('ta', roster), isEmpty);
  });

  test('an unknown team id is never locked', () {
    final filter = PlayingXiFilter(_squad(xiA: ['a1']));

    expect(filter.isLocked('other'), isFalse);
    expect(filter.roster('other', roster), roster);
  });

  test('bowlers are narrowed by id, and a name-only bowler by XI name', () {
    final filter = PlayingXiFilter(_squad(xiB: ['b1']));
    final bowlers = [
      const BowlerRef(id: 'b1', name: 'Bumrah', legalDeliveries: 6),
      const BowlerRef(id: 'b2', name: 'Bench Bowl'),
      const BowlerRef(id: null, name: ' bumrah '),
      const BowlerRef(id: null, name: 'Stranger'),
    ];

    expect(filter.bowlers('tb', bowlers).map((b) => b.name), [
      'Bumrah',
      ' bumrah ',
    ]);
    expect(filter.bowlers('ta', bowlers), bowlers);
  });
}
