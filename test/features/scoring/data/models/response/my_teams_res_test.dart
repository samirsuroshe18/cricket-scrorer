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
      'page': 1,
      'limit': 20,
      'total': 1,
    });

    expect(res.teams.single.id, '665f1a2b3c4d5e6f7a8b9c01');
    expect(res.teams.single.shortName, 'MI');
    expect(res.page, 1);
    expect(res.limit, 20);
    expect(res.total, 1);
  });

  test('fromJson accepts a null shortName', () {
    final res = MyTeamsRes.fromJson({
      'teams': [
        {'id': 'team-1', 'name': 'Chennai Super Kings', 'shortName': null},
      ],
      'page': 1,
      'limit': 20,
      'total': 1,
    });

    expect(res.teams.single.shortName, isNull);
  });

  group('hasMore', () {
    test('is true when another page exists', () {
      final res = MyTeamsRes(teams: [], page: 1, limit: 20, total: 21);

      expect(res.hasMore, isTrue);
    });

    test('is false when the current page is an exact multiple of the total', () {
      final res = MyTeamsRes(teams: [], page: 1, limit: 20, total: 20);

      expect(res.hasMore, isFalse);
    });

    test('is false past the last page', () {
      final res = MyTeamsRes(teams: [], page: 2, limit: 20, total: 21);

      expect(res.hasMore, isFalse);
    });
  });
}
