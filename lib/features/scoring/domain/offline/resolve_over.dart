import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';

/// Client-side mirror of the backend's `resolveOver.js`. See
/// `resolve_delivery.dart` for why this is a port rather than a
/// reimplementation, and its limits.

/// Six LEGAL deliveries — wides and no-balls never advance the over, byes
/// and leg-byes do.
const int legalDeliveriesPerOver = 6;

const int maxWickets = 10;

/// An over completes on the TRANSITION, not the state: this delivery is legal
/// AND takes the over from 5 legal deliveries to 6. `overLegalDeliveries` is
/// the count BEFORE this delivery is applied.
bool completesOver({required bool isLegal, required int overLegalDeliveries}) =>
    isLegal && overLegalDeliveries == legalDeliveriesPerOver - 1;

class BallOutcome {
  final bool overComplete;
  final int wicketsAfter;
  final int oversCompletedAfter;
  final int totalRunsAfter;
  final bool allOut;
  final bool oversDone;
  final bool targetAchieved;
  final bool inningsComplete;
  final bool newBowlerRequired;

  const BallOutcome({
    required this.overComplete,
    required this.wicketsAfter,
    required this.oversCompletedAfter,
    required this.totalRunsAfter,
    required this.allOut,
    required this.oversDone,
    required this.targetAchieved,
    required this.inningsComplete,
    required this.newBowlerRequired,
  });
}

/// Everything this delivery did to the over and the innings, derived from
/// [pre] rather than from any live state — the same discipline the server
/// applies for the same reason: a preview and, later, the real ack must
/// derive identically or they will visibly disagree for a moment.
BallOutcome resolveBallOutcome({
  required bool isLegal,
  required bool isWicket,
  int teamRuns = 0,
  required PreEventState pre,
  required int totalOvers,
  int inningsNumber = 1,
  int? target,
}) {
  final overComplete = completesOver(
    isLegal: isLegal,
    overLegalDeliveries: pre.overLegalDeliveries,
  );

  final wicketsAfter = pre.wickets + (isWicket ? 1 : 0);
  final oversCompletedAfter = pre.oversCompleted + (overComplete ? 1 : 0);
  final totalRunsAfter = pre.totalRuns + teamRuns;

  final allOut = wicketsAfter >= maxWickets;
  // Only an over boundary can exhaust the overs — a mid-over ball can never
  // take oversCompleted past the limit.
  final oversDone = overComplete && oversCompletedAfter >= totalOvers;

  final targetAchieved =
      inningsNumber == 2 && target != null && totalRunsAfter >= target;

  final inningsComplete = targetAchieved || allOut || oversDone;

  return BallOutcome(
    overComplete: overComplete,
    wicketsAfter: wicketsAfter,
    oversCompletedAfter: oversCompletedAfter,
    totalRunsAfter: totalRunsAfter,
    allOut: allOut,
    oversDone: oversDone,
    targetAchieved: targetAchieved,
    inningsComplete: inningsComplete,
    newBowlerRequired: overComplete && !inningsComplete,
  );
}
