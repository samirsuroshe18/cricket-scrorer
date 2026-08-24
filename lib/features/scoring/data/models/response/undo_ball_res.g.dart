// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'undo_ball_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UndoneBall _$UndoneBallFromJson(Map<String, dynamic> json) => UndoneBall(
  ballEventId: json['ballEventId'] as String,
  overNumber: (json['overNumber'] as num).toInt(),
  ballNumber: (json['ballNumber'] as num).toInt(),
  absoluteBallSeq: (json['absoluteBallSeq'] as num).toInt(),
  runs: (json['runs'] as num?)?.toInt() ?? 0,
  extras: (json['extras'] as num?)?.toInt() ?? 0,
  extraType: json['extraType'] as String?,
  runsFrom: json['runsFrom'] as String?,
  isLegal: json['isLegal'] as bool? ?? true,
  wicket: json['wicket'] == null
      ? null
      : Wicket.fromJson(json['wicket'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UndoneBallToJson(UndoneBall instance) =>
    <String, dynamic>{
      'ballEventId': instance.ballEventId,
      'overNumber': instance.overNumber,
      'ballNumber': instance.ballNumber,
      'absoluteBallSeq': instance.absoluteBallSeq,
      'runs': instance.runs,
      'extras': instance.extras,
      'extraType': instance.extraType,
      'runsFrom': instance.runsFrom,
      'isLegal': instance.isLegal,
      'wicket': instance.wicket?.toJson(),
    };

UndoBallRes _$UndoBallResFromJson(Map<String, dynamic> json) => UndoBallRes(
  matchId: json['matchId'] as String,
  inningsId: json['inningsId'] as String,
  inningsNumber: (json['inningsNumber'] as num).toInt(),
  alreadyUndone: json['alreadyUndone'] as bool? ?? false,
  undone: json['undone'] == null
      ? null
      : UndoneBall.fromJson(json['undone'] as Map<String, dynamic>),
  overReopened: json['overReopened'] as bool? ?? false,
  overRemoved: json['overRemoved'] as bool? ?? false,
  inningsReopened: json['inningsReopened'] as bool? ?? false,
  strike: json['strike'] == null
      ? null
      : Strike.fromJson(json['strike'] as Map<String, dynamic>),
  bowler: json['bowler'] == null
      ? null
      : BowlerState.fromJson(json['bowler'] as Map<String, dynamic>),
  inningsTotals: InningsTotals.fromJson(
    json['inningsTotals'] as Map<String, dynamic>,
  ),
  overs: json['overs'] as String,
  inningsComplete: json['inningsComplete'] as bool? ?? false,
  canUndo: json['canUndo'] as bool? ?? false,
);

Map<String, dynamic> _$UndoBallResToJson(UndoBallRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsId': instance.inningsId,
      'inningsNumber': instance.inningsNumber,
      'alreadyUndone': instance.alreadyUndone,
      'undone': instance.undone?.toJson(),
      'overReopened': instance.overReopened,
      'overRemoved': instance.overRemoved,
      'inningsReopened': instance.inningsReopened,
      'strike': instance.strike?.toJson(),
      'bowler': instance.bowler?.toJson(),
      'inningsTotals': instance.inningsTotals.toJson(),
      'overs': instance.overs,
      'inningsComplete': instance.inningsComplete,
      'canUndo': instance.canUndo,
    };
