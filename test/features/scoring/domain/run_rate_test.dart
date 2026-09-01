import 'package:cricket_scorer/features/scoring/domain/run_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PartnershipCheckpoint.startFromServerPartnership', () {
    test(
      'backs out the checkpoint from the server-reported partnership, not '
      'from the raw current totals',
      () {
        final checkpoint = PartnershipCheckpoint();

        // Innings total is 18/0 off 3 balls, but the server says the current
        // partnership (since the last wicket) is only 5 runs off 2 balls —
        // e.g. a resumed session joining mid-innings.
        checkpoint.startFromServerPartnership(
          currentRuns: 18,
          currentLegalBalls: 3,
          partnershipRuns: 5,
          partnershipLegalBalls: 2,
        );

        expect(checkpoint.runs, 13);
        expect(checkpoint.legalBalls, 1);
        // The consumer's own math: currentTotals - checkpoint === what the
        // server reported.
        expect(18 - checkpoint.runs, 5);
        expect(3 - checkpoint.legalBalls, 2);
      },
    );

    test(
      'seeding from zero partnership (server says nothing has changed since '
      'the last wicket) reads back as the connection moment itself',
      () {
        final checkpoint = PartnershipCheckpoint();

        checkpoint.startFromServerPartnership(
          currentRuns: 40,
          currentLegalBalls: 30,
          partnershipRuns: 0,
          partnershipLegalBalls: 0,
        );

        expect(checkpoint.runs, 40);
        expect(checkpoint.legalBalls, 30);
      },
    );

    test(
      'a wicket after a server-seeded checkpoint can still be undone '
      'correctly — the seed counts as a real checkpoint for the stack',
      () {
        final checkpoint = PartnershipCheckpoint();
        checkpoint.startFromServerPartnership(
          currentRuns: 18,
          currentLegalBalls: 3,
          partnershipRuns: 5,
          partnershipLegalBalls: 2,
        );

        checkpoint.onWicket(totalRunsAfter: 20, legalBallsAfter: 4);
        expect(checkpoint.runs, 20);
        expect(checkpoint.legalBalls, 4);

        checkpoint.onUndoneWicket();
        expect(checkpoint.runs, 13);
        expect(checkpoint.legalBalls, 1);
      },
    );

    test(
      'discards any earlier undo history — a fresh seed is a fresh partnership',
      () {
        final checkpoint = PartnershipCheckpoint();
        checkpoint.start(runs: 0, legalBalls: 0);
        checkpoint.onWicket(totalRunsAfter: 10, legalBallsAfter: 5);

        checkpoint.startFromServerPartnership(
          currentRuns: 50,
          currentLegalBalls: 40,
          partnershipRuns: 8,
          partnershipLegalBalls: 6,
        );

        // The pre-seed wicket history must not resurface on a later undo.
        checkpoint.onUndoneWicket();
        expect(checkpoint.runs, 42);
        expect(checkpoint.legalBalls, 34);
      },
    );
  });
}
