import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses a team profile with a populated roster', () {
    final res = TeamProfileRes.fromJson({
      'teamId': '665f1a2b3c4d5e6f7a8b9c01',
      'name': 'Mumbai Indians',
      'shortName': 'MI',
      'canManage': true,
      'roster': [
        {
          'playerId': '665f3b1c2d3e4f5a6b7c8d90',
          'playerName': 'Rahul',
          'jerseyNumber': 7,
          'role': 'batsman',
        },
      ],
    });

    expect(res.teamId, '665f1a2b3c4d5e6f7a8b9c01');
    expect(res.shortName, 'MI');
    expect(res.canManage, isTrue);
    expect(res.roster.single.playerName, 'Rahul');
    expect(res.roster.single.jerseyNumber, 7);
    expect(res.roster.single.role, 'batsman');
  });

  test(
    'fromJson accepts a null shortName, false canManage, and an empty roster',
    () {
      final res = TeamProfileRes.fromJson({
        'teamId': '665f1a2b3c4d5e6f7a8b9c01',
        'name': 'Mumbai Indians',
        'shortName': null,
        'canManage': false,
        'roster': <dynamic>[],
      });

      expect(res.shortName, isNull);
      expect(res.canManage, isFalse);
      expect(res.roster, isEmpty);
    },
  );

  test('fromJson parses stats, captain ids and roster flags', () {
    final res = TeamProfileRes.fromJson({
      'teamId': 't1',
      'name': 'Mumbai Indians',
      'canManage': true,
      'captainId': 'p1',
      'viceCaptainId': 'p2',
      'stats': {
        'played': 12,
        'won': 7,
        'lost': 4,
        'tied': 1,
        'noResult': 0,
        'winPercentage': 58.3,
        'form': ['W', 'L', 'W', 'W', 'T'],
      },
      'roster': [
        {
          'playerId': 'p1',
          'playerName': 'Rohit',
          'jerseyNumber': 45,
          'role': 'batsman',
          'isCaptain': true,
          'isViceCaptain': false,
        },
      ],
    });

    expect(res.captainId, 'p1');
    expect(res.viceCaptainId, 'p2');
    expect(res.stats?.played, 12);
    expect(res.stats?.won, 7);
    expect(res.stats?.winPercentage, 58.3);
    expect(res.stats?.form, ['W', 'L', 'W', 'W', 'T']);
    expect(res.roster.single.isCaptain, isTrue);
    expect(res.roster.single.isViceCaptain, isFalse);
  });

  test('fromJson accepts an integer winPercentage', () {
    final res = TeamProfileRes.fromJson({
      'teamId': 't1',
      'name': 'Mumbai Indians',
      'canManage': true,
      'stats': {
        'played': 1,
        'won': 1,
        'lost': 0,
        'tied': 0,
        'noResult': 0,
        'winPercentage': 100,
        'form': ['W'],
      },
      'roster': <dynamic>[],
    });

    expect(res.stats?.winPercentage, 100.0);
  });

  test('fromJson tolerates a legacy payload without stats or leader fields', () {
    final res = TeamProfileRes.fromJson({
      'teamId': 't1',
      'name': 'Mumbai Indians',
      'canManage': true,
      'roster': [
        {
          'playerId': 'p1',
          'playerName': 'Rahul',
          'jerseyNumber': null,
          'role': 'unknown',
        },
      ],
    });

    expect(res.stats, isNull);
    expect(res.captainId, isNull);
    expect(res.viceCaptainId, isNull);
    expect(res.roster.single.isCaptain, isFalse);
    expect(res.roster.single.isViceCaptain, isFalse);
  });
}
