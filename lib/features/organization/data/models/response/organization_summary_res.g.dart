// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_summary_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationSummaryRes _$OrganizationSummaryResFromJson(
  Map<String, dynamic> json,
) => OrganizationSummaryRes(
  id: json['id'] as String,
  name: json['name'] as String,
  myRole: json['myRole'] as String,
  memberCount: (json['memberCount'] as num).toInt(),
  teamCount: (json['teamCount'] as num).toInt(),
  logoUrl: json['logoUrl'] as String?,
);

Map<String, dynamic> _$OrganizationSummaryResToJson(
  OrganizationSummaryRes instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'myRole': instance.myRole,
  'memberCount': instance.memberCount,
  'teamCount': instance.teamCount,
  'logoUrl': instance.logoUrl,
};

MyOrganizationsRes _$MyOrganizationsResFromJson(Map<String, dynamic> json) =>
    MyOrganizationsRes(
      organizations: (json['organizations'] as List<dynamic>)
          .map(
            (e) => OrganizationSummaryRes.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$MyOrganizationsResToJson(MyOrganizationsRes instance) =>
    <String, dynamic>{
      'organizations': instance.organizations.map((e) => e.toJson()).toList(),
    };
