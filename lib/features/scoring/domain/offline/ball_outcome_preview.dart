import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/wicket.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_delivery.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_over.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/resolve_strike.dart';

/// The composition point for the offline preview — everything
/// `score_ball_controller.dart` needs to apply a queued delivery exactly the
/// way it applies a real REST ack, built from [Strike]/[Wicket]/
/// [InningsTotals] so the SAME apply code runs either way. See
/// `resolve_delivery.dart` for why this mirrors the server rather than
/// reimplements it, and its one deliberate gap: per-ball figures are tracked
/// incrementally here (see [PreEventState.striker]/`.nonStriker`), not
/// re-aggregated from full ball history the way `liveStrikeFigures` does —
/// the two converge the instant a real ack lands, since this preview is
/// display-only and is always hard-replaced, never merged.
///
/// [nextPreEventState] is what the *next* offline ball previews against, and
/// what gets persisted as the *following* queued row's rollback snapshot —
/// this call's own input [PreEventState] is what THIS row stores, mirroring
/// the server's append-only-snapshot-per-ball design exactly.
class BallOutcomePreview {
  final Strike strike;
  final Wicket? wicket;
  final InningsTotals inningsTotals;
  final bool overComplete;
  final bool newBowlerRequired;
  final bool inningsComplete;

  /// The bowler whose over just completed — the name a picker should grey
  /// out for the next over. Null unless [overComplete] is true.
  final String? bowlerJustBowled;

  /// See [BallOutcome.completionReason]. Exposed here so a caller with only
  /// this preview — never the underlying [BallOutcome] — can still compute a
  /// provisional match result for innings 2's terminal ball, via
  /// `resolveMatchResultPreview`.
  final String? completionReason;

  final PreEventState nextPreEventState;

  const BallOutcomePreview({
    required this.strike,
    this.wicket,
    required this.inningsTotals,
    required this.overComplete,
    required this.newBowlerRequired,
    required this.inningsComplete,
    this.bowlerJustBowled,
    required this.completionReason,
    required this.nextPreEventState,
  });
}

BallOutcomePreview previewBall({
  required PreEventState pre,
  required ScoreBallReq req,
  required int totalOvers,
  required int inningsNumber,
  int? target,
}) {
  final delivery = resolveDelivery(
    runs: req.runs,
    extraType: req.extraType,
    runsFrom: req.runsFrom ?? RunsFrom.bat,
  );

  final wicketType = req.wicketType;
  final isWicket = wicketType != null;
  final dismissedIsStriker =
      (req.dismissedBatsman ?? DismissedBatsman.striker) ==
      DismissedBatsman.striker;
  final dismissedName = isWicket
      ? (dismissedIsStriker ? pre.striker.name : pre.nonStriker.name)
      : null;
  final incomingName = isWicket ? req.incomingBatsmanName : null;

  final outcome = resolveBallOutcome(
    isLegal: delivery.isLegal,
    isWicket: isWicket,
    teamRuns: delivery.teamRuns,
    pre: pre,
    totalOvers: totalOvers,
    inningsNumber: inningsNumber,
    target: target,
  );

  final strikeRotated = delivery.rotatesOnRuns != outcome.overComplete;

  // Credited to whoever faced THIS ball — before rotation/substitution moves
  // anyone — exactly mirroring liveStrikeFigures: runs regardless of
  // legality, a legal ball counts toward balls faced.
  final creditedStriker = BatsmanFigures(
    name: pre.striker.name,
    runs: pre.striker.runs + delivery.ballRuns,
    balls: pre.striker.balls + (delivery.isLegal ? 1 : 0),
  );

  final rotatedPair = resolveStrikePreview(
    striker: creditedStriker,
    nonStriker: pre.nonStriker,
    rotated: strikeRotated,
    isWicket: isWicket,
    dismissedWasStriker: dismissedIsStriker,
    incomingName: incomingName,
  );

  final nextExtras = pre.extrasSnapshot.plus(delivery.buckets);
  final nextOverExtras = outcome.overComplete
      ? const ExtrasSnapshot()
      : pre.overExtrasSnapshot.plus(delivery.buckets);

  final nextPre = PreEventState(
    totalRuns: outcome.totalRunsAfter,
    wickets: outcome.wicketsAfter,
    legalBalls: pre.legalBalls + (delivery.isLegal ? 1 : 0),
    totalBalls: pre.totalBalls + 1,
    oversCompleted: outcome.oversCompletedAfter,
    striker: rotatedPair.striker,
    nonStriker: rotatedPair.nonStriker,
    // Cleared on over completion, exactly like the server's
    // Inning.currentBowlerId — a delivery refuses to apply without one.
    currentBowlerName: outcome.overComplete ? null : pre.currentBowlerName,
    overTotalRuns: outcome.overComplete
        ? 0
        : pre.overTotalRuns + delivery.teamRuns,
    overLegalDeliveries: outcome.overComplete
        ? 0
        : pre.overLegalDeliveries + (delivery.isLegal ? 1 : 0),
    extrasSnapshot: nextExtras,
    overExtrasSnapshot: nextOverExtras,
  );

  final rotatedOnRuns = strikeRotated != outcome.overComplete;

  final strike = Strike(
    strikerName: rotatedPair.striker.name,
    strikerRuns: rotatedPair.striker.runs,
    strikerBalls: rotatedPair.striker.balls,
    nonStrikerName: rotatedPair.nonStriker.name,
    nonStrikerRuns: rotatedPair.nonStriker.runs,
    nonStrikerBalls: rotatedPair.nonStriker.balls,
    rotated: strikeRotated,
    rotationReason: rotatedOnRuns == outcome.overComplete
        ? null
        : (rotatedOnRuns ? 'odd_runs' : 'over_end'),
  );

  final wicket = isWicket
      ? Wicket(
          type: wicketType,
          dismissedPlayerName: dismissedName,
          incomingBatsmanName: incomingName,
        )
      : null;

  final inningsTotals = InningsTotals(
    totalRuns: nextPre.totalRuns,
    wickets: nextPre.wickets,
    legalBalls: nextPre.legalBalls,
    totalBalls: nextPre.totalBalls,
    oversCompleted: nextPre.oversCompleted,
    extras: ExtrasBreakdown(
      wides: nextExtras.wides,
      noBalls: nextExtras.noBalls,
      byes: nextExtras.byes,
      legByes: nextExtras.legByes,
    ),
  );

  return BallOutcomePreview(
    strike: strike,
    wicket: wicket,
    inningsTotals: inningsTotals,
    overComplete: outcome.overComplete,
    newBowlerRequired: outcome.newBowlerRequired,
    inningsComplete: outcome.inningsComplete,
    bowlerJustBowled: outcome.overComplete ? pre.currentBowlerName : null,
    completionReason: outcome.completionReason,
    nextPreEventState: nextPre,
  );
}
