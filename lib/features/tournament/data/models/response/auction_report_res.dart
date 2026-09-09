import 'package:json_annotation/json_annotation.dart';

part 'auction_report_res.g.dart';

/// `GET /v1/tournament/:tournamentId/auction/squad` — live-reflects
/// whatever's true right now (empty before the auction starts, partial
/// mid-auction, final once every lot has resolved). There is no
/// `sessionId` anywhere in this feature: a tournament can have at most one
/// `AuctionSession` ever (see the backend's unique index + `startAuction`'s
/// unconditional 409), so there is nothing to pick between.
@JsonSerializable(explicitToJson: true)
class AuctionSquadRes {
  final String tournamentId;
  final List<AuctionSquadTeamRes> teams;
  final List<AuctionUnsoldPlayerRes> unsold;

  AuctionSquadRes({
    required this.tournamentId,
    required this.teams,
    required this.unsold,
  });

  factory AuctionSquadRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionSquadResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionSquadResToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AuctionSquadTeamRes {
  final String teamId;
  final String teamName;
  final String ownerId;
  final String ownerName;
  final int budget;
  final int spent;
  final int remaining;
  final List<AuctionSquadPlayerRes> players;

  AuctionSquadTeamRes({
    required this.teamId,
    required this.teamName,
    required this.ownerId,
    required this.ownerName,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.players,
  });

  factory AuctionSquadTeamRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionSquadTeamResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionSquadTeamResToJson(this);
}

@JsonSerializable()
class AuctionSquadPlayerRes {
  final String playerId;
  final String playerName;
  final String? role;
  final int soldPrice;

  AuctionSquadPlayerRes({
    required this.playerId,
    required this.playerName,
    this.role,
    required this.soldPrice,
  });

  factory AuctionSquadPlayerRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionSquadPlayerResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionSquadPlayerResToJson(this);
}

@JsonSerializable()
class AuctionUnsoldPlayerRes {
  final String playerId;
  final String playerName;
  final String? role;
  final int basePrice;

  AuctionUnsoldPlayerRes({
    required this.playerId,
    required this.playerName,
    this.role,
    required this.basePrice,
  });

  factory AuctionUnsoldPlayerRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionUnsoldPlayerResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionUnsoldPlayerResToJson(this);
}

/// `GET /v1/tournament/:tournamentId/auction/history` — resolution summary
/// only (no per-lot bid trail), ordered by `resolvedAt` ascending. This is
/// the data source Phase 5's shareable "SOLD" card will read from.
@JsonSerializable(explicitToJson: true)
class AuctionHistoryRes {
  final String tournamentId;
  final List<AuctionHistoryEntryRes> entries;

  AuctionHistoryRes({
    required this.tournamentId,
    required this.entries,
  });

  factory AuctionHistoryRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionHistoryResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionHistoryResToJson(this);
}

@JsonSerializable()
class AuctionHistoryEntryRes {
  final String lotId;
  final String playerId;
  final String playerName;
  final String? role;
  final int basePrice;
  final String outcome;
  final int? soldPrice;
  final String? teamId;
  final String? teamName;
  final DateTime resolvedAt;

  AuctionHistoryEntryRes({
    required this.lotId,
    required this.playerId,
    required this.playerName,
    this.role,
    required this.basePrice,
    required this.outcome,
    this.soldPrice,
    this.teamId,
    this.teamName,
    required this.resolvedAt,
  });

  factory AuctionHistoryEntryRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionHistoryEntryResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionHistoryEntryResToJson(this);
}
