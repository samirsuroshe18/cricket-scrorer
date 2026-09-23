// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_teams_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationRef _$OrganizationRefFromJson(Map<String, dynamic> json) =>
    OrganizationRef(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$OrganizationRefToJson(OrganizationRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

TeamSummary _$TeamSummaryFromJson(Map<String, dynamic> json) => TeamSummary(
  id: json['id'] as String,
  name: json['name'] as String,
  shortName: json['shortName'] as String?,
  logoUrl: json['logoUrl'] as String?,
  organization: json['organization'] == null
      ? null
      : OrganizationRef.fromJson(json['organization'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TeamSummaryToJson(TeamSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'shortName': instance.shortName,
      'logoUrl': instance.logoUrl,
      'organization': instance.organization?.toJson(),
    };

MyTeamsRes _$MyTeamsResFromJson(Map<String, dynamic> json) => MyTeamsRes(
  teams: (json['teams'] as List<dynamic>)
      .map((e) => TeamSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$MyTeamsResToJson(MyTeamsRes instance) =>
    <String, dynamic>{
      'teams': instance.teams.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
    };
