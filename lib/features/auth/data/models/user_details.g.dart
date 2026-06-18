// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetails _$UserDetailsFromJson(Map<String, dynamic> json) => UserDetails(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      type: $enumDecodeNullable(_$UserTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$UserDetailsToJson(UserDetails instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'type': _$UserTypeEnumMap[instance.type],
    };

const _$UserTypeEnumMap = {
  UserType.standardUser: 'standardUser',
  UserType.institutionUser: 'institutionUser',
};
