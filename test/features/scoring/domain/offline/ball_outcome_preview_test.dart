import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/ball_outcome_preview.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:flutter_test/flutter_test.dart';

PreEventState _pre({
  int totalRuns = 24,
  int wickets = 2,
  int oversCompleted = 1,
  int overLegalDeliveries = 5,
  String strikerName = 'Rohit Sharma',
  String nonStrikerName = 'Ishan Kishan',
  String? currentBowlerName = 'Bumrah',
  int strikerRuns = 10,
  int strikerBalls = 8,
}) {
  return PreEventState(
    totalRuns: totalRuns,
    wickets: wickets,
    legalBalls: oversCompleted * 6 + overLegalDeliveries,
    totalBalls: oversCompleted * 6 + overLegalDeliveries,
    oversCompleted: oversCompleted,
    striker: BatsmanFigures(name: strikerName, runs: strikerRuns, balls: strikerBalls),
    nonStriker: BatsmanFigures(name: nonStrikerName, runs: 3, balls: 4),
    currentBowlerName: currentBowlerName,
    overTotalRuns: 7,
    overLegalDeliveries: overLegalDeliveries,
    extrasSnapshot: const ExtrasSnapshot(wides: 2, noBalls: 1, byes: 3, legByes: 0),
    overExtrasSnapshot: const ExtrasSnapshot(wides: 1, noBalls: 0, byes: 3, legByes: 0),
  );
}

ScoreBallReq _req({
  int runs = 0,
  String? extraType,
  String? runsFrom,
  String? wicketType,
  String? dismissedBatsman,
  String? incomingBatsmanName,
}) {
  return ScoreBallReq(
    runs: runs,
    extraType: extraType,
    runsFrom: runsFrom,
    wicketType: wicketType,
    dismissedBatsman: dismissedBatsman,
    incomingBatsmanName: incomingBatsmanName,
    idempotencyKey: 'test-key',
  );
}

