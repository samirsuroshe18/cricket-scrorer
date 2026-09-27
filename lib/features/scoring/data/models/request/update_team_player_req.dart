/// Body of `PATCH /v1/team/:teamId/players/:playerId`. Presence-sensitive, so
/// not `@JsonSerializable()`: an *absent* key means "leave unchanged", and for
/// `jerseyNumber` an explicit `null` means "remove the number". [toJson] omits
/// every unset field and only writes `jerseyNumber: null` when
/// [clearJerseyNumber] is set.
///
/// Separate from [UpdatePlayerReq] on purpose: `PATCH /v1/player/:playerId`
/// reads a `null` jersey number as `0`, so the flag must never be reachable
/// from that request.
class UpdateTeamPlayerReq {
  final String? role;
  final int? jerseyNumber;

  /// Wins over [jerseyNumber] when both are set.
  final bool clearJerseyNumber;

  UpdateTeamPlayerReq({
    this.role,
    this.jerseyNumber,
    this.clearJerseyNumber = false,
  });

  Map<String, dynamic> toJson() => {
    if (role != null) 'role': role,
    if (clearJerseyNumber)
      'jerseyNumber': null
    else if (jerseyNumber != null)
      'jerseyNumber': jerseyNumber,
  };
}
