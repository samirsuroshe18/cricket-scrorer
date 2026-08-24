// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_ball_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtrasBreakdown _$ExtrasBreakdownFromJson(Map<String, dynamic> json) =>
    ExtrasBreakdown(
      wides: (json['wides'] as num?)?.toInt() ?? 0,
      noBalls: (json['noBalls'] as num?)?.toInt() ?? 0,
      byes: (json['byes'] as num?)?.toInt() ?? 0,
      legByes: (json['legByes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ExtrasBreakdownToJson(ExtrasBreakdown instance) =>
    <String, dynamic>{
      'wides': instance.wides,
      'noBalls': instance.noBalls,
      'byes': instance.byes,
      'legByes': instance.legByes,
    };

InningsTotals _$InningsTotalsFromJson(Map<String, dynamic> json) =>
    InningsTotals(
      totalRuns: (json['totalRuns'] as num).toInt(),
      wickets: (json['wickets'] as num).toInt(),
      legalBalls: (json['legalBalls'] as num).toInt(),
      totalBalls: (json['totalBalls'] as num).toInt(),
      oversCompleted: (json['oversCompleted'] as num).toInt(),
      extras: ExtrasBreakdown.fromJson(json['extras'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InningsTotalsToJson(InningsTotals instance) =>
    <String, dynamic>{
      'totalRuns': instance.totalRuns,
      'wickets': instance.wickets,
      'legalBalls': instance.legalBalls,
      'totalBalls': instance.totalBalls,
      'oversCompleted': instance.oversCompleted,
      'extras': instance.extras.toJson(),
    };

OverSummary _$OverSummaryFromJson(Map<String, dynamic> json) => OverSummary(
  overNumber: (json['overNumber'] as num?)?.toInt(),
  legalDeliveries: (json['legalDeliveries'] as num?)?.toInt() ?? 0,
  totalRuns: (json['totalRuns'] as num?)?.toInt() ?? 0,
  wickets: (json['wickets'] as num?)?.toInt() ?? 0,
  extras: json['extras'] == null
      ? null
      : ExtrasBreakdown.fromJson(json['extras'] as Map<String, dynamic>),
  bowlerId: json['bowlerId'] as String?,
  bowlerName: json['bowlerName'] as String?,
);

Map<String, dynamic> _$OverSummaryToJson(OverSummary instance) =>
    <String, dynamic>{
      'overNumber': instance.overNumber,
      'legalDeliveries': instance.legalDeliveries,
      'totalRuns': instance.totalRuns,
      'wickets': instance.wickets,
      'extras': instance.extras?.toJson(),
      'bowlerId': instance.bowlerId,
      'bowlerName': instance.bowlerName,
    };

NextBowler _$NextBowlerFromJson(Map<String, dynamic> json) => NextBowler(
  excludedBowlerId: json['excludedBowlerId'] as String?,
  excludedBowlerName: json['excludedBowlerName'] as String?,
);

Map<String, dynamic> _$NextBowlerToJson(NextBowler instance) =>
    <String, dynamic>{
      'excludedBowlerId': instance.excludedBowlerId,
      'excludedBowlerName': instance.excludedBowlerName,
    };

ScoreBallRes _$ScoreBallResFromJson(Map<String, dynamic> json) => ScoreBallRes(
  ballEventId: json['ballEventId'] as String,
  matchId: json['matchId'] as String,
  inningsId: json['inningsId'] as String,
  overNumber: (json['overNumber'] as num).toInt(),
  ballNumber: (json['ballNumber'] as num).toInt(),
  absoluteBallSeq: (json['absoluteBallSeq'] as num).toInt(),
  runs: (json['runs'] as num).toInt(),
  extras: (json['extras'] as num?)?.toInt() ?? 0,
  extraType: json['extraType'] as String?,
  runsFrom: json['runsFrom'] as String?,
  isLegal: json['isLegal'] as bool? ?? true,
  overComplete: json['overComplete'] as bool? ?? false,
  over: json['over'] == null
      ? null
      : OverSummary.fromJson(json['over'] as Map<String, dynamic>),
  nextBowler: json['nextBowler'] == null
      ? null
      : NextBowler.fromJson(json['nextBowler'] as Map<String, dynamic>),
  inningsComplete: json['inningsComplete'] as bool? ?? false,
  wicket: json['wicket'] == null
      ? null
      : Wicket.fromJson(json['wicket'] as Map<String, dynamic>),
  strike: json['strike'] == null
      ? null
      : Strike.fromJson(json['strike'] as Map<String, dynamic>),
  inningsTotals: InningsTotals.fromJson(
    json['inningsTotals'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ScoreBallResToJson(ScoreBallRes instance) =>
    <String, dynamic>{
      'ballEventId': instance.ballEventId,
      'matchId': instance.matchId,
      'inningsId': instance.inningsId,
      'overNumber': instance.overNumber,
      'ballNumber': instance.ballNumber,
      'absoluteBallSeq': instance.absoluteBallSeq,
      'runs': instance.runs,
      'extras': instance.extras,
      'extraType': instance.extraType,
      'runsFrom': instance.runsFrom,
      'isLegal': instance.isLegal,
      'overComplete': instance.overComplete,
      'over': instance.over?.toJson(),
      'nextBowler': instance.nextBowler?.toJson(),
      'inningsComplete': instance.inningsComplete,
      'wicket': instance.wicket?.toJson(),
      'strike': instance.strike?.toJson(),
      'inningsTotals': instance.inningsTotals.toJson(),
    };
