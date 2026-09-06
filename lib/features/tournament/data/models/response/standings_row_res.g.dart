// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standings_row_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StandingsRowRes _$StandingsRowResFromJson(Map<String, dynamic> json) =>
    StandingsRowRes(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      played: (json['played'] as num).toInt(),
      won: (json['won'] as num).toInt(),
      lost: (json['lost'] as num).toInt(),
      tied: (json['tied'] as num).toInt(),
      noResult: (json['noResult'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      nrr: (json['nrr'] as num).toDouble(),
    );

Map<String, dynamic> _$StandingsRowResToJson(StandingsRowRes instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'played': instance.played,
      'won': instance.won,
      'lost': instance.lost,
      'tied': instance.tied,
      'noResult': instance.noResult,
      'points': instance.points,
      'nrr': instance.nrr,
    };
