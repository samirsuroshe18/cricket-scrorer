import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_strike.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveStrikePreview', () {
    test('no rotation, no dismissal — pair and figures pass through unchanged', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit', runs: 10, balls: 8),
        nonStriker: const BatsmanFigures(name: 'Ishan', runs: 3, balls: 4),
      );

      expect(result.striker.name, 'Rohit');
      expect(result.striker.runs, 10);
      expect(result.nonStriker.name, 'Ishan');
    });

    test('rotation swaps the whole pair, figures included', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit', runs: 10, balls: 8),
        nonStriker: const BatsmanFigures(name: 'Ishan', runs: 3, balls: 4),
        rotated: true,
      );

      expect(result.striker.name, 'Ishan');
      expect(result.striker.runs, 3);
      expect(result.nonStriker.name, 'Rohit');
      expect(result.nonStriker.runs, 10);
    });

    test('a dismissed striker is replaced by the incoming batsman at (0, 0)', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit', runs: 10, balls: 8),
        nonStriker: const BatsmanFigures(name: 'Ishan', runs: 3, balls: 4),
        isWicket: true,
        dismissedWasStriker: true,
        incomingName: 'Surya',
      );

      expect(result.striker.name, 'Surya');
      expect(result.striker.runs, 0);
      expect(result.striker.balls, 0);
      expect(result.nonStriker.name, 'Ishan');
    });

    test('a dismissed non-striker (run out) is replaced without touching the striker', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit', runs: 10, balls: 8),
        nonStriker: const BatsmanFigures(name: 'Ishan', runs: 3, balls: 4),
        isWicket: true,
        dismissedWasStriker: false,
        incomingName: 'Surya',
      );

      expect(result.striker.name, 'Rohit');
      expect(result.nonStriker.name, 'Surya');
      expect(result.nonStriker.runs, 0);
    });

    test('rotate THEN substitute: a run out on a crossed run replaces by slot, not by end', () {
      // The batsmen crossed (rotated=true) before the striker (as of before
      // this ball) was run out at the non-striker's end — so after rotation
      // he is AT the non-striker's end, and that is where the incoming
      // batsman must land, not at the end he started the ball at.
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit', runs: 10, balls: 8),
        nonStriker: const BatsmanFigures(name: 'Ishan', runs: 3, balls: 4),
        rotated: true,
        isWicket: true,
        dismissedWasStriker: true,
        incomingName: 'Surya',
      );

      // After rotation the pair is (Ishan, Rohit); Rohit is now at
      // non-striker, so that is where the substitution must land him.
      expect(result.striker.name, 'Ishan');
      expect(result.nonStriker.name, 'Surya');
    });

    test('the final wicket leaves the dismissed end empty (null incoming)', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit'),
        nonStriker: const BatsmanFigures(name: 'Ishan'),
        isWicket: true,
        dismissedWasStriker: true,
      );

      expect(result.striker.name, isNull);
    });

    // The concrete case this positional design exists for: two players who
    // share a name (a real possibility in a local lineup) at the crease
    // together. Substitution used to match on `BatsmanFigures.name`, so
    // dismissing one "Ali" could evict the *other* Ali's figures instead —
    // whichever one happened to be checked first. Positional matching can't
    // make that mistake: it never looks at either name at all.
    test(
      'two identically-named batsmen: only the dismissed slot is replaced, '
      'the other keeps their own figures',
      () {
        final result = resolveStrikePreview(
          striker: const BatsmanFigures(name: 'Ali', runs: 25, balls: 20),
          nonStriker: const BatsmanFigures(name: 'Ali', runs: 4, balls: 6),
          isWicket: true,
          dismissedWasStriker: true,
          incomingName: 'Zafar',
        );

        expect(result.striker.name, 'Zafar');
        expect(result.striker.runs, 0);
        expect(result.striker.balls, 0);

        // The OTHER Ali — still batting — must keep his own 4 off 6, not be
        // silently reset or merged with the dismissed one's figures.
        expect(result.nonStriker.name, 'Ali');
        expect(result.nonStriker.runs, 4);
        expect(result.nonStriker.balls, 6);
      },
    );

    test(
      'two identically-named batsmen, non-striker dismissed after a crossed run',
      () {
        final result = resolveStrikePreview(
          striker: const BatsmanFigures(name: 'Ali', runs: 25, balls: 20),
          nonStriker: const BatsmanFigures(name: 'Ali', runs: 4, balls: 6),
          rotated: true,
          isWicket: true,
          dismissedWasStriker: false,
          incomingName: 'Zafar',
        );

        // Rotated first: pair is now (nonStriker-Ali[4,6], striker-Ali[25,20]).
        // dismissedWasStriker=false XOR rotated=true -> now-striker slot is
        // evicted, since the pre-ball non-striker ended up there.
        expect(result.striker.name, 'Zafar');
        expect(result.striker.runs, 0);

        expect(result.nonStriker.name, 'Ali');
        expect(result.nonStriker.runs, 25);
        expect(result.nonStriker.balls, 20);
      },
    );
  });
}
