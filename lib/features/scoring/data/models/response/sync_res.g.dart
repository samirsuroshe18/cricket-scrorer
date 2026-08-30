// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncState _$SyncStateFromJson(Map<String, dynamic> json) => SyncState(
  strike: json['strike'] == null
      ? null
      : Strike.fromJson(json['strike'] as Map<String, dynamic>),
  bowler: json['bowler'] == null
      ? null
      : BowlerState.fromJson(json['bowler'] as Map<String, dynamic>),
  target: (json['target'] as num?)?.toInt(),
  inningsTotals: InningsTotals.fromJson(
    json['inningsTotals'] as Map<String, dynamic>,
  ),
  overs: json['overs'] as String,
  inningsComplete: json['inningsComplete'] as bool? ?? false,
  canUndo: json['canUndo'] as bool? ?? false,
);

Map<String, dynamic> _$SyncStateToJson(SyncState instance) => <String, dynamic>{
  'strike': instance.strike?.toJson(),
  'bowler': instance.bowler?.toJson(),
  'target': instance.target,
  'inningsTotals': instance.inningsTotals.toJson(),
  'overs': instance.overs,
  'inningsComplete': instance.inningsComplete,
  'canUndo': instance.canUndo,
};

SyncRes _$SyncResFromJson(Map<String, dynamic> json) => SyncRes(
  matchId: json['matchId'] as String,
  inningsId: json['inningsId'] as String,
  inningsNumber: (json['inningsNumber'] as num).toInt(),
  syncStatus: json['syncStatus'] as String,
  baseAbsoluteBallSeq: (json['baseAbsoluteBallSeq'] as num).toInt(),
  absoluteBallSeq: (json['absoluteBallSeq'] as num).toInt(),
  appliedCount: (json['appliedCount'] as num?)?.toInt() ?? 0,
  skippedCount: (json['skippedCount'] as num?)?.toInt() ?? 0,
  failedAt: (json['failedAt'] as num?)?.toInt(),
  failedCode: json['failedCode'] as String?,
  lastBallEventId: json['lastBallEventId'] as String?,
  state: SyncState.fromJson(json['state'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SyncResToJson(SyncRes instance) => <String, dynamic>{
  'matchId': instance.matchId,
  'inningsId': instance.inningsId,
  'inningsNumber': instance.inningsNumber,
  'syncStatus': instance.syncStatus,
  'baseAbsoluteBallSeq': instance.baseAbsoluteBallSeq,
  'absoluteBallSeq': instance.absoluteBallSeq,
  'appliedCount': instance.appliedCount,
  'skippedCount': instance.skippedCount,
  'failedAt': instance.failedAt,
  'failedCode': instance.failedCode,
  'lastBallEventId': instance.lastBallEventId,
  'state': instance.state.toJson(),
};
