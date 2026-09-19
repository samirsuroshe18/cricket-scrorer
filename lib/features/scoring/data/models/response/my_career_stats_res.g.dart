// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_career_stats_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyCareerStatsRes _$MyCareerStatsResFromJson(Map<String, dynamic> json) =>
    MyCareerStatsRes(
      linkedPlayerCount: (json['linkedPlayerCount'] as num).toInt(),
      matchesPlayed: (json['matchesPlayed'] as num).toInt(),
      runs: (json['runs'] as num).toInt(),
      wickets: (json['wickets'] as num).toInt(),
    );

Map<String, dynamic> _$MyCareerStatsResToJson(MyCareerStatsRes instance) =>
    <String, dynamic>{
      'linkedPlayerCount': instance.linkedPlayerCount,
      'matchesPlayed': instance.matchesPlayed,
      'runs': instance.runs,
      'wickets': instance.wickets,
    };
