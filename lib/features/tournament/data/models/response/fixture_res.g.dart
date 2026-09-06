// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixture_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixtureTeamRef _$FixtureTeamRefFromJson(Map<String, dynamic> json) =>
    FixtureTeamRef(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
    );

Map<String, dynamic> _$FixtureTeamRefToJson(FixtureTeamRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'shortName': instance.shortName,
    };

FixtureWinnerRef _$FixtureWinnerRefFromJson(Map<String, dynamic> json) =>
    FixtureWinnerRef(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$FixtureWinnerRefToJson(FixtureWinnerRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

FixtureRes _$FixtureResFromJson(Map<String, dynamic> json) => FixtureRes(
  id: json['id'] as String,
  round: (json['round'] as num).toInt(),
  order: (json['order'] as num).toInt(),
  teamA: FixtureTeamRef.fromJson(json['teamA'] as Map<String, dynamic>),
  teamB: json['teamB'] == null
      ? null
      : FixtureTeamRef.fromJson(json['teamB'] as Map<String, dynamic>),
  isBye: json['isBye'] as bool,
  status: json['status'] as String,
  winner: json['winner'] == null
      ? null
      : FixtureWinnerRef.fromJson(json['winner'] as Map<String, dynamic>),
  matchId: json['matchId'] as String?,
);

Map<String, dynamic> _$FixtureResToJson(FixtureRes instance) =>
    <String, dynamic>{
      'id': instance.id,
      'round': instance.round,
      'order': instance.order,
      'teamA': instance.teamA.toJson(),
      'teamB': instance.teamB?.toJson(),
      'isBye': instance.isBye,
      'status': instance.status,
      'winner': instance.winner?.toJson(),
      'matchId': instance.matchId,
    };
