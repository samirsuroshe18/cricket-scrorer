// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wicket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wicket _$WicketFromJson(Map<String, dynamic> json) => Wicket(
  type: json['type'] as String?,
  dismissedPlayerId: json['dismissedPlayerId'] as String?,
  dismissedPlayerName: json['dismissedPlayerName'] as String?,
  incomingBatsmanId: json['incomingBatsmanId'] as String?,
  incomingBatsmanName: json['incomingBatsmanName'] as String?,
);

Map<String, dynamic> _$WicketToJson(Wicket instance) => <String, dynamic>{
  'type': instance.type,
  'dismissedPlayerId': instance.dismissedPlayerId,
  'dismissedPlayerName': instance.dismissedPlayerName,
  'incomingBatsmanId': instance.incomingBatsmanId,
  'incomingBatsmanName': instance.incomingBatsmanName,
};
