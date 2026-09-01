import 'package:cricket_scorer/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

// Validators.password used to check emptiness on the trimmed value but
// length on the raw one — so padding a single real character with spaces
// (e.g. "a     ") read as non-empty AND long enough, even though the
// meaningful content was one character. The minimum was also 6, while the
// backend's own MIN_PASSWORD_LENGTH is 8 — a password the client accepted
// as valid could still be rejected by the server.
void main() {
  group('Validators.password', () {
    test('rejects a single real character padded out with spaces', () {
      expect(Validators.password('a     '), isNotNull);
    });

    test('rejects an all-whitespace value as empty, not merely short', () {
      expect(Validators.password('        '), isNotNull);
    });

    test('rejects a password shorter than 8 real characters', () {
      expect(Validators.password('abc1234'), isNotNull);
    });

    test('accepts a password with at least 8 real characters', () {
      expect(Validators.password('abc12345'), isNull);
    });
  });
}
