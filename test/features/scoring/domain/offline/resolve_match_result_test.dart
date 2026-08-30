import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_match_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Same defaults as the backend's own `tests/resolveMatchResult.test.js` —
/// this file's cases mirror that one's, one for one.
MatchResultInfo _base({
  String? completionReason = 'overs_complete',
  String battingTeam1 = 'teamA',
  String battingTeam2 = 'teamB',
  int runs1 = 150,
  int runs2 = 140,
  int wickets2 = 6,
}) {
  return resolveMatchResultPreview(
    completionReason: completionReason,
    battingTeam1: battingTeam1,
    battingTeam2: battingTeam2,
    runs1: runs1,
    runs2: runs2,
    wickets2: wickets2,
  );
}

void main() {
  group('resolveMatchResultPreview', () {
    test('a target chase win is a wickets margin, not runs', () {
      final result = _base(
        completionReason: 'target_achieved',
        runs2: 151,
        wickets2: 6,
      );
      expect(result.winner, 'teamB');
      expect(result.marginType, 'wickets');
      expect(result.margin, 4);
    });

    test('losing zero wickets on the way to the target is a 10-wicket win', () {
      final result = _base(
        completionReason: 'target_achieved',
        runs2: 151,
        wickets2: 0,
      );
      expect(result.winner, 'teamB');
      expect(result.marginType, 'wickets');
      expect(result.margin, 10);
    });

    test(
      'all out short of the target is a runs win for the side batting first',
      () {
        final result = _base(
          completionReason: 'all_out',
          runs1: 150,
          runs2: 120,
        );
        expect(result.winner, 'teamA');
        expect(result.marginType, 'runs');
        expect(result.margin, 30);
      },
    );

    test(
      'overs run out short of the target is a runs win for the side batting '
      'first',
      () {
        final result = _base(
          completionReason: 'overs_complete',
          runs1: 150,
          runs2: 149,
        );
        expect(result.winner, 'teamA');
        expect(result.marginType, 'runs');
        expect(result.margin, 1);
      },
    );

    test('equal totals is a tie, not a runs win for either side', () {
      final result = _base(
        completionReason: 'all_out',
        runs1: 150,
        runs2: 150,
      );
      expect(result.winner, 'tie');
      expect(result.isTie, isTrue);
      expect(result.marginType, isNull);
      expect(result.margin, isNull);
    });

    test(
      'one run short of a tie is still a runs win, not rounded to a tie',
      () {
        final result = _base(
          completionReason: 'all_out',
          runs1: 150,
          runs2: 149,
        );
        expect(result.winner, 'teamA');
        expect(result.marginType, 'runs');
        expect(result.margin, 1);
      },
    );

    test(
      'target_achieved always names the side batting second, never the first',
      () {
        final result = _base(
          completionReason: 'target_achieved',
          runs2: 200,
          wickets2: 3,
        );
        expect(result.winner, 'teamB');
      },
    );
  });
}
