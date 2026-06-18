// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_pass_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetPassReq _$SetPassReqFromJson(Map<String, dynamic> json) => SetPassReq(
      email: json['email'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
      resetToken: json['resetToken'] as String,
    );

Map<String, dynamic> _$SetPassReqToJson(SetPassReq instance) =>
    <String, dynamic>{
      'email': instance.email,
      'newPassword': instance.newPassword,
      'confirmPassword': instance.confirmPassword,
      'resetToken': instance.resetToken,
    };
