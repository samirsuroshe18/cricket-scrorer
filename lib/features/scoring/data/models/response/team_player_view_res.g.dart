// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_player_view_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamPlayerRosterPlayer _$TeamPlayerRosterPlayerFromJson(
  Map<String, dynamic> json,
) => TeamPlayerRosterPlayer(
  playerId: json['playerId'] as String,
  playerName: json['playerName'] as String,
  role: json['role'] as String,
  jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
  isCaptain: json['isCaptain'] as bool? ?? false,
  isViceCaptain: json['isViceCaptain'] as bool? ?? false,
);

Map<String, dynamic> _$TeamPlayerRosterPlayerToJson(
  TeamPlayerRosterPlayer instance,
) => <String, dynamic>{
  'playerId': instance.playerId,
  'playerName': instance.playerName,
  'role': instance.role,
  'jerseyNumber': instance.jerseyNumber,
  'isCaptain': instance.isCaptain,
  'isViceCaptain': instance.isViceCaptain,
};

TeamPlayerViewRes _$TeamPlayerViewResFromJson(Map<String, dynamic> json) =>
    TeamPlayerViewRes(
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      stats: json['stats'] == null
          ? null
          : TeamStatsRes.fromJson(json['stats'] as Map<String, dynamic>),
      captainId: json['captainId'] as String?,
      viceCaptainId: json['viceCaptainId'] as String?,
      roster: (json['roster'] as List<dynamic>)
          .map(
            (e) => TeamPlayerRosterPlayer.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$TeamPlayerViewResToJson(TeamPlayerViewRes instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'name': instance.name,
      'shortName': instance.shortName,
      'logoUrl': instance.logoUrl,
      'stats': instance.stats?.toJson(),
      'captainId': instance.captainId,
      'viceCaptainId': instance.viceCaptainId,
      'roster': instance.roster.map((e) => e.toJson()).toList(),
    };
