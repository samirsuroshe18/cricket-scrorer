// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_organization_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamOrganizationRes _$TeamOrganizationResFromJson(Map<String, dynamic> json) =>
    TeamOrganizationRes(
      id: json['id'] as String,
      organization: json['organization'] == null
          ? null
          : OrganizationRef.fromJson(
              json['organization'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TeamOrganizationResToJson(
  TeamOrganizationRes instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization': instance.organization?.toJson(),
};
