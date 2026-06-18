// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      loggedInUser: json['loggedInUser'] == null
          ? null
          : LoggedInUser.fromJson(json['loggedInUser'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'loggedInUser': instance.loggedInUser,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

LoggedInUser _$LoggedInUserFromJson(Map<String, dynamic> json) => LoggedInUser(
      id: json['_id'] as String?,
      email: json['email'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      userName: json['userName'] as String?,
      profileCompleted: json['profileCompleted'] as bool?,
      accountStatus: json['accountStatus'] as String?,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      v: (json['__v'] as num?)?.toInt(),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      passwordChangedAt: json['passwordChangedAt'] == null
          ? null
          : DateTime.parse(json['passwordChangedAt'] as String),
      bio: json['bio'] as String?,
      fullName: json['fullName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$LoggedInUserToJson(LoggedInUser instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'email': instance.email,
      'isEmailVerified': instance.isEmailVerified,
      'userName': instance.userName,
      'profileCompleted': instance.profileCompleted,
      'accountStatus': instance.accountStatus,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      '__v': instance.v,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'passwordChangedAt': instance.passwordChangedAt?.toIso8601String(),
      'bio': instance.bio,
      'fullName': instance.fullName,
      'photoUrl': instance.photoUrl,
    };
