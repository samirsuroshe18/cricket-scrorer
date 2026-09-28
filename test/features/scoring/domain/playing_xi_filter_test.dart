import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';
import 'package:cricket_scorer/features/scoring/domain/playing_xi_filter.dart';
import 'package:flutter_test/flutter_test.dart';

SquadSidePlayerRes _sp(String id, String name, {int? jersey}) =>
    SquadSidePlayerRes(
      playerId: id,
      name: name,
      role: 'batsman',
      jerseyNumber: jersey,
    );

MatchSquadRes _squad({List<String>? xiA, List<String>? xiB}) => MatchSquadRes(
  matchId: 'm1',
  teamA: SquadSideRes(
    teamId: 'ta',
    players: [
      _sp('a1', 'Rohit', jersey: 45),
      _sp('a2', 'Pant'),
      _sp('a3', 'Bench Bat'),
    ],
    playingXI: xiA,
  ),
  teamB: SquadSideRes(
    teamId: 'tb',
    players: [_sp('b1', 'Bumrah'), _sp('b2', 'Bench Bowl')],
    playingXI: xiB,
  ),
);

void main() {
  test('a side with no XI set is not locked and has no XI to offer', () {
    final filter = PlayingXiFilter(_squad());

    expect(filter.isLocked('ta'), isFalse);
    expect(filter.xiRoster('ta'), isNull);
    expect(filter.xiBowlers('ta', const []), isNull);
  });

  test('with no squad at all nothing is locked', () {
    const filter = PlayingXiFilter(null);

    expect(filter.isLocked('ta'), isFalse);
    expect(filter.xiRoster('ta'), isNull);
  });

  test('a set XI locks that side and is served from the squad itself', () {
    final filter = PlayingXiFilter(_squad(xiA: ['a1', 'a2']));

    expect(filter.isLocked('ta'), isTrue);
    expect(filter.isLocked('tb'), isFalse);
    final roster = filter.xiRoster('ta')!;
    expect(roster.map((p) => p.playerName), ['Rohit', 'Pant']);
    expect(roster.first.playerId, 'a1');
    expect(roster.first.jerseyNumber, 45);
  });

  test('a set-but-empty XI is locked and offers nobody', () {
    final filter = PlayingXiFilter(_squad(xiA: []));

    expect(filter.isLocked('ta'), isTrue);
    expect(filter.xiRoster('ta'), isEmpty);
  });

  test('an unknown team id is never locked', () {
    final filter = PlayingXiFilter(_squad(xiA: ['a1']));

    expect(filter.isLocked('other'), isFalse);
    expect(filter.xiRoster('other'), isNull);
  });

  test('a locked side\'s bowlers are its whole XI, even if none were seen', () {
    final filter = PlayingXiFilter(_squad(xiB: ['b1', 'b2']));

    final bowlers = filter.xiBowlers('tb', const [])!;

    expect(bowlers.map((b) => b.name), ['Bumrah', 'Bench Bowl']);
    expect(bowlers.first.id, 'b1');
    expect(bowlers.first.legalDeliveries, isNull);
  });

  test('overs bowled carry over from a bowler already seen, matched by id', () {
    final filter = PlayingXiFilter(_squad(xiB: ['b1', 'b2']));
    final seen = [
      const BowlerRef(id: 'b1', name: 'Bumrah', legalDeliveries: 6),
      const BowlerRef(id: 'zz', name: 'Someone Else', legalDeliveries: 12),
    ];

    final bowlers = filter.xiBowlers('tb', seen)!;

    expect(bowlers.map((b) => b.name), ['Bumrah', 'Bench Bowl']);
    expect(bowlers.first.legalDeliveries, 6);
    expect(bowlers.last.legalDeliveries, isNull);
  });
}
