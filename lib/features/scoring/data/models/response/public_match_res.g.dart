// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_match_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicTeamRef _$PublicTeamRefFromJson(Map<String, dynamic> json) =>
    PublicTeamRef(
      name: json['name'] as String?,
    );

Map<String, dynamic> _$PublicTeamRefToJson(PublicTeamRef instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

PublicMatchInfo _$PublicMatchInfoFromJson(Map<String, dynamic> json) =>
    PublicMatchInfo(
      matchId: json['matchId'] as String,
      joinCode: json['joinCode'] as String?,
      title: json['title'] as String?,
      teamA: PublicTeamRef.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: PublicTeamRef.fromJson(json['teamB'] as Map<String, dynamic>),
      totalOvers: (json['totalOvers'] as num).toInt(),
      status: json['status'] as String,
      matchType: json['matchType'] as String?,
      venue: json['venue'] as String?,
      currentInnings: (json['currentInnings'] as num).toInt(),
    );

Map<String, dynamic> _$PublicMatchInfoToJson(PublicMatchInfo instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'joinCode': instance.joinCode,
      'title': instance.title,
      'teamA': instance.teamA.toJson(),
      'teamB': instance.teamB.toJson(),
      'totalOvers': instance.totalOvers,
      'status': instance.status,
      'matchType': instance.matchType,
      'venue': instance.venue,
      'currentInnings': instance.currentInnings,
    };

PublicInningsState _$PublicInningsStateFromJson(Map<String, dynamic> json) =>
    PublicInningsState(
      matchId: json['matchId'] as String?,
      inningsNumber: (json['inningsNumber'] as num?)?.toInt(),
      totalRuns: (json['totalRuns'] as num).toInt(),
      wickets: (json['wickets'] as num).toInt(),
      overs: json['overs'] as String,
      extras: ExtrasBreakdown.fromJson(json['extras'] as Map<String, dynamic>),
      strike: json['strike'] == null
          ? null
          : Strike.fromJson(json['strike'] as Map<String, dynamic>),
      bowler: json['bowler'] == null
          ? null
          : BowlerState.fromJson(json['bowler'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PublicInningsStateToJson(PublicInningsState instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'inningsNumber': instance.inningsNumber,
      'totalRuns': instance.totalRuns,
      'wickets': instance.wickets,
      'overs': instance.overs,
      'extras': instance.extras.toJson(),
      'strike': instance.strike?.toJson(),
      'bowler': instance.bowler?.toJson(),
    };

PublicMatchRes _$PublicMatchResFromJson(Map<String, dynamic> json) =>
    PublicMatchRes(
      match: PublicMatchInfo.fromJson(json['match'] as Map<String, dynamic>),
      innings: json['innings'] == null
          ? null
          : PublicInningsState.fromJson(
              json['innings'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PublicMatchResToJson(PublicMatchRes instance) =>
    <String, dynamic>{
      'match': instance.match.toJson(),
      'innings': instance.innings?.toJson(),
    };
