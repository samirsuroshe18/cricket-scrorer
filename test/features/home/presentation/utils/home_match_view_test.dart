import 'package:cricket_scorer/features/home/presentation/utils/home_match_view.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:flutter_test/flutter_test.dart';

MatchHistoryItem _item({
  String status = 'live',
  int totalOvers = 20,
  MatchUserRef? assignedScorer,
  MatchResultInfo? result,
  CurrentInningsSummary? innings,
}) => MatchHistoryItem(
  matchId: 'm1',
  teamA: TeamRef(id: 'a', name: 'Mumbai'),
  teamB: TeamRef(id: 'b', name: 'Pune'),
  totalOvers: totalOvers,
  status: status,
  assignedScorer: assignedScorer,
  result: result,
  createdAt: '2026-09-18T10:15:00.000Z',
  syncStatus: 'synced',
  currentInnings: innings,
);

CurrentInningsSummary _innings({
  int number = 2,
  String? battingTeam = 'teamB',
  int runs = 142,
  int wickets = 4,
  String overs = '16.2',
  int? target = 181,
}) => CurrentInningsSummary(
  inningsNumber: number,
  battingTeam: battingTeam,
  totalRuns: runs,
  wickets: wickets,
  overs: overs,
  target: target,
);

void main() {
  group('isScoredBy', () {
    test('an unassigned match is scored by whoever the list belongs to', () {
      expect(isScoredBy(_item(), 'me'), isTrue);
    });

    test('once a scorer is assigned, only that scorer is scoring', () {
      final item = _item(
        assignedScorer: MatchUserRef(id: 'other', name: 'O'),
      );
      expect(isScoredBy(item, 'me'), isFalse);
      expect(isScoredBy(item, 'other'), isTrue);
    });

    test('an unknown user id never matches an assigned scorer', () {
      final item = _item(
        assignedScorer: MatchUserRef(id: '', name: 'O'),
      );
      expect(isScoredBy(item, ''), isFalse);
    });
  });

  group('legalBallsFromOvers', () {
    test('converts N.n into balls', () {
      expect(legalBallsFromOvers('16.2'), 98);
      expect(legalBallsFromOvers('0.0'), 0);
      expect(legalBallsFromOvers('1.0'), 6);
    });

    test('rejects a malformed string', () {
      expect(legalBallsFromOvers('16'), isNull);
      expect(legalBallsFromOvers('a.b'), isNull);
    });
  });

  group('chaseNeeded', () {
    test('reports runs and balls still needed', () {
      final chase = chaseNeeded(_item(innings: _innings()));
      expect(chase, (runsNeeded: 39, ballsLeft: 22));
    });

    test('is null in the first innings, where there is no target', () {
      expect(chaseNeeded(_item(innings: _innings(target: null))), isNull);
    });

    test('is null once the target has been reached', () {
      expect(chaseNeeded(_item(innings: _innings(runs: 181))), isNull);
    });

    test('never reports a negative number of balls', () {
      final chase = chaseNeeded(
        _item(totalOvers: 1, innings: _innings(overs: '3.0')),
      );
      expect(chase?.ballsLeft, 0);
    });

    test('is null when the server sent no innings at all', () {
      expect(chaseNeeded(_item()), isNull);
    });
  });

  group('team names', () {
    test('batting and bowling sides follow battingTeam', () {
      final item = _item(innings: _innings(battingTeam: 'teamB'));
      expect(battingTeamName(item), 'Pune');
      expect(bowlingTeamName(item), 'Mumbai');
    });

    test('are null for a server that predates battingTeam', () {
      final item = _item(innings: _innings(battingTeam: null));
      expect(battingTeamName(item), isNull);
      expect(bowlingTeamName(item), isNull);
    });
  });

  group('recent balls', () {
    RecentBall ball(int runs, {String? extra, bool wicket = false}) =>
        RecentBall(totalRuns: runs, extraType: extra, isWicket: wicket);

    test('labels use cricket notation', () {
      expect(recentBallLabel(ball(0)), '0');
      expect(recentBallLabel(ball(4)), '4');
      expect(recentBallLabel(ball(0, wicket: true)), 'W');
      expect(recentBallLabel(ball(1, extra: 'wide')), 'Wd');
      expect(recentBallLabel(ball(3, extra: 'wide')), '3Wd');
      expect(recentBallLabel(ball(1, extra: 'no_ball')), 'Nb');
      expect(recentBallLabel(ball(5, extra: 'no_ball')), '5Nb');
    });

    test('a wicket wins over the runs on the same ball', () {
      expect(recentBallLabel(ball(1, wicket: true)), 'W');
      expect(recentBallKind(ball(1, wicket: true)), RecentBallKind.wicket);
    });

    test('kinds separate boundaries, extras and plain balls', () {
      expect(recentBallKind(ball(4)), RecentBallKind.boundary);
      expect(recentBallKind(ball(6)), RecentBallKind.boundary);
      expect(recentBallKind(ball(2)), RecentBallKind.plain);
      expect(recentBallKind(ball(4, extra: 'wide')), RecentBallKind.extra);
    });
  });

  group('resultLine', () {
    test('names the winner and the margin', () {
      final line = resultLine(
        _item(
          status: 'completed',
          result: MatchResultInfo(
            winner: 'teamA',
            marginType: 'runs',
            margin: 24,
          ),
        ),
      );
      // Raw keys: no translations are loaded in a bare test.
      expect(line, 'Mumbai won_by 24 runs_word');
    });

    test('uses the wickets unit for a chase', () {
      final line = resultLine(
        _item(
          status: 'completed',
          result: MatchResultInfo(
            winner: 'teamB',
            marginType: 'wickets',
            margin: 3,
          ),
        ),
      );
      expect(line, startsWith('Pune won_by 3 '));
    });

    test('is the tie line for a tie', () {
      final line = resultLine(
        _item(
          status: 'completed',
          result: MatchResultInfo(winner: 'tie'),
        ),
      );
      expect(line, 'match_tied');
    });

    test('is the abandoned label for an abandoned match', () {
      expect(resultLine(_item(status: 'abandoned')), 'status_abandoned');
    });

    test('is null while the match is still going', () {
      expect(resultLine(_item()), isNull);
    });
  });

  test('shortDate drops the year', () {
    expect(shortDate('2026-09-18T10:15:00.000Z'), matches(r'^\d{1,2} Sep$'));
    expect(shortDate('not a date'), 'not a date');
  });

  test('initialsFor handles handles, names and nothing', () {
    expect(initialsFor('cricket_final'), 'CF');
    expect(initialsFor('Priya Nair'), 'PN');
    expect(initialsFor('samir18'), 'SA');
    expect(initialsFor('x'), 'X');
    expect(initialsFor(null), '?');
    expect(initialsFor('   '), '?');
  });
}
