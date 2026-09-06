/// Not `@JsonSerializable()`: `PATCH /v1/player/:playerId` treats an
/// *absent* field as "leave unchanged" but reads any other value as "the
/// caller sent this field" — same wire contract as `UpdateTournamentReq`.
/// Generated `toJson()` would serialize an unset field as JSON `null`
/// rather than omitting the key, which is exactly the wrong wire behavior
/// here. This class's `toJson()` omits every field that wasn't provided.
class UpdatePlayerReq {
  final String? role;
  final int? jerseyNumber;
  final String? bio;
  final String? battingStyle;
  final String? bowlingStyle;

  UpdatePlayerReq({
    this.role,
    this.jerseyNumber,
    this.bio,
    this.battingStyle,
    this.bowlingStyle,
  });

  Map<String, dynamic> toJson() => {
    if (role != null) 'role': role,
    if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
    if (bio != null) 'bio': bio,
    if (battingStyle != null) 'battingStyle': battingStyle,
    if (bowlingStyle != null) 'bowlingStyle': bowlingStyle,
  };
}
