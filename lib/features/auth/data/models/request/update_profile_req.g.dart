// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileReq _$UpdateProfileReqFromJson(Map<String, dynamic> json) =>
    UpdateProfileReq(
      userName: json['userName'] as String,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$UpdateProfileReqToJson(UpdateProfileReq instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'bio': instance.bio,
    };
