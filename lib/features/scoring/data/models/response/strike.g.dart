// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Strike _$StrikeFromJson(Map<String, dynamic> json) => Strike(
  strikerId: json['strikerId'] as String?,
  strikerName: json['strikerName'] as String?,
  nonStrikerId: json['nonStrikerId'] as String?,
  nonStrikerName: json['nonStrikerName'] as String?,
  rotated: json['rotated'] as bool?,
  rotationReason: json['rotationReason'] as String?,
);

Map<String, dynamic> _$StrikeToJson(Strike instance) => <String, dynamic>{
  'strikerId': instance.strikerId,
  'strikerName': instance.strikerName,
  'nonStrikerId': instance.nonStrikerId,
  'nonStrikerName': instance.nonStrikerName,
  'rotated': instance.rotated,
  'rotationReason': instance.rotationReason,
};
