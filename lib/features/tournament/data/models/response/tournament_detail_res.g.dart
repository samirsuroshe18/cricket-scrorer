// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_detail_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentOrganizationRef _$TournamentOrganizationRefFromJson(
  Map<String, dynamic> json,
) => TournamentOrganizationRef(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$TournamentOrganizationRefToJson(
  TournamentOrganizationRef instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

TournamentTeamRef _$TournamentTeamRefFromJson(Map<String, dynamic> json) =>
    TournamentTeamRef(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$TournamentTeamRefToJson(TournamentTeamRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'shortName': instance.shortName,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

TournamentDetailRes _$TournamentDetailResFromJson(Map<String, dynamic> json) =>
    TournamentDetailRes(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String,
      status: json['status'] as String,
      organization: TournamentOrganizationRef.fromJson(
        json['organization'] as Map<String, dynamic>,
      ),
      teams: (json['teams'] as List<dynamic>)
          .map((e) => TournamentTeamRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TournamentDetailResToJson(
  TournamentDetailRes instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'format': instance.format,
  'status': instance.status,
  'organization': instance.organization.toJson(),
  'teams': instance.teams.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
};
