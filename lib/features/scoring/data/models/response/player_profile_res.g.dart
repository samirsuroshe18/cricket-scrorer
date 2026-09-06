// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_profile_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerProfileRes _$PlayerProfileResFromJson(Map<String, dynamic> json) =>
    PlayerProfileRes(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      role: json['role'] as String,
      jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
      bio: json['bio'] as String?,
      battingStyle: json['battingStyle'] as String?,
      bowlingStyle: json['bowlingStyle'] as String?,
    );

Map<String, dynamic> _$PlayerProfileResToJson(PlayerProfileRes instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'role': instance.role,
      'jerseyNumber': instance.jerseyNumber,
      'bio': instance.bio,
      'battingStyle': instance.battingStyle,
      'bowlingStyle': instance.bowlingStyle,
    };
