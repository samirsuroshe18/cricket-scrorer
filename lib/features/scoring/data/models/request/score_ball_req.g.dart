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

Map<String, dynamic> _$ScoreBallReqToJson(ScoreBallReq instance) {
  final val = <String, dynamic>{
    'runs': instance.runs,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extraType', instance.extraType);
  writeNotNull('runsFrom', instance.runsFrom);
  writeNotNull('wicketType', instance.wicketType);
  writeNotNull('dismissedBatsman', instance.dismissedBatsman);
  writeNotNull('incomingBatsmanName', instance.incomingBatsmanName);
  val['idempotencyKey'] = instance.idempotencyKey;
  return val;
}
