import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_playing_xi_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('endpoints', () {
    const endpoint = MatchEndpoint();

    test('start at /v1, never /api', () {
      expect(endpoint.matchSquad('m1'), '/v1/match/m1/squad');
      expect(
        endpoint.playingXi('m1', 'teamB'),
        '/v1/match/m1/squad/teamB/playing-xi',
      );
      expect(endpoint.teamInvite('t1', 'i1'), '/v1/team/t1/invites/i1');
      for (final path in [
        endpoint.matchSquad('m1'),
        endpoint.playingXi('m1', 'teamA'),
        endpoint.teamInvite('t1', 'i1'),
      ]) {
        expect(path.startsWith('/api'), isFalse);
      }
    });
  });

  group('SaveSquadReq.playingXI', () {
    test('is sent when set, including an empty XI, and omitted when null', () {
      final withXi = SaveSquadReq(
        side: 'teamA',
        players: [SquadPlayerReq(name: 'Rohit')],
        playingXI: ['Rohit'],
      );
      final empty = SaveSquadReq(
        side: 'teamA',
        players: const [],
        playingXI: const [],
      );
      final unset = SaveSquadReq(side: 'teamA', players: const []);

      expect(withXi.toJson()['playingXI'], ['Rohit']);
      expect(empty.toJson()['playingXI'], <String>[]);
      expect(unset.toJson().containsKey('playingXI'), isFalse);
    });
  });

  test('SquadRes reads playingXI, null when the server sends none', () {
    final set = SquadRes.fromJson({
      'side': 'teamA',
      'players': <Object>[],
      'playingXI': ['p1'],
    });
    final unset = SquadRes.fromJson({
      'side': 'teamA',
      'players': <Object>[],
      'playingXI': null,
    });

    expect(set.playingXI, ['p1']);
    expect(unset.playingXI, isNull);
  });

  test('SavePlayingXiReq keeps the side on the path, not in the body', () {
    final req = SavePlayingXiReq(side: 'teamA', playingXI: ['p1', 'p2']);

    expect(req.toJson(), {
      'playingXI': ['p1', 'p2'],
    });
  });

  group('MatchSquadRes', () {
    final payload = {
      'matchId': 'm1',
      'inningsStarted': true,
      'teamA': {
        'teamId': 'ta',
        'players': [
          {
            'playerId': 'p1',
            'name': 'Rohit',
            'role': 'batsman',
            'jerseyNumber': 45,
          },
          {
            'playerId': 'p2',
            'name': 'Bumrah',
            'role': 'bowler',
            'jerseyNumber': null,
          },
        ],
        'captainId': 'p1',
        'viceCaptainId': null,
        'keeperId': null,
        'playingXI': <String>[],
        'savedAt': '2026-09-28T10:00:00.000Z',
      },
      'teamB': {
        'teamId': 'tb',
        'players': <Object>[],
        'captainId': null,
        'viceCaptainId': null,
        'keeperId': null,
        'playingXI': null,
        'savedAt': null,
      },
    };

    test(
      'parses both sides and keeps an empty XI distinct from an unset one',
      () {
        final res = MatchSquadRes.fromJson(payload);

        expect(res.matchId, 'm1');
        expect(res.inningsStarted, isTrue);
        expect(res.teamA.teamId, 'ta');
        expect(res.teamA.players.first.jerseyNumber, 45);
        expect(res.teamA.players.last.jerseyNumber, isNull);
        expect(res.teamA.captainId, 'p1');
        expect(res.teamA.playingXI, isEmpty);
        expect(res.teamA.playingXI, isNotNull);
        expect(res.teamA.savedAt, '2026-09-28T10:00:00.000Z');
        expect(res.teamB.players, isEmpty);
        expect(res.teamB.playingXI, isNull);
        expect(res.teamB.savedAt, isNull);
      },
    );

    test('a PATCH response with an extra side key parses as a side', () {
      final side = SquadSideRes.fromJson({
        ...(payload['teamA']! as Map<String, dynamic>),
        'side': 'teamA',
      });

      expect(side.teamId, 'ta');
    });
  });

  test('TeamInvitesRes parses rows for every status', () {
    final res = TeamInvitesRes.fromJson({
      'invites': [
        {
          'inviteId': 'i1',
          'status': 'pending',
          'respondedAt': null,
          'player': {'playerId': 'p1', 'playerName': 'Rahul Sharma'},
          'invitee': {
            'userId': 'u1',
            'fullName': 'Rahul Sharma',
            'photoUrl': null,
          },
        },
        {
          'inviteId': 'i2',
          'status': 'accepted',
          'respondedAt': '2026-09-28T10:00:00.000Z',
          'player': {'playerId': 'p2', 'playerName': 'Dev'},
          'invitee': {
            'userId': 'u2',
            'fullName': 'Dev',
            'photoUrl': 'https://x/y.png',
          },
        },
      ],
    });

    expect(res.invites, hasLength(2));
    expect(res.invites.first.status, 'pending');
    expect(res.invites.first.respondedAt, isNull);
    expect(res.invites.first.invitee.photoUrl, isNull);
    expect(res.invites.last.respondedAt, '2026-09-28T10:00:00.000Z');
    expect(res.invites.last.player.playerName, 'Dev');
    expect(TeamInvitesRes.fromJson({'invites': <Object>[]}).invites, isEmpty);
  });
}
