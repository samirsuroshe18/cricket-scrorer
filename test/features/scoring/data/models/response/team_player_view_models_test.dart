import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/playing_for_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_player_view_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayingForTeamsRes', () {
    test('parses rows with optional shortName and logo', () {
      final res = PlayingForTeamsRes.fromJson({
        'teams': [
          {
            'id': 't1',
            'name': 'Mumbai Indians',
            'shortName': 'MI',
            'logoUrl': null,
            'myPlayerName': 'Mohit Zatu',
          },
          {'id': 't2', 'name': 'Riverside', 'myPlayerName': 'Mohit'},
        ],
        'page': 1,
        'limit': 20,
        'total': 2,
      });

      expect(res.teams.first.name, 'Mumbai Indians');
      expect(res.teams.first.shortName, 'MI');
      expect(res.teams.first.myPlayerName, 'Mohit Zatu');
      expect(res.teams.last.shortName, isNull);
      expect(res.teams.last.logoUrl, isNull);
    });

    test('hasMore is true only while more pages remain', () {
      PlayingForTeamsRes page(int p, int total) => PlayingForTeamsRes.fromJson({
        'teams': <Map<String, dynamic>>[],
        'page': p,
        'limit': 20,
        'total': total,
      });

      expect(page(1, 21).hasMore, isTrue);
      expect(page(2, 21).hasMore, isFalse);
      expect(page(1, 20).hasMore, isFalse);
    });
  });

  group('TeamPlayerViewRes', () {
    test('parses roster, leaders and stats', () {
      final res = TeamPlayerViewRes.fromJson({
        'teamId': 't1',
        'name': 'Mumbai Indians',
        'shortName': 'MI',
        'logoUrl': null,
        'stats': {
          'played': 3,
          'won': 2,
          'lost': 1,
          'tied': 0,
          'noResult': 0,
          'winPercentage': 66.7,
          'form': ['W', 'L', 'W'],
        },
        'captainId': 'p2',
        'viceCaptainId': null,
        'roster': [
          {
            'playerId': 'p1',
            'playerName': 'Mohit Zatu',
            'role': 'batsman',
            'jerseyNumber': 7,
            'isCaptain': false,
            'isViceCaptain': false,
          },
          {
            'playerId': 'p2',
            'playerName': 'Mate',
            'role': 'unknown',
            'jerseyNumber': null,
            'isCaptain': true,
            'isViceCaptain': false,
          },
        ],
      });

      expect(res.name, 'Mumbai Indians');
      expect(res.stats?.won, 2);
      expect(res.captainId, 'p2');
      expect(res.viceCaptainId, isNull);
      expect(res.roster.first.jerseyNumber, 7);
      expect(res.roster.last.isCaptain, isTrue);
    });
  });

  test('MatchHistoryRes parses a player-view item without scorer fields', () {
    final res = MatchHistoryRes.fromJson({
      'matches': [
        {
          'matchId': 'm1',
          'teamA': {'id': 'a', 'name': 'A', 'logoUrl': null},
          'teamB': {'id': 'b', 'name': 'B', 'logoUrl': null},
          'joinCode': 'ABC123',
          'totalOvers': 5,
          'status': 'live',
          'result': null,
          'tossWinner': null,
          'tossDecision': null,
          'createdAt': '2026-09-27T10:00:00.000Z',
          'currentInnings': null,
        },
      ],
      'page': 1,
      'limit': 20,
      'total': 1,
    });

    final item = res.matches.single;
    expect(item.joinCode, 'ABC123');
    expect(item.createdBy, isNull);
    expect(item.assignedScorer, isNull);
    expect(item.syncStatus, 'synced');
  });
}
