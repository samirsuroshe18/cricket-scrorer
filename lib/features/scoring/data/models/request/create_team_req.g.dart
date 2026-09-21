// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_team_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTeamReq _$CreateTeamReqFromJson(Map<String, dynamic> json) =>
    CreateTeamReq(
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
    );

Map<String, dynamic> _$CreateTeamReqToJson(CreateTeamReq instance) =>
    <String, dynamic>{'name': instance.name, 'shortName': instance.shortName};
