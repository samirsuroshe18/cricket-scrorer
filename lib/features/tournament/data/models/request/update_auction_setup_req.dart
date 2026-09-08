/// `PATCH /v1/tournament/:tournamentId/auction-setup` — every field is
/// independently optional. Deliberately **not** `@JsonSerializable`, same
/// reasoning as `UpdateTournamentReq`: `toJson()` omits an absent field
/// entirely rather than serializing it as `null`, because the backend
/// distinguishes "not sent" (leave unchanged) from a value — see the design
/// spec's §3.4, which also notes there is no explicit-clear path for any of
/// these fields in this pass, so `null` is never a meaningful value to send.
class UpdateAuctionSetupReq {
  final int? minSquadSize;
  final int? maxSquadSize;
  final Map<String, int>? categoryCaps;
  final List<AuctionOwnerInput>? owners;

  UpdateAuctionSetupReq({
    this.minSquadSize,
    this.maxSquadSize,
    this.categoryCaps,
    this.owners,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (minSquadSize != null) json['minSquadSize'] = minSquadSize;
    if (maxSquadSize != null) json['maxSquadSize'] = maxSquadSize;
    if (categoryCaps != null) json['categoryCaps'] = categoryCaps;
    if (owners != null) {
      json['owners'] = owners!.map((o) => o.toJson()).toList();
    }
    return json;
  }
}

/// One row of the `owners` array — a team, the org member owning it, and
/// their budget. Play-money only; see the design spec's §3.7.
class AuctionOwnerInput {
  final String teamId;
  final String userId;
  final int budget;

  AuctionOwnerInput({
    required this.teamId,
    required this.userId,
    required this.budget,
  });

  Map<String, dynamic> toJson() => {
    'teamId': teamId,
    'userId': userId,
    'budget': budget,
  };
}
