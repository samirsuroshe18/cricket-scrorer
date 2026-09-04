import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses the caller\'s own teams', () {
    final res = MyTeamsRes.fromJson({
      'teams': [
        {
          'id': '665f1a2b3c4d5e6f7a8b9c01',
          'name': 'Mumbai Indians',
          'shortName': 'MI',
        },
      ],
    });

    expect(res.teams.single.id, '665f1a2b3c4d5e6f7a8b9c01');
    expect(res.teams.single.shortName, 'MI');
  });

  test('fromJson accepts a null shortName', () {
    final res = MyTeamsRes.fromJson({
      'teams': [
        {'id': 'team-1', 'name': 'Chennai Super Kings', 'shortName': null},
      ],
    });

    expect(res.teams.single.shortName, isNull);
  });
}
