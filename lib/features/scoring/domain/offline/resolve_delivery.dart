import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';

/// Client-side mirror of the backend's `resolveDelivery.js`, ported line for
/// line so the two can never disagree about the arithmetic. Used only to
/// preview a delivery while offline — see `ball_outcome_preview.dart`. The
/// server remains the sole authority the instant it can be reached again.
///
/// Invariants (matching the server's own, verified there against
/// tests/resolveDelivery.test.js):
///   teamRuns === ballRuns + ballExtras
///   sum(buckets) === ballExtras
///   rotatesOnRuns === (runs % 2 == 1) — independent of extraType/runsFrom
class DeliveryOutcome {
  final int ballRuns;
  final int ballExtras;
  final int teamRuns;
  final bool isLegal;
  final bool rotatesOnRuns;
  final ExtrasSnapshot buckets;

  const DeliveryOutcome({
    required this.ballRuns,
    required this.ballExtras,
    required this.teamRuns,
    required this.isLegal,
    required this.rotatesOnRuns,
    required this.buckets,
  });
}

DeliveryOutcome resolveDelivery({
  required int runs,
  String? extraType,
  String runsFrom = RunsFrom.bat,
}) {
  final penalty = extraType != null ? 1 : 0;
  final isLegal = extraType == null;
  // A wide is never credited to the batsman even though runs may have been run.
  final creditToBat = extraType != ExtraType.wide && runsFrom == RunsFrom.bat;

  final ballRuns = creditToBat ? runs : 0;
  final ballExtras = penalty + (creditToBat ? 0 : runs);

  // Strike follows the runs the batsmen actually ran or hit, whoever they are
  // credited to — so odd byes, leg-byes and runs off a wide all rotate. It is
  // `runs`, not `ballRuns`: the automatic wide/no-ball penalty is never run
  // between the wickets, so it never changes the strike.
  final rotatesOnRuns = runs % 2 == 1;

  var wides = 0;
  var noBalls = 0;
  var byes = 0;
  var legByes = 0;

  if (extraType == ExtraType.wide) {
    // Law 22: every run from a wide is debited as a wide, however it was run.
    wides = penalty + runs;
  } else {
    if (extraType == ExtraType.noBall) noBalls = penalty;
    if (runsFrom == RunsFrom.bye) byes = runs;
    if (runsFrom == RunsFrom.legBye) legByes = runs;
  }

  return DeliveryOutcome(
    ballRuns: ballRuns,
    ballExtras: ballExtras,
    teamRuns: ballRuns + ballExtras,
    isLegal: isLegal,
    rotatesOnRuns: rotatesOnRuns,
    buckets: ExtrasSnapshot(
      wides: wides,
      noBalls: noBalls,
      byes: byes,
      legByes: legByes,
    ),
  );
}
