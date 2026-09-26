// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadPlayerRes _$SquadPlayerResFromJson(Map<String, dynamic> json) =>
    SquadPlayerRes(
      playerId: json['playerId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$SquadPlayerResToJson(SquadPlayerRes instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'name': instance.name,
      'role': instance.role,
    };

SquadRes _$SquadResFromJson(Map<String, dynamic> json) => SquadRes(
  side: json['side'] as String,
  players: (json['players'] as List<dynamic>)
      .map((e) => SquadPlayerRes.fromJson(e as Map<String, dynamic>))
      .toList(),
  captainId: json['captainId'] as String?,
  viceCaptainId: json['viceCaptainId'] as String?,
  keeperId: json['keeperId'] as String?,
);

Map<String, dynamic> _$SquadResToJson(SquadRes instance) => <String, dynamic>{
  'side': instance.side,
  'players': instance.players.map((e) => e.toJson()).toList(),
  'captainId': instance.captainId,
  'viceCaptainId': instance.viceCaptainId,
  'keeperId': instance.keeperId,
};
