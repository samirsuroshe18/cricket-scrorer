import 'package:json_annotation/json_annotation.dart';

part 'player_invite_res.g.dart';

/// `data` of `GET /v1/player-invite/:inviteId` — the invitee's current view,
/// fetched fresh because the notification payload is frozen at send time.
@JsonSerializable()
class PlayerInviteRes {
  final String inviteId;

  /// `pending` / `accepted` / `declined`.
  final String status;
  final String teamId;
  final String teamName;
  final String? invitedByName;
  final String? playerName;

  PlayerInviteRes({
    required this.inviteId,
    required this.status,
    required this.teamId,
    required this.teamName,
    this.invitedByName,
    this.playerName,
  });

  bool get isPending => status == 'pending';

  factory PlayerInviteRes.fromJson(Map<String, dynamic> json) =>
      _$PlayerInviteResFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerInviteResToJson(this);
}

/// `data` of `POST /v1/player-invite/:inviteId/accept` and `/decline`.
/// [playerId] is only sent on accept.
@JsonSerializable()
class PlayerInviteAnswerRes {
  final String inviteId;
  final String status;
  final String? playerId;

  PlayerInviteAnswerRes({
    required this.inviteId,
    required this.status,
    this.playerId,
  });

  factory PlayerInviteAnswerRes.fromJson(Map<String, dynamic> json) =>
      _$PlayerInviteAnswerResFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerInviteAnswerResToJson(this);
}
