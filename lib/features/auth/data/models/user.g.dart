// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String?,
  email: json['email'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool?,
  userName: json['userName'] as String?,
  profileCompleted: json['profileCompleted'] as bool?,
  accountStatus: json['accountStatus'] as String?,
  language: json['language'] as String?,
  isDeleted: json['isDeleted'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'email': instance.email,
  'isEmailVerified': instance.isEmailVerified,
  'userName': instance.userName,
  'profileCompleted': instance.profileCompleted,
  'accountStatus': instance.accountStatus,
  'language': instance.language,
  'isDeleted': instance.isDeleted,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
};
