// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_bowler_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectBowlerRes _$SelectBowlerResFromJson(Map<String, dynamic> json) =>
    SelectBowlerRes(
      matchId: json['matchId'] as String,
      inningsId: json['inningsId'] as String,
      overNumber: (json['overNumber'] as num).toInt(),
      bowler: Bowler.fromJson(json['bowler'] as Map<String, dynamic>),
      previousBowler: json['previousBowler'] == null
          ? null
          : Bowler.fromJson(json['previousBowler'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SelectBowlerResToJson(SelectBowlerRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsId': instance.inningsId,
      'overNumber': instance.overNumber,
      'bowler': instance.bowler.toJson(),
      'previousBowler': instance.previousBowler?.toJson(),
    };
