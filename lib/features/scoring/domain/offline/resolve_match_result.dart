import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_over.dart';

/// Client-side mirror of the backend's `resolveMatchResult.js`, ported line
/// for line so the two can never disagree. Unlike the ball/over rules this
/// sits beside, the server never explicitly refused this one to the client —
/// it simply never needed a preview before. It needs only both innings'
/// final `battingTeam`/`totalRuns` and innings 2's `wickets`, all of which
/// this device already has once innings 2's terminal ball is queued, which
/// is what makes it safe to preview: unlike the scorecard's per-batsman
/// figures, nothing here needs data only the server holds.
///
/// Covered by tests/resolveMatchResult.test.js on the backend; this file's
/// own test port mirrors those same cases.
MatchResultInfo resolveMatchResultPreview({
  required String? completionReason,
  required String battingTeam1,
  required String battingTeam2,
  required int runs1,
  required int runs2,
  required int wickets2,
}) {
  if (completionReason == 'target_achieved') {
    return MatchResultInfo(
      winner: battingTeam2,
      marginType: 'wickets',
      margin: maxWickets - wickets2,
    );
  }

  if (runs2 == runs1) {
    return MatchResultInfo(winner: 'tie');
  }

  if (runs2 > runs1) {
    // Reached ahead of the target's own boundary check firing is not a real
    // path today — target_achieved above catches every case this app can
    // produce — but resolving it as a runs win rather than assuming it
    // unreachable keeps this function correct if that ever changes, exactly
    // matching the backend's own comment here.
    return MatchResultInfo(
      winner: battingTeam2,
      marginType: 'runs',
      margin: runs2 - runs1,
    );
  }

  return MatchResultInfo(
    winner: battingTeam1,
    marginType: 'runs',
    margin: runs1 - runs2,
  );
}
