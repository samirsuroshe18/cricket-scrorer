// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_innings_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartInningsRes _$StartInningsResFromJson(Map<String, dynamic> json) =>
    StartInningsRes(
      matchId: json['matchId'] as String,
      inningsId: json['inningsId'] as String,
      inningsNumber: (json['inningsNumber'] as num).toInt(),
      battingTeam: json['battingTeam'] as String,
      bowlingTeam: json['bowlingTeam'] as String,
      strike: Strike.fromJson(json['strike'] as Map<String, dynamic>),
      bowler: json['bowler'] == null
          ? null
          : Bowler.fromJson(json['bowler'] as Map<String, dynamic>),
      inningsTotals: InningsTotals.fromJson(
        json['inningsTotals'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$StartInningsResToJson(StartInningsRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsId': instance.inningsId,
      'inningsNumber': instance.inningsNumber,
      'battingTeam': instance.battingTeam,
      'bowlingTeam': instance.bowlingTeam,
      'strike': instance.strike.toJson(),
      'bowler': instance.bowler?.toJson(),
      'inningsTotals': instance.inningsTotals.toJson(),
    };
