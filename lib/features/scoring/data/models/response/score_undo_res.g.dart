// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_undo_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UndoneBallRef _$UndoneBallRefFromJson(Map<String, dynamic> json) =>
    UndoneBallRef(
      ballEventId: json['ballEventId'] as String?,
      overNumber: (json['overNumber'] as num?)?.toInt(),
      ballNumber: (json['ballNumber'] as num?)?.toInt(),
      absoluteBallSeq: (json['absoluteBallSeq'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UndoneBallRefToJson(UndoneBallRef instance) =>
    <String, dynamic>{
      'ballEventId': instance.ballEventId,
      'overNumber': instance.overNumber,
      'ballNumber': instance.ballNumber,
      'absoluteBallSeq': instance.absoluteBallSeq,
    };

ScoreUndoRes _$ScoreUndoResFromJson(Map<String, dynamic> json) => ScoreUndoRes(
  matchId: json['matchId'] as String?,
  inningsId: json['inningsId'] as String?,
  inningsNumber: (json['inningsNumber'] as num?)?.toInt(),
  totalRuns: (json['totalRuns'] as num).toInt(),
  wickets: (json['wickets'] as num).toInt(),
  overs: json['overs'] as String,
  extras: ExtrasBreakdown.fromJson(json['extras'] as Map<String, dynamic>),
  strike: json['strike'] == null
      ? null
      : Strike.fromJson(json['strike'] as Map<String, dynamic>),
  bowler: json['bowler'] == null
      ? null
      : BowlerState.fromJson(json['bowler'] as Map<String, dynamic>),
  undoneBall: json['undoneBall'] == null
      ? null
      : UndoneBallRef.fromJson(json['undoneBall'] as Map<String, dynamic>),
  overReopened: json['overReopened'] as bool? ?? false,
  inningsReopened: json['inningsReopened'] as bool? ?? false,
);

Map<String, dynamic> _$ScoreUndoResToJson(ScoreUndoRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsId': instance.inningsId,
      'inningsNumber': instance.inningsNumber,
      'totalRuns': instance.totalRuns,
      'wickets': instance.wickets,
      'overs': instance.overs,
      'extras': instance.extras.toJson(),
      'strike': instance.strike?.toJson(),
      'bowler': instance.bowler?.toJson(),
      'undoneBall': instance.undoneBall?.toJson(),
      'overReopened': instance.overReopened,
      'inningsReopened': instance.inningsReopened,
    };
