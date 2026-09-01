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
/// A session that joins or resumes mid-partnership has no ball history of its
/// own to recover the true checkpoint from — that's what
/// [startFromServerPartnership] is for, seeding it from a server-computed
/// figure instead of guessing. [start] remains the fallback for a payload
/// that genuinely has no partnership to report (a fresh innings, or one that
/// has not started yet — see [SpectatorController.currentBowler] for the
/// same shape of "nothing to seed from yet" case) and for a moment that truly
/// is the start of a new partnership.
class PartnershipCheckpoint {
  int runs = 0;
  int legalBalls = 0;

  /// Checkpoints superseded by [onWicket], most recent last. Popped by
  /// [onUndoneWicket] to walk back exactly one dismissal — never rebuilt from
  /// scratch, since nothing here has the ball history to do that.
  final List<_Snapshot> _previous = [];

  /// Call once per new partnership: innings start, or resuming/joining
  /// mid-innings with the totals as they stand right now — the fallback for
  /// when nothing better is available; prefer [startFromServerPartnership]
  /// wherever a payload actually carries the server's own figure.
  void start({required int runs, required int legalBalls}) {
    this.runs = runs;
    this.legalBalls = legalBalls;
    _previous.clear();
  }

  /// Call once per new partnership when the server reports the current
  /// partnership directly — a `match:state` join ack or the initial public
  /// fetch, both computed from the innings' full ball history, which this
  /// client does not have. [currentRuns]/[currentLegalBalls] are the innings
  /// totals that same payload carries; [partnershipRuns]/[partnershipBalls]
  /// are what the server says the not-out pair has added since the last
  /// wicket. Backs out the checkpoint those two facts imply, rather than
  /// assuming (as [start] has to) that the connection moment IS the start of
  /// a new partnership.
  void startFromServerPartnership({
    required int currentRuns,
    required int currentLegalBalls,
    required int partnershipRuns,
    required int partnershipLegalBalls,
  }) {
    runs = currentRuns - partnershipRuns;
    legalBalls = currentLegalBalls - partnershipLegalBalls;
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
