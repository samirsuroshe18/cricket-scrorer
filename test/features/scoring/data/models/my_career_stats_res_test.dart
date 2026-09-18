import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the four counters', () {
    final res = MyCareerStatsRes.fromJson({
      'linkedPlayerCount': 2,
      'matchesPlayed': 7,
      'runs': 250,
      'wickets': 7,
    });

    expect(res.linkedPlayerCount, 2);
    expect(res.matchesPlayed, 7);
    expect(res.runs, 250);
    expect(res.wickets, 7);
  });
}
