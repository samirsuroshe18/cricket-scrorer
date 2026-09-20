import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses battingTeam, target and recentBalls', () {
    final innings = CurrentInningsSummary.fromJson({
      'inningsNumber': 2,
      'battingTeam': 'teamB',
      'totalRuns': 142,
      'wickets': 4,
      'overs': '16.2',
      'target': 181,
      'recentBalls': [
        {'totalRuns': 1, 'extraType': null, 'isWicket': false},
        {'totalRuns': 1, 'extraType': 'wide', 'isWicket': false},
        {'totalRuns': 0, 'extraType': null, 'isWicket': true},
      ],
    });

    expect(innings.battingTeam, 'teamB');
    expect(innings.target, 181);
    expect(innings.recentBalls, hasLength(3));
    expect(innings.recentBalls[1].extraType, 'wide');
    expect(innings.recentBalls[2].isWicket, isTrue);
  });

  test('still parses a response from a server that omits the new fields', () {
    final innings = CurrentInningsSummary.fromJson({
      'inningsNumber': 1,
      'totalRuns': 5,
      'wickets': 0,
      'overs': '0.2',
    });

    expect(innings.battingTeam, isNull);
    expect(innings.target, isNull);
    expect(innings.recentBalls, isEmpty);
  });

  group('MatchHistoryRes.counts', () {
    Map<String, dynamic> json({Map<String, dynamic>? counts}) => {
      'matches': <Map<String, dynamic>>[],
      'page': 1,
      'limit': 20,
      'total': 0,
      'counts': ?counts,
    };

    test("parses the server's per-status counts", () {
      final res = MatchHistoryRes.fromJson(
        json(
          counts: {
            'upcoming': 1,
            'live': 2,
            'innings_break': 0,
            'completed': 5,
            'abandoned': 3,
          },
        ),
      );

      expect(res.counts['live'], 2);
      expect(res.counts['completed'], 5);
      expect(res.counts, hasLength(5));
    });

    // A server that predates the field must not fail the whole history parse
    // — the chips just show no number.
    test('is empty, not an error, when the server omits it', () {
      expect(MatchHistoryRes.fromJson(json()).counts, isEmpty);
    });
  });
}
