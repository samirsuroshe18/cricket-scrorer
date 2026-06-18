// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterReq _$RegisterReqFromJson(Map<String, dynamic> json) => RegisterReq(
      email: json['email'] as String,
      userName: json['userName'] as String?,
      fullName: json['fullName'] as String?,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
    );

Map<String, dynamic> _$RegisterReqToJson(RegisterReq instance) =>
    <String, dynamic>{
      'email': instance.email,
      'userName': instance.userName,
      'fullName': instance.fullName,
      'password': instance.password,
      'fcmToken': instance.fcmToken,
      'rememberMe': instance.rememberMe,
    };
