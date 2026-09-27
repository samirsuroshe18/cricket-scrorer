// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_invite_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamInviteRes _$TeamInviteResFromJson(Map<String, dynamic> json) =>
    TeamInviteRes(
      inviteId: json['inviteId'] as String?,
      status: json['status'] as String,
      player: TeamRosterPlayer.fromJson(json['player'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamInviteResToJson(TeamInviteRes instance) =>
    <String, dynamic>{
      'inviteId': instance.inviteId,
      'status': instance.status,
      'player': instance.player,
    };
