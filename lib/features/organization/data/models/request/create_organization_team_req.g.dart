// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_organization_team_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrganizationTeamReq _$CreateOrganizationTeamReqFromJson(
  Map<String, dynamic> json,
) => CreateOrganizationTeamReq(
  name: json['name'] as String,
  shortName: json['shortName'] as String?,
);

Map<String, dynamic> _$CreateOrganizationTeamReqToJson(
  CreateOrganizationTeamReq instance,
) => <String, dynamic>{'name': instance.name, 'shortName': instance.shortName};
