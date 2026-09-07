// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pool_entry_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoolEntryRes _$PoolEntryResFromJson(Map<String, dynamic> json) =>
    PoolEntryRes(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      role: json['role'] as String,
      jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
      battingStyle: json['battingStyle'] as String?,
      bowlingStyle: json['bowlingStyle'] as String?,
      bio: json['bio'] as String?,
      basePrice: (json['basePrice'] as num).toInt(),
      registeredAt: json['registeredAt'] as String,
    );

Map<String, dynamic> _$PoolEntryResToJson(PoolEntryRes instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'role': instance.role,
      'jerseyNumber': instance.jerseyNumber,
      'battingStyle': instance.battingStyle,
      'bowlingStyle': instance.bowlingStyle,
      'bio': instance.bio,
      'basePrice': instance.basePrice,
      'registeredAt': instance.registeredAt,
    };
