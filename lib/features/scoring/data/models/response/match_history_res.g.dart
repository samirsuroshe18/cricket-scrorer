// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_history_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchHistoryItem _$MatchHistoryItemFromJson(Map<String, dynamic> json) =>
    MatchHistoryItem(
      matchId: json['matchId'] as String,
      teamA: TeamRef.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: TeamRef.fromJson(json['teamB'] as Map<String, dynamic>),
      joinCode: json['joinCode'] as String?,
      totalOvers: (json['totalOvers'] as num).toInt(),
      status: json['status'] as String,
      result: json['result'] == null
          ? null
          : MatchResultInfo.fromJson(json['result'] as Map<String, dynamic>),
      tossWinner: json['tossWinner'] as String?,
      tossDecision: json['tossDecision'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$MatchHistoryItemToJson(MatchHistoryItem instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'teamA': instance.teamA.toJson(),
      'teamB': instance.teamB.toJson(),
      'joinCode': instance.joinCode,
      'totalOvers': instance.totalOvers,
      'status': instance.status,
      'result': instance.result?.toJson(),
      'tossWinner': instance.tossWinner,
      'tossDecision': instance.tossDecision,
      'createdAt': instance.createdAt,
    };

MatchHistoryRes _$MatchHistoryResFromJson(Map<String, dynamic> json) =>
    MatchHistoryRes(
      matches: (json['matches'] as List<dynamic>)
          .map((e) => MatchHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$MatchHistoryResToJson(MatchHistoryRes instance) =>
    <String, dynamic>{
      'matches': instance.matches.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
    };
