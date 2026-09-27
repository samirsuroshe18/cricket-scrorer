import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_invite_res.g.dart';

/// `data` of `POST /v1/team/:teamId/invites`. [inviteId] is null with
/// `status: "accepted"` when the player was already linked to that person, so
/// there was nothing to ask; the roster entry exists either way.
@JsonSerializable()
class TeamInviteRes {
  final String? inviteId;

  /// `pending` or `accepted`.
  final String status;
  final TeamRosterPlayer player;

  TeamInviteRes({
    required this.inviteId,
    required this.status,
    required this.player,
  });

  factory TeamInviteRes.fromJson(Map<String, dynamic> json) =>
      _$TeamInviteResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamInviteResToJson(this);
}
