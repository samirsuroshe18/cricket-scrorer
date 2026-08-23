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
      'inningsTotals': instance.inningsTotals.toJson(),
    };
