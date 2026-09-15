// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileReq _$UpdateProfileReqFromJson(Map<String, dynamic> json) =>
    UpdateProfileReq(
      userName: json['userName'] as String,
      bio: json['bio'] as String?,
      battingStyle: json['battingStyle'] as String?,
      bowlingStyle: json['bowlingStyle'] as String?,
      playingRole: json['playingRole'] as String?,
      jerseyNumber: (json['jerseyNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateProfileReqToJson(UpdateProfileReq instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'bio': instance.bio,
      'battingStyle': ?instance.battingStyle,
      'bowlingStyle': ?instance.bowlingStyle,
      'playingRole': ?instance.playingRole,
      'jerseyNumber': ?instance.jerseyNumber,
    };
