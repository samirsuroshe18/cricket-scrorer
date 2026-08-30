// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_complete_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchCompleteInningsSummary _$MatchCompleteInningsSummaryFromJson(
  Map<String, dynamic> json,
) => MatchCompleteInningsSummary(
  inningsNumber: (json['inningsNumber'] as num).toInt(),
  battingTeam: json['battingTeam'] as String,
  totalRuns: (json['totalRuns'] as num).toInt(),
  wickets: (json['wickets'] as num).toInt(),
  overs: json['overs'] as String,
);

Map<String, dynamic> _$MatchCompleteInningsSummaryToJson(
  MatchCompleteInningsSummary instance,
) => <String, dynamic>{
  'inningsNumber': instance.inningsNumber,
  'battingTeam': instance.battingTeam,
  'totalRuns': instance.totalRuns,
  'wickets': instance.wickets,
  'overs': instance.overs,
};

MatchCompleteRes _$MatchCompleteResFromJson(Map<String, dynamic> json) =>
    MatchCompleteRes(
      matchId: json['matchId'] as String,
      result: MatchResultInfo.fromJson(json['result'] as Map<String, dynamic>),
      innings: (json['innings'] as List<dynamic>)
          .map(
            (e) =>
                MatchCompleteInningsSummary.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$MatchCompleteResToJson(MatchCompleteRes instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'result': instance.result.toJson(),
      'innings': instance.innings.map((e) => e.toJson()).toList(),
    };
