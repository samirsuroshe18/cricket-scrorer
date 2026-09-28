// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_invites_res.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitedPlayerRes _$InvitedPlayerResFromJson(Map<String, dynamic> json) =>
    InvitedPlayerRes(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
    );

Map<String, dynamic> _$InvitedPlayerResToJson(InvitedPlayerRes instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
    };

InviteeUserRes _$InviteeUserResFromJson(Map<String, dynamic> json) =>
    InviteeUserRes(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$InviteeUserResToJson(InviteeUserRes instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'fullName': instance.fullName,
      'photoUrl': instance.photoUrl,
    };

TeamInviteItemRes _$TeamInviteItemResFromJson(Map<String, dynamic> json) =>
    TeamInviteItemRes(
      inviteId: json['inviteId'] as String,
      status: json['status'] as String,
      respondedAt: json['respondedAt'] as String?,
      player: InvitedPlayerRes.fromJson(json['player'] as Map<String, dynamic>),
      invitee: InviteeUserRes.fromJson(json['invitee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TeamInviteItemResToJson(TeamInviteItemRes instance) =>
    <String, dynamic>{
      'inviteId': instance.inviteId,
      'status': instance.status,
      'respondedAt': instance.respondedAt,
      'player': instance.player.toJson(),
      'invitee': instance.invitee.toJson(),
    };

TeamInvitesRes _$TeamInvitesResFromJson(Map<String, dynamic> json) =>
    TeamInvitesRes(
      invites:
          (json['invites'] as List<dynamic>?)
              ?.map(
                (e) => TeamInviteItemRes.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$TeamInvitesResToJson(TeamInvitesRes instance) =>
    <String, dynamic>{
      'invites': instance.invites.map((e) => e.toJson()).toList(),
    };
