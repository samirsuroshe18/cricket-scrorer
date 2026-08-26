// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Strike _$StrikeFromJson(Map<String, dynamic> json) => Strike(
  strikerId: json['strikerId'] as String?,
  strikerName: json['strikerName'] as String?,
  strikerRuns: (json['strikerRuns'] as num?)?.toInt() ?? 0,
  strikerBalls: (json['strikerBalls'] as num?)?.toInt() ?? 0,
  nonStrikerId: json['nonStrikerId'] as String?,
  nonStrikerName: json['nonStrikerName'] as String?,
  nonStrikerRuns: (json['nonStrikerRuns'] as num?)?.toInt() ?? 0,
  nonStrikerBalls: (json['nonStrikerBalls'] as num?)?.toInt() ?? 0,
  rotated: json['rotated'] as bool?,
  rotationReason: json['rotationReason'] as String?,
);

Map<String, dynamic> _$StrikeToJson(Strike instance) => <String, dynamic>{
  'strikerId': instance.strikerId,
  'strikerName': instance.strikerName,
  'strikerRuns': instance.strikerRuns,
  'strikerBalls': instance.strikerBalls,
  'nonStrikerId': instance.nonStrikerId,
  'nonStrikerName': instance.nonStrikerName,
  'nonStrikerRuns': instance.nonStrikerRuns,
  'nonStrikerBalls': instance.nonStrikerBalls,
  'rotated': instance.rotated,
  'rotationReason': instance.rotationReason,
};
