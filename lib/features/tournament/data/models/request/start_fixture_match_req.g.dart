// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_fixture_match_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartFixtureMatchReq _$StartFixtureMatchReqFromJson(
  Map<String, dynamic> json,
) => StartFixtureMatchReq(
  totalOvers: (json['totalOvers'] as num).toInt(),
  tossWinner: json['tossWinner'] as String?,
  tossDecision: json['tossDecision'] as String?,
);

Map<String, dynamic> _$StartFixtureMatchReqToJson(
  StartFixtureMatchReq instance,
) => <String, dynamic>{
  'totalOvers': instance.totalOvers,
  'tossWinner': ?instance.tossWinner,
  'tossDecision': ?instance.tossDecision,
};
