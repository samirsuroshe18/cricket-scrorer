// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_match_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMatchReq _$CreateMatchReqFromJson(Map<String, dynamic> json) =>
    CreateMatchReq(
      teamAName: json['teamAName'] as String,
      teamBName: json['teamBName'] as String,
      totalOvers: (json['totalOvers'] as num).toInt(),
      tossWinner: json['tossWinner'] as String?,
      tossDecision: json['tossDecision'] as String?,
      teamAId: json['teamAId'] as String?,
      teamBId: json['teamBId'] as String?,
    );

Map<String, dynamic> _$CreateMatchReqToJson(CreateMatchReq instance) =>
    <String, dynamic>{
      'teamAName': instance.teamAName,
      'teamBName': instance.teamBName,
      'totalOvers': instance.totalOvers,
      'tossWinner': instance.tossWinner,
      'tossDecision': instance.tossDecision,
      'teamAId': instance.teamAId,
      'teamBId': instance.teamBId,
    };
