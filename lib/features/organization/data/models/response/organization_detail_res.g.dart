// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_detail_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationUserRef _$OrganizationUserRefFromJson(Map<String, dynamic> json) =>
    OrganizationUserRef(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$OrganizationUserRefToJson(
  OrganizationUserRef instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

OrganizationMemberRes _$OrganizationMemberResFromJson(
  Map<String, dynamic> json,
) => OrganizationMemberRes(
  id: json['id'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$OrganizationMemberResToJson(
  OrganizationMemberRes instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'role': instance.role,
};

OrganizationTeamRef _$OrganizationTeamRefFromJson(Map<String, dynamic> json) =>
    OrganizationTeamRef(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
    );

Map<String, dynamic> _$OrganizationTeamRefToJson(
  OrganizationTeamRef instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'shortName': instance.shortName,
};

OrganizationTournamentRef _$OrganizationTournamentRefFromJson(
  Map<String, dynamic> json,
) => OrganizationTournamentRef(
  id: json['id'] as String,
  name: json['name'] as String,
  format: json['format'] as String,
  status: json['status'] as String,
  teamCount: (json['teamCount'] as num).toInt(),
);

Map<String, dynamic> _$OrganizationTournamentRefToJson(
  OrganizationTournamentRef instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'format': instance.format,
  'status': instance.status,
  'teamCount': instance.teamCount,
};

OrganizationDetailRes _$OrganizationDetailResFromJson(
  Map<String, dynamic> json,
) => OrganizationDetailRes(
  id: json['id'] as String,
  name: json['name'] as String,
  owner: OrganizationUserRef.fromJson(json['owner'] as Map<String, dynamic>),
  members: (json['members'] as List<dynamic>)
      .map((e) => OrganizationMemberRes.fromJson(e as Map<String, dynamic>))
      .toList(),
  teams: (json['teams'] as List<dynamic>)
      .map((e) => OrganizationTeamRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  tournaments:
      (json['tournaments'] as List<dynamic>?)
          ?.map(
            (e) =>
                OrganizationTournamentRef.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$OrganizationDetailResToJson(
  OrganizationDetailRes instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'owner': instance.owner.toJson(),
  'members': instance.members.map((e) => e.toJson()).toList(),
  'teams': instance.teams.map((e) => e.toJson()).toList(),
  'tournaments': instance.tournaments.map((e) => e.toJson()).toList(),
};
