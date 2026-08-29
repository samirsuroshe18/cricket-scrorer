import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_delivery.dart';
import 'package:flutter_test/flutter_test.dart';

// Mirrors the scenario table in the backend's tests/resolveDelivery.test.js —
// same cases, same invariants, so the client's provisional preview can never
// silently disagree with the server it is standing in for.
void main() {
  group('resolveDelivery', () {
    final cases = <String, ({
      int runs,
      String? extraType,
      String runsFrom,
      int ballRuns,
      int ballExtras,
      bool isLegal,
      bool rotatesOnRuns,
      int wides,
      int noBalls,
      int byes,
      int legByes,
    })>{
      'dot ball': (
        runs: 0, extraType: null, runsFrom: RunsFrom.bat,
        ballRuns: 0, ballExtras: 0, isLegal: true, rotatesOnRuns: false,
        wides: 0, noBalls: 0, byes: 0, legByes: 0,
      ),
      'four off the bat': (
        runs: 4, extraType: null, runsFrom: RunsFrom.bat,
        ballRuns: 4, ballExtras: 0, isLegal: true, rotatesOnRuns: false,
        wides: 0, noBalls: 0, byes: 0, legByes: 0,
      ),
      'a single (rotates)': (
        runs: 1, extraType: null, runsFrom: RunsFrom.bat,
        ballRuns: 1, ballExtras: 0, isLegal: true, rotatesOnRuns: true,
        wides: 0, noBalls: 0, byes: 0, legByes: 0,
      ),
      '2 byes': (
        runs: 2, extraType: null, runsFrom: RunsFrom.bye,
        ballRuns: 0, ballExtras: 2, isLegal: true, rotatesOnRuns: false,
        wides: 0, noBalls: 0, byes: 2, legByes: 0,
      ),
      '1 leg-bye': (
        runs: 1, extraType: null, runsFrom: RunsFrom.legBye,
        ballRuns: 0, ballExtras: 1, isLegal: true, rotatesOnRuns: true,
        wides: 0, noBalls: 0, byes: 0, legByes: 1,
      ),
      'plain wide': (
        runs: 0, extraType: ExtraType.wide, runsFrom: RunsFrom.bat,
        ballRuns: 0, ballExtras: 1, isLegal: false, rotatesOnRuns: false,
        wides: 1, noBalls: 0, byes: 0, legByes: 0,
      ),
      'wide with 2 run': (
        runs: 2, extraType: ExtraType.wide, runsFrom: RunsFrom.bat,
        ballRuns: 0, ballExtras: 3, isLegal: false, rotatesOnRuns: false,
        wides: 3, noBalls: 0, byes: 0, legByes: 0,
      ),
      'wide with 1 run (odd runs still rotate, even off a wide)': (
        runs: 1, extraType: ExtraType.wide, runsFrom: RunsFrom.bat,
        ballRuns: 0, ballExtras: 2, isLegal: false, rotatesOnRuns: true,
        wides: 2, noBalls: 0, byes: 0, legByes: 0,
      ),
      'plain no-ball': (
        runs: 0, extraType: ExtraType.noBall, runsFrom: RunsFrom.bat,
        ballRuns: 0, ballExtras: 1, isLegal: false, rotatesOnRuns: false,
        wides: 0, noBalls: 1, byes: 0, legByes: 0,
      ),
      'no-ball hit for four': (
        runs: 4, extraType: ExtraType.noBall, runsFrom: RunsFrom.bat,
        ballRuns: 4, ballExtras: 1, isLegal: false, rotatesOnRuns: false,
        wides: 0, noBalls: 1, byes: 0, legByes: 0,
      ),
      'no-ball that went for 2 byes': (
        runs: 2, extraType: ExtraType.noBall, runsFrom: RunsFrom.bye,
        ballRuns: 0, ballExtras: 3, isLegal: false, rotatesOnRuns: false,
        wides: 0, noBalls: 1, byes: 2, legByes: 0,
      ),
    };

    cases.forEach((name, c) {
      test(name, () {
        final result = resolveDelivery(
          runs: c.runs,
          extraType: c.extraType,
          runsFrom: c.runsFrom,
        );

        expect(result.ballRuns, c.ballRuns, reason: 'ballRuns');
        expect(result.ballExtras, c.ballExtras, reason: 'ballExtras');
        expect(result.isLegal, c.isLegal, reason: 'isLegal');
        expect(result.rotatesOnRuns, c.rotatesOnRuns, reason: 'rotatesOnRuns');
        expect(result.buckets.wides, c.wides, reason: 'wides');
        expect(result.buckets.noBalls, c.noBalls, reason: 'noBalls');
        expect(result.buckets.byes, c.byes, reason: 'byes');
        expect(result.buckets.legByes, c.legByes, reason: 'legByes');

        // Invariants, checked on every case rather than just asserted once.
        expect(
          result.teamRuns,
          result.ballRuns + result.ballExtras,
          reason: 'teamRuns === ballRuns + ballExtras',
        );
        expect(
          result.buckets.wides +
              result.buckets.noBalls +
              result.buckets.byes +
              result.buckets.legByes,
          result.ballExtras,
          reason: 'sum(buckets) === ballExtras',
        );
        expect(
          result.rotatesOnRuns,
          c.runs % 2 == 1,
          reason: 'rotatesOnRuns === (runs % 2 == 1), independent of extraType/runsFrom',
        );
      });
    });
  });
}
