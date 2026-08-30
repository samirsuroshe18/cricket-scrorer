// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_ball_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScoreBallReq _$ScoreBallReqFromJson(Map<String, dynamic> json) => ScoreBallReq(
  runs: (json['runs'] as num).toInt(),
  extraType: json['extraType'] as String?,
  runsFrom: json['runsFrom'] as String?,
  wicketType: json['wicketType'] as String?,
  dismissedBatsman: json['dismissedBatsman'] as String?,
  incomingBatsmanName: json['incomingBatsmanName'] as String?,
  idempotencyKey: json['idempotencyKey'] as String,
);

Map<String, dynamic> _$ScoreBallReqToJson(ScoreBallReq instance) =>
    <String, dynamic>{
      'runs': instance.runs,
      'extraType': ?instance.extraType,
      'runsFrom': ?instance.runsFrom,
      'wicketType': ?instance.wicketType,
      'dismissedBatsman': ?instance.dismissedBatsman,
      'incomingBatsmanName': ?instance.incomingBatsmanName,
      'idempotencyKey': instance.idempotencyKey,
    };
