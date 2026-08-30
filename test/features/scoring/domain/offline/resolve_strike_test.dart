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
        dismissedName: 'Rohit',
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
        dismissedName: 'Ishan',
        incomingName: 'Surya',
      );

      expect(result.striker.name, 'Rohit');
      expect(result.nonStriker.name, 'Surya');
      expect(result.nonStriker.runs, 0);
    });

    test('rotate THEN substitute: a run out on a crossed run replaces by player, not by end', () {
      // The batsmen crossed (rotated=true) before the striker (as of before
      // this ball) was run out at the non-strikers end — so after rotation
      // he is AT the non-striker's end, and that is where the incoming
      // batsman must land, not at the end he started the ball at.
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit', runs: 10, balls: 8),
        nonStriker: const BatsmanFigures(name: 'Ishan', runs: 3, balls: 4),
        rotated: true,
        dismissedName: 'Rohit',
        incomingName: 'Surya',
      );

      // After rotation the pair is (Ishan, Rohit); Rohit is now at
      // non-striker, so that is where the substitution must land him.
      expect(result.striker.name, 'Ishan');
      expect(result.nonStriker.name, 'Surya');
    });

    test('dismissed name matching neither batsman leaves the pair untouched', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit'),
        nonStriker: const BatsmanFigures(name: 'Ishan'),
        dismissedName: 'Someone Else',
        incomingName: 'Surya',
      );

      expect(result.striker.name, 'Rohit');
      expect(result.nonStriker.name, 'Ishan');
    });

    test('name matching is case-insensitive and trims whitespace', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: '  Rohit Sharma  '),
        nonStriker: const BatsmanFigures(name: 'Ishan Kishan'),
        dismissedName: 'rohit sharma',
        incomingName: 'Surya',
      );

      expect(result.striker.name, 'Surya');
    });

    test('the final wicket leaves the dismissed end empty (null incoming)', () {
      final result = resolveStrikePreview(
        striker: const BatsmanFigures(name: 'Rohit'),
        nonStriker: const BatsmanFigures(name: 'Ishan'),
        dismissedName: 'Rohit',
      );

      expect(result.striker.name, isNull);
    });
  });
}
