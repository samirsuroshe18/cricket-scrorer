/// Current/required run rate and partnership math, shared by the scorer's
/// console and the spectator screen so the two can never compute a number
/// differently. Pure functions only — every input here already exists as
/// server-reported state on both controllers; nothing is derived that the
/// server did not say.
library;

/// Legal deliveries bowled, parsed from the `overs` display string
/// (`"<completedOvers>.<legalBallsInCurrentOver>"`). Needed wherever a
/// payload carries `overs` but not `InningsTotals.legalBalls` directly —
/// `score:update`, `match:state` and the public fetch all do.
int legalBallsFromOvers(String overs) {
  final parts = overs.split('.');
  final completed = int.tryParse(parts[0]) ?? 0;
  final partial = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return completed * 6 + partial;
}

/// Runs per (legal) over so far. Zero before the first legal delivery — there
/// is no rate yet, not an infinite one.
///
/// Named `compute*` rather than `currentRunRate` on purpose: both controllers
/// expose an observable of that name, and an unqualified call from inside
/// either class would resolve to the field, not this function.
double computeCurrentRunRate({required int totalRuns, required int legalBalls}) {
  if (legalBalls <= 0) return 0;
  return totalRuns / (legalBalls / 6);
}

/// Runs per over needed to reach [target]. Null whenever there is nothing to
/// chase: innings 1 ([target] null) or no legal deliveries left in the match.
/// Zero once [target] is already reached — never negative.
double? computeRequiredRunRate({
  required int? target,
  required int totalRuns,
  required int legalBallsBowled,
  required int totalOvers,
}) {
  if (target == null) return null;
  final ballsRemaining = totalOvers * 6 - legalBallsBowled;
  if (ballsRemaining <= 0) return null;
  final runsNeeded = target - totalRuns;
  if (runsNeeded <= 0) return 0;
  return runsNeeded / (ballsRemaining / 6);
}

/// One (runs, legalBalls) pair — the innings totals a partnership started
/// from.
typedef _Snapshot = ({int runs, int legalBalls});

/// The runs/legal-balls the current partnership started from. Partnership
/// figures are always `currentTotals - checkpoint`; only the checkpoint moves,
/// and only on a wicket (forward) or undoing one (backward).
///
/// A session that joins or resumes mid-partnership has no ball history to
/// recover the true checkpoint from, so it starts at whatever totals were
/// current on connect — the partnership then reads "since I connected," not
/// "since the wicket," until the next dismissal makes it exact. Same shape of
/// limitation as [SpectatorController.currentBowler]'s documented staleness;
/// not solved for the same reason — it would need the backend to track
/// partnerships from `BallEvent` history, which nothing here does yet.
class PartnershipCheckpoint {
  int runs = 0;
  int legalBalls = 0;

  /// Checkpoints superseded by [onWicket], most recent last. Popped by
  /// [onUndoneWicket] to walk back exactly one dismissal — never rebuilt from
  /// scratch, since nothing here has the ball history to do that.
  final List<_Snapshot> _previous = [];

  /// Call once per new partnership: innings start, or resuming/joining
  /// mid-innings with the totals as they stand right now.
  void start({required int runs, required int legalBalls}) {
    this.runs = runs;
    this.legalBalls = legalBalls;
    _previous.clear();
  }

  /// Call after applying a ball whose `wicket` was non-null, with the innings
  /// totals *after* that ball — the state the new pair starts from.
  void onWicket({required int totalRunsAfter, required int legalBallsAfter}) {
    _previous.add((runs: runs, legalBalls: legalBalls));
    runs = totalRunsAfter;
    legalBalls = legalBallsAfter;
  }

  /// Call when an undo removed a wicket ball — restores the checkpoint the
  /// dismissal had superseded. A no-op if nothing is on the stack, which only
  /// happens if the very first ball of the connection was itself undone.
  void onUndoneWicket() {
    if (_previous.isEmpty) return;
    final restored = _previous.removeLast();
    runs = restored.runs;
    legalBalls = restored.legalBalls;
  }
}
