// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchOrganizationRes _$SearchOrganizationResFromJson(
  Map<String, dynamic> json,
) => SearchOrganizationRes(
  id: json['id'] as String,
  name: json['name'] as String,
  memberCount: (json['memberCount'] as num).toInt(),
);

Map<String, dynamic> _$SearchOrganizationResToJson(
  SearchOrganizationRes instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'memberCount': instance.memberCount,
};

SearchTournamentRes _$SearchTournamentResFromJson(Map<String, dynamic> json) =>
    SearchTournamentRes(
      id: json['id'] as String,
      name: json['name'] as String,
      organizationName: json['organizationName'] as String,
      format: json['format'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$SearchTournamentResToJson(
  SearchTournamentRes instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'organizationName': instance.organizationName,
  'format': instance.format,
  'status': instance.status,
};

SearchRes _$SearchResFromJson(Map<String, dynamic> json) => SearchRes(
  organizations: (json['organizations'] as List<dynamic>)
      .map((e) => SearchOrganizationRes.fromJson(e as Map<String, dynamic>))
      .toList(),
  tournaments: (json['tournaments'] as List<dynamic>)
      .map((e) => SearchTournamentRes.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SearchResToJson(SearchRes instance) => <String, dynamic>{
  'organizations': instance.organizations.map((e) => e.toJson()).toList(),
  'tournaments': instance.tournaments.map((e) => e.toJson()).toList(),
};
