// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_score_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LastBall _$LastBallFromJson(Map<String, dynamic> json) => LastBall(
  runs: (json['runs'] as num).toInt(),
  extras: (json['extras'] as num?)?.toInt() ?? 0,
  extraType: json['extraType'] as String?,
  runsFrom: json['runsFrom'] as String?,
  isLegal: json['isLegal'] as bool? ?? true,
  overNumber: (json['overNumber'] as num).toInt(),
  ballNumber: (json['ballNumber'] as num).toInt(),
  absoluteBallSeq: (json['absoluteBallSeq'] as num).toInt(),
);

Map<String, dynamic> _$LastBallToJson(LastBall instance) => <String, dynamic>{
  'runs': instance.runs,
  'extras': instance.extras,
  'extraType': instance.extraType,
  'runsFrom': instance.runsFrom,
  'isLegal': instance.isLegal,
  'overNumber': instance.overNumber,
  'ballNumber': instance.ballNumber,
  'absoluteBallSeq': instance.absoluteBallSeq,
};

LiveScoreRes _$LiveScoreResFromJson(Map<String, dynamic> json) => LiveScoreRes(
  matchId: json['matchId'] as String,
  inningsId: json['inningsId'] as String?,
  inningsNumber: (json['inningsNumber'] as num).toInt(),
  totalRuns: (json['totalRuns'] as num).toInt(),
  wickets: (json['wickets'] as num).toInt(),
  overs: json['overs'] as String,
  extras: json['extras'] == null
      ? null
      : ExtrasBreakdown.fromJson(json['extras'] as Map<String, dynamic>),
  lastBall: json['lastBall'] == null
      ? null
      : LastBall.fromJson(json['lastBall'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LiveScoreResToJson(LiveScoreRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsId': instance.inningsId,
      'inningsNumber': instance.inningsNumber,
      'totalRuns': instance.totalRuns,
      'wickets': instance.wickets,
      'overs': instance.overs,
      'extras': instance.extras?.toJson(),
      'lastBall': instance.lastBall?.toJson(),
    };
