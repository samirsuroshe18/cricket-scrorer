// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_squad_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadPlayerReq _$SquadPlayerReqFromJson(Map<String, dynamic> json) =>
    SquadPlayerReq(
      playerId: json['playerId'] as String?,
      name: json['name'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$SquadPlayerReqToJson(SquadPlayerReq instance) =>
    <String, dynamic>{
      'playerId': ?instance.playerId,
      'name': instance.name,
      'role': ?instance.role,
    };

SaveSquadReq _$SaveSquadReqFromJson(Map<String, dynamic> json) => SaveSquadReq(
  side: json['side'] as String,
  players: (json['players'] as List<dynamic>)
      .map((e) => SquadPlayerReq.fromJson(e as Map<String, dynamic>))
      .toList(),
  captain: json['captain'] as String?,
  viceCaptain: json['viceCaptain'] as String?,
  keeper: json['keeper'] as String?,
);

Map<String, dynamic> _$SaveSquadReqToJson(SaveSquadReq instance) =>
    <String, dynamic>{
      'players': instance.players.map((e) => e.toJson()).toList(),
      'captain': ?instance.captain,
      'viceCaptain': ?instance.viceCaptain,
      'keeper': ?instance.keeper,
    };
