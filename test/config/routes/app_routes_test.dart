import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

// WatchMatchBottomSheet hands a manually-typed spectator code straight to
// spectatorPath with no encoding of its own — unlike the deep-link path,
// which is structurally constrained by its own regex to never contain '/'
// or '?', a pasted code can carry anything the OS share sheet handed it.
// spectatorPath is the single point every caller funnels through, so
// encoding lives here rather than at each call site.
void main() {
  group('AppRoutes.spectatorPath', () {
    test('builds the ordinary path for a plain alphanumeric code', () {
      expect(AppRoutes.spectatorPath('H7K2QP'), '/spectate/H7K2QP');
    });

    test('encodes a code containing a slash, so it cannot inject a path segment', () {
      final path = AppRoutes.spectatorPath('AB/CD');
      expect(path, isNot(contains('/CD')));
      expect(path, '/spectate/AB%2FCD');
    });

    test('encodes a code containing a query-string-shaped character', () {
      final path = AppRoutes.spectatorPath('AB?x=1');
      expect(path.split('?').length, 1);
    });

    test('encodes a code containing a fragment character', () {
      final path = AppRoutes.spectatorPath('AB#frag');
      expect(path, isNot(contains('#frag')));
    });
  });
}
