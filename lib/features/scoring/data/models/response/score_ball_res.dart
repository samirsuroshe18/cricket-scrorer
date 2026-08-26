import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/wicket.dart';
import 'package:json_annotation/json_annotation.dart';

part 'score_ball_res.g.dart';

@JsonSerializable()
class ExtrasBreakdown {
  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;

  ExtrasBreakdown({
    this.wides = 0,
    this.noBalls = 0,
    this.byes = 0,
    this.legByes = 0,
  });

  int get total => wides + noBalls + byes + legByes;

  factory ExtrasBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ExtrasBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$ExtrasBreakdownToJson(this);
}

@JsonSerializable(explicitToJson: true)
class InningsTotals {
  final int totalRuns;
  final int wickets;
  final int legalBalls;
  final int totalBalls;
  final int oversCompleted;
  final ExtrasBreakdown extras;

  InningsTotals({
    required this.totalRuns,
    required this.wickets,
    required this.legalBalls,
    required this.totalBalls,
    required this.oversCompleted,
    required this.extras,
  });

  factory InningsTotals.fromJson(Map<String, dynamic> json) =>
      _$InningsTotalsFromJson(json);

  Map<String, dynamic> toJson() => _$InningsTotalsToJson(this);
}

/// The over just finished, or null on any delivery that did not end one.
///
/// [overNumber] is nullable because this object serves two payloads: the REST
/// `score-ball` response nests it here, while the `over:complete` socket event
/// carries the over number at its own top level and omits it from this block.
@JsonSerializable(explicitToJson: true)
class OverSummary {
  final int? overNumber;
  final int legalDeliveries;
  final int totalRuns;
  final int wickets;
  final ExtrasBreakdown? extras;
  final String? bowlerId;
  final String? bowlerName;

  OverSummary({
    this.overNumber,
    this.legalDeliveries = 0,
    this.totalRuns = 0,
    this.wickets = 0,
    this.extras,
    this.bowlerId,
    this.bowlerName,
  });

  factory OverSummary.fromJson(Map<String, dynamic> json) =>
      _$OverSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$OverSummaryToJson(this);
}

/// Present **iff** a bowler is owed for the over about to start. Null when the
/// over didn't end, and null when the innings ended on that ball — so the
/// console branches on presence and never has to recombine `overComplete` with
/// `inningsComplete` to decide whether to prompt.
///
/// The excluded bowler is a *rule handed down by the server*, deliberately
/// separate from [OverSummary.bowlerId], which is a fact about the over just
/// bowled. The picker greys whoever this names; it does not work out for itself
/// who bowled last.
@JsonSerializable()
class NextBowler {
  final String? excludedBowlerId;
  final String? excludedBowlerName;

  NextBowler({this.excludedBowlerId, this.excludedBowlerName});

  factory NextBowler.fromJson(Map<String, dynamic> json) =>
      _$NextBowlerFromJson(json);

  Map<String, dynamic> toJson() => _$NextBowlerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ScoreBallRes {
  final String ballEventId;
  final String matchId;
  final String inningsId;
  final int overNumber;
  final int ballNumber;
  final int absoluteBallSeq;

  /// Runs credited to the batsman (0 for wides, byes and leg-byes).
  final int runs;

  /// Runs credited to the team without batsman credit — penalty + any
  /// byes/leg-byes/wide runs. `runs + extras` is what the delivery added.
  final int extras;
  final String? extraType;
  final String? runsFrom;
  final bool isLegal;

  /// True when this delivery completed the over. Reported separately from
  /// [Strike.rotated] because it stays true in the case where odd runs and the
  /// over end cancel each other out — a new-bowler prompt needs to fire even
  /// though the strike did not change.
  final bool overComplete;

  /// The over this delivery completed, or null. Non-null exactly when
  /// [overComplete] is true.
  final OverSummary? over;

  /// Non-null exactly when a bowler must be chosen before the next delivery.
  /// See [NextBowler].
  final NextBowler? nextBowler;

  /// True once the innings is over — the 10th wicket, or the last ball of the
  /// last over. The server rejects further deliveries either way.
  final bool inningsComplete;

  /// [inningsComplete] narrowed to "and it was innings 2" — the match ending
  /// has no separate detector. The primary trigger for navigating to the
  /// result screen; `match:complete` on the socket is the recovery path for
  /// when this ack is lost on patchy signal, same relationship as
  /// [overComplete]/`over:complete`.
  final bool matchComplete;

  /// The dismissal, or null on an ordinary delivery.
  final Wicket? wicket;

  /// Who is on strike *after* this delivery. Server-computed; never derived
  /// client-side.
  final Strike? strike;

  final InningsTotals inningsTotals;

  ScoreBallRes({
    required this.ballEventId,
    required this.matchId,
    required this.inningsId,
    required this.overNumber,
    required this.ballNumber,
    required this.absoluteBallSeq,
    required this.runs,
    this.extras = 0,
    this.extraType,
    this.runsFrom,
    this.isLegal = true,
    this.overComplete = false,
    this.over,
    this.nextBowler,
    this.inningsComplete = false,
    this.matchComplete = false,
    this.wicket,
    this.strike,
    required this.inningsTotals,
  });

  factory ScoreBallRes.fromJson(Map<String, dynamic> json) =>
      _$ScoreBallResFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreBallResToJson(this);
}
