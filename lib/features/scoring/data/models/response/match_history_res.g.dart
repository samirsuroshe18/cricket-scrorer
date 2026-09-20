// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_history_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchUserRef _$MatchUserRefFromJson(Map<String, dynamic> json) =>
    MatchUserRef(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$MatchUserRefToJson(MatchUserRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

RecentBall _$RecentBallFromJson(Map<String, dynamic> json) => RecentBall(
  totalRuns: (json['totalRuns'] as num).toInt(),
  extraType: json['extraType'] as String?,
  isWicket: json['isWicket'] as bool,
);

Map<String, dynamic> _$RecentBallToJson(RecentBall instance) =>
    <String, dynamic>{
      'totalRuns': instance.totalRuns,
      'extraType': instance.extraType,
      'isWicket': instance.isWicket,
    };

CurrentInningsSummary _$CurrentInningsSummaryFromJson(
  Map<String, dynamic> json,
) => CurrentInningsSummary(
  inningsNumber: (json['inningsNumber'] as num).toInt(),
  battingTeam: json['battingTeam'] as String?,
  totalRuns: (json['totalRuns'] as num).toInt(),
  wickets: (json['wickets'] as num).toInt(),
  overs: json['overs'] as String,
  target: (json['target'] as num?)?.toInt(),
  recentBalls:
      (json['recentBalls'] as List<dynamic>?)
          ?.map((e) => RecentBall.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CurrentInningsSummaryToJson(
  CurrentInningsSummary instance,
) => <String, dynamic>{
  'inningsNumber': instance.inningsNumber,
  'battingTeam': instance.battingTeam,
  'totalRuns': instance.totalRuns,
  'wickets': instance.wickets,
  'overs': instance.overs,
  'target': instance.target,
  'recentBalls': instance.recentBalls.map((e) => e.toJson()).toList(),
};

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
      createdBy: json['createdBy'] == null
          ? null
          : MatchUserRef.fromJson(json['createdBy'] as Map<String, dynamic>),
      assignedScorer: json['assignedScorer'] == null
          ? null
          : MatchUserRef.fromJson(
              json['assignedScorer'] as Map<String, dynamic>,
            ),
      createdAt: json['createdAt'] as String,
      syncStatus: json['syncStatus'] as String,
      currentInnings: json['currentInnings'] == null
          ? null
          : CurrentInningsSummary.fromJson(
              json['currentInnings'] as Map<String, dynamic>,
            ),
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
      'createdBy': instance.createdBy?.toJson(),
      'assignedScorer': instance.assignedScorer?.toJson(),
      'createdAt': instance.createdAt,
      'syncStatus': instance.syncStatus,
      'currentInnings': instance.currentInnings?.toJson(),
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
