import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:flutter_test/flutter_test.dart';

// publicMatch is the one endpoint here built from a value that can be raw
// user input (typed into the spectate-by-code sheet, or read off a deep
// link) rather than a server-generated id — unlike every other builder in
// this class, which only ever receives an ObjectId hex string. It used to
// interpolate `code` straight into the path with no encoding at all, safe
// only because both current callers happen to hand it something already
// path-safe. A future caller isn't guaranteed that.
void main() {
  const endpoint = MatchEndpoint();

  test('percent-encodes characters that are not safe in a URL path segment', () {
    expect(
      endpoint.publicMatch('AB CD/12'),
      '/v1/match/public/AB%20CD%2F12',
    );
  });

  test('leaves an ordinary alphanumeric share code untouched', () {
    expect(endpoint.publicMatch('AB12CD'), '/v1/match/public/AB12CD');
  });

  test('myTeams is a fixed path', () {
    expect(endpoint.myTeams, '/v1/team');
  });

  test('teamProfile interpolates the team id with no encoding', () {
    expect(
      endpoint.teamProfile('665f1a2b3c4d5e6f7a8b9c01'),
      '/v1/team/665f1a2b3c4d5e6f7a8b9c01',
    );
  });

  test('teamMatches interpolates the team id with no encoding', () {
    expect(
      endpoint.teamMatches('665f1a2b3c4d5e6f7a8b9c01'),
      '/v1/team/665f1a2b3c4d5e6f7a8b9c01/matches',
    );
  });
}
