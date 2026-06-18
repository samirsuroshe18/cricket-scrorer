// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOtpReq _$VerifyOtpReqFromJson(Map<String, dynamic> json) => VerifyOtpReq(
      email: json['email'] as String,
      emailOtp: json['emailOtp'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$VerifyOtpReqToJson(VerifyOtpReq instance) =>
    <String, dynamic>{
      'email': instance.email,
      'emailOtp': instance.emailOtp,
      'type': instance.type,
    };
