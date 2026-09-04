import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses a team profile with a populated roster', () {
    final res = TeamProfileRes.fromJson({
      'teamId': '665f1a2b3c4d5e6f7a8b9c01',
      'name': 'Mumbai Indians',
      'shortName': 'MI',
      'roster': [
        {
          'playerId': '665f3b1c2d3e4f5a6b7c8d90',
          'playerName': 'Rahul',
          'jerseyNumber': 7,
          'role': 'batsman',
        },
      ],
    });

    expect(res.teamId, '665f1a2b3c4d5e6f7a8b9c01');
    expect(res.shortName, 'MI');
    expect(res.roster.single.playerName, 'Rahul');
    expect(res.roster.single.jerseyNumber, 7);
    expect(res.roster.single.role, 'batsman');
  });

  test('fromJson accepts a null shortName and an empty roster', () {
    final res = TeamProfileRes.fromJson({
      'teamId': '665f1a2b3c4d5e6f7a8b9c01',
      'name': 'Mumbai Indians',
      'shortName': null,
      'roster': <dynamic>[],
    });

    expect(res.shortName, isNull);
    expect(res.roster, isEmpty);
  });
}
