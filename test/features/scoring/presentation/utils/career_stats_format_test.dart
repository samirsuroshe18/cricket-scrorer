import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/utils/career_stats_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatAverage', () {
    // The exact worked example from the backend's own tests: 50 runs, 1
    // dismissal. The backend computes 50/1 = 50 server-side; this only
    // checks display formatting doesn't corrupt that value on the way to
    // the screen.
    test('formats a computed average to 2 decimal places', () {
      expect(formatAverage(50), '50.00');
    });

    test('renders null (never dismissed) as "-", not "0.00"', () {
      expect(formatAverage(null), '-');
    });

    test('rounds a non-terminating average for display', () {
      expect(formatAverage(33.333333), '33.33');
    });
  });

  group('formatHighScore', () {
    test('appends * for a not-out high score — cricket convention', () {
      final highScore = HighScore(runs: 30, isNotOut: true, matchId: 'm1');
      expect(formatHighScore(highScore), '30*');
    });

    test('has no * for a dismissed high score', () {
      final highScore = HighScore(runs: 30, isNotOut: false, matchId: 'm1');
      expect(formatHighScore(highScore), '30');
    });

    test('renders null (no innings batted yet) as "-"', () {
      expect(formatHighScore(null), '-');
    });
  });

  group('formatBestBowling', () {
    test('formats as wickets/runs', () {
      final bestBowling = BestBowling(wickets: 1, runs: 0, matchId: 'm2');
      expect(formatBestBowling(bestBowling), '1/0');
    });

    test('renders null (no innings bowled yet) as "-"', () {
      expect(formatBestBowling(null), '-');
    });
  });

  group('formatOversFromLegalDeliveries', () {
    test('12 legal deliveries is 2 complete overs — "2.0"', () {
      expect(formatOversFromLegalDeliveries(12), '2.0');
    });

    test('26 legal deliveries is 4 overs and 2 balls — "4.2"', () {
      expect(formatOversFromLegalDeliveries(26), '4.2');
    });

    test('0 legal deliveries is "0.0"', () {
      expect(formatOversFromLegalDeliveries(0), '0.0');
    });
  });
}
