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
    );

Map<String, dynamic> _$TeamRosterPlayerToJson(TeamRosterPlayer instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'jerseyNumber': instance.jerseyNumber,
      'role': instance.role,
    };

TeamProfileRes _$TeamProfileResFromJson(Map<String, dynamic> json) =>
    TeamProfileRes(
      teamId: json['teamId'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      organization: json['organization'] == null
          ? null
          : OrganizationRef.fromJson(
              json['organization'] as Map<String, dynamic>,
            ),
      roster: (json['roster'] as List<dynamic>)
          .map((e) => TeamRosterPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TeamProfileResToJson(TeamProfileRes instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'name': instance.name,
      'shortName': instance.shortName,
      'organization': instance.organization?.toJson(),
      'roster': instance.roster.map((e) => e.toJson()).toList(),
    };
