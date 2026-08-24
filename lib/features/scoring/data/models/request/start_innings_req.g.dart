// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_innings_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartInningsReq _$StartInningsReqFromJson(Map<String, dynamic> json) =>
    StartInningsReq(
      strikerName: json['strikerName'] as String,
      nonStrikerName: json['nonStrikerName'] as String,
      bowlerName: json['bowlerName'] as String,
    );

Map<String, dynamic> _$StartInningsReqToJson(StartInningsReq instance) =>
    <String, dynamic>{
      'strikerName': instance.strikerName,
      'nonStrikerName': instance.nonStrikerName,
      'bowlerName': instance.bowlerName,
    };
