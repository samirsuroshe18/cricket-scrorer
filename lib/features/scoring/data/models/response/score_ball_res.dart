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
    required this.inningsTotals,
  });

  factory ScoreBallRes.fromJson(Map<String, dynamic> json) =>
      _$ScoreBallResFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreBallResToJson(this);
}
