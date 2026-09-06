import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FixtureRes.fromJson parses a scheduled fixture with no winner', () {
    final json = {
      'id': 'fixture-1',
      'round': 1,
      'order': 0,
      'teamA': {'id': 'team-1', 'name': 'Harbor CC', 'shortName': 'HCC'},
      'teamB': {'id': 'team-2', 'name': 'Lakeside XI', 'shortName': null},
      'isBye': false,
      'status': 'scheduled',
      'winner': null,
      'matchId': null,
    };

    final fixture = FixtureRes.fromJson(json);

    expect(fixture.teamA.name, 'Harbor CC');
    expect(fixture.teamB?.name, 'Lakeside XI');
    expect(fixture.isBye, isFalse);
    expect(fixture.winner, isNull);
    expect(fixture.matchId, isNull);
  });

  test('FixtureRes.fromJson parses a bye fixture with teamB null', () {
    final json = {
      'id': 'fixture-2',
      'round': 1,
      'order': 1,
      'teamA': {'id': 'team-3', 'name': 'Riverside U19', 'shortName': null},
      'teamB': null,
      'isBye': true,
      'status': 'bye',
      'winner': {'id': 'team-3', 'name': 'Riverside U19'},
      'matchId': null,
    };

    final fixture = FixtureRes.fromJson(json);

    expect(fixture.teamB, isNull);
    expect(fixture.isBye, isTrue);
    expect(fixture.winner?.id, 'team-3');
  });

  test('FixtureRes.fromJson parses a completed fixture with a matchId', () {
    final json = {
      'id': 'fixture-3',
      'round': 1,
      'order': 2,
      'teamA': {'id': 'team-4', 'name': 'Eastgate CC', 'shortName': null},
      'teamB': {'id': 'team-5', 'name': 'Northside Warriors', 'shortName': null},
      'isBye': false,
      'status': 'completed',
      'winner': {'id': 'team-4', 'name': 'Eastgate CC'},
      'matchId': 'match-9',
    };

    final fixture = FixtureRes.fromJson(json);

    expect(fixture.status, 'completed');
    expect(fixture.winner?.name, 'Eastgate CC');
    expect(fixture.matchId, 'match-9');
  });
}
