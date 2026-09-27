/// Body of `POST /v1/team/:teamId/players`. Not `@JsonSerializable()`: the
/// server treats `null` and an absent key the same, but omitting unset fields
/// keeps the wire body minimal and matches [UpdatePlayerReq].
///
/// Exactly one of [name] (a typed name, find-or-create) or [playerId] (one of
/// the scorer's existing players) identifies the player; the server ignores
/// `name` when `playerId` is present.
class AddTeamPlayerReq {
  final String? name;
  final String? playerId;
  final String? role;
  final int? jerseyNumber;

  AddTeamPlayerReq({this.name, this.playerId, this.role, this.jerseyNumber})
    : assert(
        name != null || playerId != null,
        'AddTeamPlayerReq needs a name or a playerId',
      );

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (playerId != null) 'playerId': playerId,
    if (role != null) 'role': role,
    if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
  };
}
