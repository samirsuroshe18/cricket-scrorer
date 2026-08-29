import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_over.dart';
import 'package:flutter_test/flutter_test.dart';

PreEventState _pre({
  int overLegalDeliveries = 0,
  int wickets = 0,
  int oversCompleted = 0,
  int totalRuns = 0,
}) {
  return PreEventState(
    totalRuns: totalRuns,
    wickets: wickets,
    legalBalls: oversCompleted * 6 + overLegalDeliveries,
    totalBalls: oversCompleted * 6 + overLegalDeliveries,
    oversCompleted: oversCompleted,
    overTotalRuns: 0,
    overLegalDeliveries: overLegalDeliveries,
  );
}

void main() {
  group('completesOver', () {
    for (final n in [0, 1, 2, 3, 4]) {
      test('does not fire at $n legal deliveries', () {
        expect(
          completesOver(isLegal: true, overLegalDeliveries: n),
          isFalse,
        );
      });
    }

    test('fires on the 6th legal delivery (overLegalDeliveries == 5 before it)', () {
      expect(completesOver(isLegal: true, overLegalDeliveries: 5), isTrue);
    });

    test('never fires on an illegal delivery, regardless of count', () {
      expect(completesOver(isLegal: false, overLegalDeliveries: 5), isFalse);
    });
  });

  group('resolveBallOutcome', () {
    test('a plain mid-over ball changes nothing structural', () {
      final outcome = resolveBallOutcome(
        isLegal: true,
        isWicket: false,
        teamRuns: 1,
        pre: _pre(overLegalDeliveries: 2),
        totalOvers: 20,
      );

      expect(outcome.overComplete, isFalse);
      expect(outcome.allOut, isFalse);
      expect(outcome.oversDone, isFalse);
      expect(outcome.targetAchieved, isFalse);
      expect(outcome.inningsComplete, isFalse);
      expect(outcome.newBowlerRequired, isFalse);
    });

    test('the 10th wicket ends the innings regardless of overs left', () {
      final outcome = resolveBallOutcome(
        isLegal: true,
        isWicket: true,
        pre: _pre(wickets: 9, overLegalDeliveries: 2),
        totalOvers: 20,
      );

      expect(outcome.wicketsAfter, 10);
      expect(outcome.allOut, isTrue);
      expect(outcome.inningsComplete, isTrue);
      // All out on a non-over-ending ball asks for no bowler — there is no
      // next over.
      expect(outcome.newBowlerRequired, isFalse);
    });

    test('the last legal ball of the last over ends the innings and asks for no bowler', () {
      final outcome = resolveBallOutcome(
        isLegal: true,
        isWicket: false,
        pre: _pre(overLegalDeliveries: 5, oversCompleted: 19),
        totalOvers: 20,
      );

      expect(outcome.overComplete, isTrue);
      expect(outcome.oversDone, isTrue);
      expect(outcome.inningsComplete, isTrue);
      expect(outcome.newBowlerRequired, isFalse);
    });

    test('an over ending mid-innings (more overs left) asks for a new bowler', () {
      final outcome = resolveBallOutcome(
        isLegal: true,
        isWicket: false,
        pre: _pre(overLegalDeliveries: 5, oversCompleted: 3),
        totalOvers: 20,
      );

      expect(outcome.overComplete, isTrue);
      expect(outcome.inningsComplete, isFalse);
      expect(outcome.newBowlerRequired, isTrue);
    });

    group('target precedence — targetAchieved > allOut > oversDone', () {
      test('reaching the target on the very ball that would also be the last over wins as targetAchieved', () {
        final outcome = resolveBallOutcome(
          isLegal: true,
          isWicket: false,
          teamRuns: 4,
          pre: _pre(overLegalDeliveries: 5, oversCompleted: 19, totalRuns: 96),
          totalOvers: 20,
          inningsNumber: 2,
          target: 100,
        );

        expect(outcome.totalRunsAfter, 100);
        expect(outcome.targetAchieved, isTrue);
        expect(outcome.oversDone, isTrue); // still true underneath
        expect(outcome.inningsComplete, isTrue);
      });

      test('the 10th wicket falling on the last ball of the last over is all_out, not overs_complete', () {
        final outcome = resolveBallOutcome(
          isLegal: true,
          isWicket: true,
          pre: _pre(wickets: 9, overLegalDeliveries: 5, oversCompleted: 19),
          totalOvers: 20,
          inningsNumber: 2,
          target: 500, // nowhere close — target not achieved
        );

        expect(outcome.allOut, isTrue);
        expect(outcome.oversDone, isTrue);
        expect(outcome.targetAchieved, isFalse);
        expect(outcome.inningsComplete, isTrue);
      });

      test('innings 1 never checks the target even if one were somehow passed in', () {
        final outcome = resolveBallOutcome(
          isLegal: true,
          isWicket: false,
          teamRuns: 100,
          pre: _pre(totalRuns: 50),
          totalOvers: 20,
          // inningsNumber defaults to 1
          target: 10,
        );

        expect(outcome.targetAchieved, isFalse);
      });
    });
  });
}
