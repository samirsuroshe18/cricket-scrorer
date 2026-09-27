// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_innings_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartInningsReq _$StartInningsReqFromJson(Map<String, dynamic> json) =>
    StartInningsReq(
      strikerName: json['strikerName'] as String,
      strikerId: json['strikerId'] as String?,
      nonStrikerName: json['nonStrikerName'] as String,
      nonStrikerId: json['nonStrikerId'] as String?,
      bowlerName: json['bowlerName'] as String,
      bowlerId: json['bowlerId'] as String?,
    );

Map<String, dynamic> _$StartInningsReqToJson(StartInningsReq instance) =>
    <String, dynamic>{
      'strikerName': instance.strikerName,
      'strikerId': ?instance.strikerId,
      'nonStrikerName': instance.nonStrikerName,
      'nonStrikerId': ?instance.nonStrikerId,
      'bowlerName': instance.bowlerName,
      'bowlerId': ?instance.bowlerId,
    };
