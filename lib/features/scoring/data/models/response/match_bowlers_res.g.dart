// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_bowlers_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchBowlersRes _$MatchBowlersResFromJson(Map<String, dynamic> json) =>
    MatchBowlersRes(
      bowlers: (json['bowlers'] as List<dynamic>)
          .map((e) => BowlerFigureRes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MatchBowlersResToJson(MatchBowlersRes instance) =>
    <String, dynamic>{
      'bowlers': instance.bowlers.map((e) => e.toJson()).toList(),
    };

BowlerFigureRes _$BowlerFigureResFromJson(Map<String, dynamic> json) =>
    BowlerFigureRes(
      id: json['id'] as String,
      name: json['name'] as String,
      legalDeliveries: (json['legalDeliveries'] as num).toInt(),
      runsConceded: (json['runsConceded'] as num).toInt(),
      wickets: (json['wickets'] as num).toInt(),
    );

Map<String, dynamic> _$BowlerFigureResToJson(BowlerFigureRes instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'legalDeliveries': instance.legalDeliveries,
      'runsConceded': instance.runsConceded,
      'wickets': instance.wickets,
    };
