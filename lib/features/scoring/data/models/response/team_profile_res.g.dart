// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_profile_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamRosterPlayer _$TeamRosterPlayerFromJson(Map<String, dynamic> json) =>
    TeamRosterPlayer(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
      role: json['role'] as String,
      isCaptain: json['isCaptain'] as bool? ?? false,
      isViceCaptain: json['isViceCaptain'] as bool? ?? false,
      inviteStatus: json['inviteStatus'] as String?,
    );

Map<String, dynamic> _$TeamRosterPlayerToJson(TeamRosterPlayer instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'jerseyNumber': instance.jerseyNumber,
      'role': instance.role,
      'isCaptain': instance.isCaptain,
      'isViceCaptain': instance.isViceCaptain,
      'inviteStatus': instance.inviteStatus,
    };

TeamStatsRes _$TeamStatsResFromJson(Map<String, dynamic> json) => TeamStatsRes(
  played: (json['played'] as num?)?.toInt() ?? 0,
  won: (json['won'] as num?)?.toInt() ?? 0,
  lost: (json['lost'] as num?)?.toInt() ?? 0,
  tied: (json['tied'] as num?)?.toInt() ?? 0,
  noResult: (json['noResult'] as num?)?.toInt() ?? 0,
  winPercentage: (json['winPercentage'] as num?)?.toDouble() ?? 0.0,
  form:
      (json['form'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$TeamStatsResToJson(TeamStatsRes instance) =>
    <String, dynamic>{
      'played': instance.played,
      'won': instance.won,
      'lost': instance.lost,
      'tied': instance.tied,
      'noResult': instance.noResult,
      'winPercentage': instance.winPercentage,
      'form': instance.form,
    };

TeamProfileRes _$TeamProfileResFromJson(Map<String, dynamic> json) =>
    TeamProfileRes(
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      organization: json['organization'] == null
          ? null
          : OrganizationRef.fromJson(
              json['organization'] as Map<String, dynamic>,
            ),
      canManage: json['canManage'] as bool,
      roster: (json['roster'] as List<dynamic>)
          .map((e) => TeamRosterPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: json['stats'] == null
          ? null
          : TeamStatsRes.fromJson(json['stats'] as Map<String, dynamic>),
      captainId: json['captainId'] as String?,
      viceCaptainId: json['viceCaptainId'] as String?,
    );

Map<String, dynamic> _$TeamProfileResToJson(TeamProfileRes instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'name': instance.name,
      'shortName': instance.shortName,
      'logoUrl': instance.logoUrl,
      'organization': instance.organization?.toJson(),
      'canManage': instance.canManage,
      'roster': instance.roster.map((e) => e.toJson()).toList(),
      'stats': instance.stats?.toJson(),
      'captainId': instance.captainId,
      'viceCaptainId': instance.viceCaptainId,
    };
