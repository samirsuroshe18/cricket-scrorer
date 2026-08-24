// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'over_complete_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverCompleteRes _$OverCompleteResFromJson(Map<String, dynamic> json) =>
    OverCompleteRes(
      matchId: json['matchId'] as String,
      inningsId: json['inningsId'] as String?,
      inningsNumber: (json['inningsNumber'] as num).toInt(),
      overNumber: (json['overNumber'] as num).toInt(),
      over: OverSummary.fromJson(json['over'] as Map<String, dynamic>),
      strike: json['strike'] == null
          ? null
          : Strike.fromJson(json['strike'] as Map<String, dynamic>),
      inningsComplete: json['inningsComplete'] as bool? ?? false,
      newBowlerRequired: json['newBowlerRequired'] as bool? ?? false,
    );

Map<String, dynamic> _$OverCompleteResToJson(OverCompleteRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsId': instance.inningsId,
      'inningsNumber': instance.inningsNumber,
      'overNumber': instance.overNumber,
      'over': instance.over.toJson(),
      'strike': instance.strike?.toJson(),
      'inningsComplete': instance.inningsComplete,
      'newBowlerRequired': instance.newBowlerRequired,
    };
