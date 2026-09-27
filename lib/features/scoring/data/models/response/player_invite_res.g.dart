// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_invite_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerInviteRes _$PlayerInviteResFromJson(Map<String, dynamic> json) =>
    PlayerInviteRes(
      inviteId: json['inviteId'] as String,
      status: json['status'] as String,
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      invitedByName: json['invitedByName'] as String?,
      playerName: json['playerName'] as String?,
    );

Map<String, dynamic> _$PlayerInviteResToJson(PlayerInviteRes instance) =>
    <String, dynamic>{
      'inviteId': instance.inviteId,
      'status': instance.status,
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'invitedByName': instance.invitedByName,
      'playerName': instance.playerName,
    };

PlayerInviteAnswerRes _$PlayerInviteAnswerResFromJson(
  Map<String, dynamic> json,
) => PlayerInviteAnswerRes(
  inviteId: json['inviteId'] as String,
  status: json['status'] as String,
  playerId: json['playerId'] as String?,
);

Map<String, dynamic> _$PlayerInviteAnswerResToJson(
  PlayerInviteAnswerRes instance,
) => <String, dynamic>{
  'inviteId': instance.inviteId,
  'status': instance.status,
  'playerId': instance.playerId,
};
