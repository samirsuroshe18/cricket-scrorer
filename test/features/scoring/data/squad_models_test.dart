import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saveSquad puts to /v1/match/:matchId/squad/:side, never /api/...', () {
    const endpoint = MatchEndpoint();

    expect(endpoint.saveSquad('abc', 'teamA'), '/v1/match/abc/squad/teamA');
    expect(endpoint.saveSquad('abc', 'teamA').startsWith('/api'), isFalse);
  });

  test('SaveSquadReq omits the side and any null playerId from the body', () {
    final req = SaveSquadReq(
      side: 'teamA',
      players: [
        SquadPlayerReq(name: 'Rohit', role: 'batsman'),
        SquadPlayerReq(playerId: 'p2', name: 'Bumrah', role: 'bowler'),
        SquadPlayerReq(name: 'Pant'),
      ],
      captain: 'Rohit',
      keeper: null,
    );

    expect(req.toJson(), {
      'players': [
        {'name': 'Rohit', 'role': 'batsman'},
        {'playerId': 'p2', 'name': 'Bumrah', 'role': 'bowler'},
        {'name': 'Pant'},
      ],
      'captain': 'Rohit',
    });
  });

  test('SquadRes reads the server payload', () {
    final res = SquadRes.fromJson({
      'side': 'teamA',
      'players': [
        {'playerId': 'p1', 'name': 'Rohit', 'role': 'batsman'},
      ],
      'captainId': 'p1',
      'viceCaptainId': null,
      'keeperId': null,
    });

    expect(res.side, 'teamA');
    expect(res.players.single.playerId, 'p1');
    expect(res.captainId, 'p1');
    expect(res.viceCaptainId, isNull);
  });

  test('CreateMatchRes still parses when squads is absent or present', () {
    final base = {
      'matchId': 'm1',
      'teamA': {'id': 'a', 'name': 'A'},
      'teamB': {'id': 'b', 'name': 'B'},
      'totalOvers': 5,
      'status': 'upcoming',
      'syncStatus': 'local',
      'createdAt': '2026-09-26T00:00:00.000Z',
    };

    expect(CreateMatchRes.fromJson(base).matchId, 'm1');
    expect(
      CreateMatchRes.fromJson({
        ...base,
        'squads': {
          'teamA': {'players': <dynamic>[]},
          'teamB': {'players': <dynamic>[]},
        },
      }).matchId,
      'm1',
    );
  });
}
