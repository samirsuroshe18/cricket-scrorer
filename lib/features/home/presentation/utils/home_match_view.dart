import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_result_banner.dart';
import 'package:get/get.dart';

/// Display-only derivations the Home dashboard needs from a
/// [MatchHistoryItem]. Nothing here decides anything the server owns — no
/// scoring, no strike, no result: every function reads fields the API
/// already sent and shapes them for a card.

/// Whether the signed-in user is the one scoring [item].
///
/// The history list only ever holds matches the caller created or was
/// assigned, so an unassigned match is theirs by construction; once a scorer
/// is assigned, scoring belongs to that person alone — even to the creator,
/// who then only sees the match to track it. Mirrors the wording rule in
/// `MatchHistoryCard._delegationLabel`.
bool isScoredBy(MatchHistoryItem item, String userId) {
  final scorer = item.assignedScorer;
  if (scorer == null) return true;
  return userId.isNotEmpty && scorer.id == userId;
}

/// Legal deliveries bowled, from the server's `"N.n"` overs string — `"16.2"`
/// is 98. Null for anything that isn't in that shape.
int? legalBallsFromOvers(String overs) {
  final parts = overs.split('.');
  if (parts.length != 2) return null;
  final whole = int.tryParse(parts[0]);
  final balls = int.tryParse(parts[1]);
  if (whole == null || balls == null) return null;
  return whole * 6 + balls;
}

/// "Need 38 off 22" for a chase in progress; null when there is no chase
/// (innings 1, an older server that sends no target) or it is already won.
({int runsNeeded, int ballsLeft})? chaseNeeded(MatchHistoryItem item) {
  final innings = item.currentInnings;
  final target = innings?.target;
  if (innings == null || target == null) return null;
  final bowled = legalBallsFromOvers(innings.overs);
  if (bowled == null) return null;
  final runsNeeded = target - innings.totalRuns;
  if (runsNeeded <= 0) return null;
  final ballsLeft = item.totalOvers * 6 - bowled;
  return (runsNeeded: runsNeeded, ballsLeft: ballsLeft < 0 ? 0 : ballsLeft);
}

/// The batting side's name, or null when the server did not say who bats.
String? battingTeamName(MatchHistoryItem item) {
  return switch (item.currentInnings?.battingTeam) {
    'teamA' => item.teamA.name,
    'teamB' => item.teamB.name,
    _ => null,
  };
}

/// The side not currently batting.
String? bowlingTeamName(MatchHistoryItem item) {
  return switch (item.currentInnings?.battingTeam) {
    'teamA' => item.teamB.name,
    'teamB' => item.teamA.name,
    _ => null,
  };
}

/// What a ball dot shows. Cricket notation, deliberately not translated:
/// `W`, `Wd` and `Nb` are the same on every scorecard the app will ever
/// sit next to.
String recentBallLabel(RecentBall ball) {
  if (ball.isWicket) return 'W';
  final suffix = switch (ball.extraType) {
    'wide' => 'Wd',
    'no_ball' => 'Nb',
    _ => null,
  };
  if (suffix == null) return '${ball.totalRuns}';
  return ball.totalRuns > 1 ? '${ball.totalRuns}$suffix' : suffix;
}

enum RecentBallKind { plain, boundary, wicket, extra }

RecentBallKind recentBallKind(RecentBall ball) {
  if (ball.isWicket) return RecentBallKind.wicket;
  if (ball.extraType != null) return RecentBallKind.extra;
  if (ball.totalRuns == 4 || ball.totalRuns == 6) {
    return RecentBallKind.boundary;
  }
  return RecentBallKind.plain;
}

/// "Mumbai won by 24 runs" for a decided match, the abandoned label for an
/// abandoned one, null while the match is still going.
String? resultLine(MatchHistoryItem item) {
  if (item.status == 'abandoned') return TranslationKeys.statusAbandoned.tr;
  final result = item.result;
  if (item.status != 'completed' || result == null) return null;
  return matchResultText(
    result,
    (side) => side == 'teamA' ? item.teamA.name : item.teamB.name,
  );
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "18 Sep" — no year, for rows that only ever show recent matches. Same
/// no-`intl`, not-locale-aware convention as the rest of the app's dates.
String shortDate(String iso) {
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return iso;
  return '${date.day} ${_months[date.month - 1]}';
}

/// Up to two initials for the header avatar — "cricket_final" → "CF",
/// "Priya Nair" → "PN". `?` when there is nothing to draw from.
String initialsFor(String? name) {
  final words = (name ?? '')
      .trim()
      .split(RegExp(r'[\s_.\-]+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    final word = words.first;
    return word.substring(0, word.length > 1 ? 2 : 1).toUpperCase();
  }
  return (words.first[0] + words[1][0]).toUpperCase();
}
