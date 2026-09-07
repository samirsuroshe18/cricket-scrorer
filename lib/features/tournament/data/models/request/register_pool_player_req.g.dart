// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_pool_player_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterPoolPlayerReq _$RegisterPoolPlayerReqFromJson(
  Map<String, dynamic> json,
) => RegisterPoolPlayerReq(
  playerName: json['playerName'] as String?,
  playerId: json['playerId'] as String?,
  basePrice: (json['basePrice'] as num).toInt(),
);

Map<String, dynamic> _$RegisterPoolPlayerReqToJson(
  RegisterPoolPlayerReq instance,
) => <String, dynamic>{
  'playerName': ?instance.playerName,
  'playerId': ?instance.playerId,
  'basePrice': instance.basePrice,
};
