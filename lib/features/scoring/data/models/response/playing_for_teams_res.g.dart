// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playing_for_teams_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayingForTeam _$PlayingForTeamFromJson(Map<String, dynamic> json) =>
    PlayingForTeam(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      myPlayerName: json['myPlayerName'] as String,
    );

Map<String, dynamic> _$PlayingForTeamToJson(PlayingForTeam instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'shortName': instance.shortName,
      'logoUrl': instance.logoUrl,
      'myPlayerName': instance.myPlayerName,
    };

PlayingForTeamsRes _$PlayingForTeamsResFromJson(Map<String, dynamic> json) =>
    PlayingForTeamsRes(
      teams: (json['teams'] as List<dynamic>)
          .map((e) => PlayingForTeam.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$PlayingForTeamsResToJson(PlayingForTeamsRes instance) =>
    <String, dynamic>{
      'teams': instance.teams.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
    };
