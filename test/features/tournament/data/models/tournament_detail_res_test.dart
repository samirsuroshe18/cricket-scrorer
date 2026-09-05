import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TournamentDetailRes.fromJson parses organization and teams',
    () {
      final json = {
        'id': 'tournament-1',
        'name': 'Summer T20',
        'format': 'knockout',
        'status': 'upcoming',
        'organization': {'id': 'org-1', 'name': 'Riverside Cricket Club'},
        'teams': [
          {
            'id': 'team-1',
            'name': 'Riverside U19',
            'shortName': 'RU19',
            'joinedAt': '2026-09-05T10:05:00.000Z',
          },
        ],
        'createdAt': '2026-09-05T10:00:00.000Z',
      };

      final res = TournamentDetailRes.fromJson(json);

      expect(res.id, 'tournament-1');
      expect(res.name, 'Summer T20');
      expect(res.format, 'knockout');
      expect(res.status, 'upcoming');
      expect(res.organization.name, 'Riverside Cricket Club');
      expect(res.teams.single.shortName, 'RU19');
      expect(res.teams.single.joinedAt, DateTime.parse('2026-09-05T10:05:00.000Z'));
    },
  );

  test('TournamentDetailRes.fromJson handles a team with no shortName', () {
    final json = {
      'id': 'tournament-1',
      'name': 'Summer T20',
      'format': 'league',
      'status': 'ongoing',
      'organization': {'id': 'org-1', 'name': 'Riverside Cricket Club'},
      'teams': [
        {
          'id': 'team-1',
          'name': 'Riverside U19',
          'shortName': null,
          'joinedAt': '2026-09-05T10:05:00.000Z',
        },
      ],
      'createdAt': '2026-09-05T10:00:00.000Z',
    };

    final res = TournamentDetailRes.fromJson(json);

    expect(res.teams.single.shortName, isNull);
  });

  test('TournamentDetailRes.fromJson handles an empty teams list', () {
    final json = {
      'id': 'tournament-1',
      'name': 'Summer T20',
      'format': 'round_robin',
      'status': 'upcoming',
      'organization': {'id': 'org-1', 'name': 'Riverside Cricket Club'},
      'teams': <Map<String, dynamic>>[],
      'createdAt': '2026-09-05T10:00:00.000Z',
    };

    final res = TournamentDetailRes.fromJson(json);

    expect(res.teams, isEmpty);
  });
}