void main() {
  group('previewBall', () {
    test('a plain single rotates strike and updates totals', () {
      final pre = _pre(overLegalDeliveries: 2);
      final result = previewBall(
        pre: pre,
        req: _req(runs: 1),
        totalOvers: 20,
        inningsNumber: 1,
      );

      expect(result.strike.strikerName, 'Ishan Kishan');
      expect(result.strike.nonStrikerName, 'Rohit Sharma');
      expect(result.strike.rotated, isTrue);
      expect(result.inningsTotals.totalRuns, 25);
      expect(result.overComplete, isFalse);
      expect(result.wicket, isNull);
    });

    test('a boundary does not rotate', () {
      final pre = _pre(overLegalDeliveries: 2);
      final result = previewBall(
        pre: pre,
        req: _req(runs: 4),
        totalOvers: 20,
        inningsNumber: 1,
      );

      expect(result.strike.strikerName, 'Rohit Sharma');
      expect(result.strike.rotated, isFalse);
      expect(result.inningsTotals.totalRuns, 28);
    });

    test('a wide is illegal, adds only extras, and does not advance the over', () {
      final pre = _pre(overLegalDeliveries: 3);
      final result = previewBall(
        pre: pre,
        req: _req(runs: 0, extraType: ExtraType.wide),
        totalOvers: 20,
        inningsNumber: 1,
      );

      expect(result.inningsTotals.totalRuns, 25); // +1 penalty
      expect(result.inningsTotals.extras.wides, 3); // 2 + 1
      expect(result.overComplete, isFalse);
      expect(result.nextPreEventState.overLegalDeliveries, 3); // unchanged
    });

    test('a wicket replaces the striker and carries the dismissal', () {
      final pre = _pre(overLegalDeliveries: 2);
      final result = previewBall(
        pre: pre,
        req: _req(
          runs: 0,
          wicketType: 'bowled',
          incomingBatsmanName: 'Suryakumar Yadav',
        ),
        totalOvers: 20,
        inningsNumber: 1,
      );

      expect(result.strike.strikerName, 'Suryakumar Yadav');
      expect(result.strike.strikerRuns, 0);
      expect(result.strike.strikerBalls, 0);
      expect(result.wicket?.type, 'bowled');
      expect(result.wicket?.dismissedPlayerName, 'Rohit Sharma');
      expect(result.wicket?.incomingBatsmanName, 'Suryakumar Yadav');
      expect(result.inningsTotals.wickets, 3);
    });

    test('a run-out non-striker replaces without disturbing the striker', () {
      final pre = _pre(overLegalDeliveries: 2);
      final result = previewBall(
        pre: pre,
        req: _req(
          runs: 1,
          wicketType: 'run_out',
          dismissedBatsman: 'non_striker',
          incomingBatsmanName: 'Suryakumar Yadav',
        ),
        totalOvers: 20,
        inningsNumber: 1,
      );

      // A single rotates the pair before the substitution lands — so the
      // dismissed non-striker (Ishan, before the ball) ends up at the
      // striker's end after rotation, and that is where the replacement
      // must land, matching resolveStrikePreview's own "rotate then
      // substitute" test.
      expect(result.strike.strikerName, 'Suryakumar Yadav');
      expect(result.strike.strikerRuns, 0);
      expect(result.strike.nonStrikerName, 'Rohit Sharma');
      expect(result.strike.nonStrikerRuns, 11); // credited the single first
    });

    test('the ball completing an over asks for a new bowler and clears the pointer', () {
      final pre = _pre(overLegalDeliveries: 5);
      final result = previewBall(
        pre: pre,
        req: _req(runs: 0),
        totalOvers: 20,
        inningsNumber: 1,
      );

      expect(result.overComplete, isTrue);
      expect(result.newBowlerRequired, isTrue);
      expect(result.bowlerJustBowled, 'Bumrah');
      expect(result.nextPreEventState.currentBowlerName, isNull);
      expect(result.nextPreEventState.overLegalDeliveries, 0);
      expect(result.nextPreEventState.overTotalRuns, 0);
    });

    test('the tenth wicket ends the innings and asks for no bowler even off the last ball of an over', () {
      final pre = _pre(wickets: 9, overLegalDeliveries: 5);
      final result = previewBall(
        pre: pre,
        req: _req(runs: 0, wicketType: 'lbw'),
        totalOvers: 20,
        inningsNumber: 1,
      );

      expect(result.overComplete, isTrue);
      expect(result.inningsComplete, isTrue);
      expect(result.newBowlerRequired, isFalse);
      expect(result.inningsTotals.wickets, 10);
    });

    test('reaching the target mid-over ends innings 2 immediately', () {
      final pre = _pre(totalRuns: 96, overLegalDeliveries: 1);
      final result = previewBall(
        pre: pre,
        req: _req(runs: 4),
        totalOvers: 20,
        inningsNumber: 2,
        target: 100,
      );

      expect(result.inningsTotals.totalRuns, 100);
      expect(result.inningsComplete, isTrue);
      expect(result.overComplete, isFalse); // mid-over, not an over boundary
    });

    test('two balls chained through nextPreEventState accumulate correctly', () {
      final pre = _pre(overLegalDeliveries: 4, totalRuns: 24);

      final first = previewBall(
        pre: pre,
        req: _req(runs: 1), // rotates
        totalOvers: 20,
        inningsNumber: 1,
      );

      final second = previewBall(
        pre: first.nextPreEventState,
        req: _req(runs: 4), // no rotation — over completes here (6th legal ball)
        totalOvers: 20,
        inningsNumber: 1,
      );

      expect(first.nextPreEventState.overLegalDeliveries, 5);
      // Ball 1 (a single, odd) rotates: Rohit → Ishan on strike.
      expect(first.strike.strikerName, 'Ishan Kishan');

      expect(second.overComplete, isTrue);
      expect(second.inningsTotals.totalRuns, 24 + 1 + 4);
      // Ball 2 (a four, even — would not rotate on its own) still rotates
      // because it completes the over, and over-end always rotates
      // regardless of runs. The two rotations land Rohit back on strike for
      // the next over, matching real cricket: ends swap every over even off
      // a boundary that ran no runs between the wickets.
      expect(second.strike.strikerName, 'Rohit Sharma');
      expect(second.strike.nonStrikerName, 'Ishan Kishan');
    });
  });
}
