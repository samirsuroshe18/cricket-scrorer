import 'package:json_annotation/json_annotation.dart';

part 'team_invites_res.g.dart';

@JsonSerializable()
class InvitedPlayerRes {
  final String playerId;
  final String playerName;

  InvitedPlayerRes({required this.playerId, required this.playerName});

  factory InvitedPlayerRes.fromJson(Map<String, dynamic> json) =>
      _$InvitedPlayerResFromJson(json);

  Map<String, dynamic> toJson() => _$InvitedPlayerResToJson(this);
}

@JsonSerializable()
class InviteeUserRes {
  final String userId;
  final String fullName;
  final String? photoUrl;

  InviteeUserRes({
    required this.userId,
    required this.fullName,
    this.photoUrl,
  });

  factory InviteeUserRes.fromJson(Map<String, dynamic> json) =>
      _$InviteeUserResFromJson(json);

  Map<String, dynamic> toJson() => _$InviteeUserResToJson(this);
}

/// One row of `GET /v1/team/:teamId/invites`.
@JsonSerializable(explicitToJson: true)
class TeamInviteItemRes {
  final String inviteId;

  /// `pending`, `accepted` or `declined` (cancelled invites are never listed).
  final String status;

  /// ISO timestamp of the answer; null while pending.
  final String? respondedAt;
  final InvitedPlayerRes player;
  final InviteeUserRes invitee;

  TeamInviteItemRes({
    required this.inviteId,
    required this.status,
    this.respondedAt,
    required this.player,
    required this.invitee,
  });

  factory TeamInviteItemRes.fromJson(Map<String, dynamic> json) =>
      _$TeamInviteItemResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamInviteItemResToJson(this);
}

/// `data` of `GET /v1/team/:teamId/invites`: one row per invitee, newest first.
@JsonSerializable(explicitToJson: true)
class TeamInvitesRes {
  @JsonKey(defaultValue: <TeamInviteItemRes>[])
  final List<TeamInviteItemRes> invites;

  TeamInvitesRes({this.invites = const []});

  factory TeamInvitesRes.fromJson(Map<String, dynamic> json) =>
      _$TeamInvitesResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamInvitesResToJson(this);
}
