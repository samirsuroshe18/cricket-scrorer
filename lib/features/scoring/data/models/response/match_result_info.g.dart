// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_result_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchResultInfo _$MatchResultInfoFromJson(Map<String, dynamic> json) =>
    MatchResultInfo(
      winner: json['winner'] as String,
      marginType: json['marginType'] as String?,
      margin: (json['margin'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MatchResultInfoToJson(MatchResultInfo instance) =>
    <String, dynamic>{
      'winner': instance.winner,
      'marginType': instance.marginType,
      'margin': instance.margin,
    };
