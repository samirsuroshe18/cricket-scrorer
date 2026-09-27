// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'looked_up_user_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LookedUpUserRes _$LookedUpUserResFromJson(Map<String, dynamic> json) =>
    LookedUpUserRes(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      userName: json['userName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$LookedUpUserResToJson(LookedUpUserRes instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'fullName': instance.fullName,
      'userName': instance.userName,
      'photoUrl': instance.photoUrl,
    };
