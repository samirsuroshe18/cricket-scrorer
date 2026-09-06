// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_leaderboards_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationLeaderboardsRes _$OrganizationLeaderboardsResFromJson(
  Map<String, dynamic> json,
) => OrganizationLeaderboardsRes(
  organizationId: json['organizationId'] as String,
  battingLeaderboard: (json['battingLeaderboard'] as List<dynamic>)
      .map((e) => BattingLeaderboardRowRes.fromJson(e as Map<String, dynamic>))
      .toList(),
  bowlingLeaderboard: (json['bowlingLeaderboard'] as List<dynamic>)
      .map((e) => BowlingLeaderboardRowRes.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrganizationLeaderboardsResToJson(
  OrganizationLeaderboardsRes instance,
) => <String, dynamic>{
  'organizationId': instance.organizationId,
  'battingLeaderboard': instance.battingLeaderboard
      .map((e) => e.toJson())
      .toList(),
  'bowlingLeaderboard': instance.bowlingLeaderboard
      .map((e) => e.toJson())
      .toList(),
};
