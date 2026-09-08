import 'package:json_annotation/json_annotation.dart';

part 'auction_state_res.g.dart';

/// One-shot responses from the four owner-only auction actions
/// (start/pause/resume/next) — separate from [AuctionStateRes] below, which
/// is the *live* room's continuously-updated shape delivered over sockets.
@JsonSerializable()
class AuctionStartRes {
  final String tournamentId;
  final String sessionId;
  final String status;
  final int lotCount;

  AuctionStartRes({
    required this.tournamentId,
    required this.sessionId,
    required this.status,
    required this.lotCount,
  });

  factory AuctionStartRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionStartResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionStartResToJson(this);
}

@JsonSerializable()
class AuctionPauseResumeRes {
  final String tournamentId;
  final String status;
  final DateTime? currentLotEndsAt;

  AuctionPauseResumeRes({
    required this.tournamentId,
    required this.status,
    this.currentLotEndsAt,
  });

  factory AuctionPauseResumeRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionPauseResumeResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionPauseResumeResToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AuctionNextLotRes {
  final String tournamentId;
  final bool completed;
  final AuctionLotRes? lot;

  AuctionNextLotRes({
    required this.tournamentId,
    required this.completed,
    this.lot,
  });

  factory AuctionNextLotRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionNextLotResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionNextLotResToJson(this);
}

/// The full current state of a tournament's auction room — the shape
/// `auction:join`'s socket ack sends. [AuctionRoomController] reconstructs
/// these plain objects itself on every broadcast rather than mutating in
/// place, so no `copyWith` is needed anywhere on this page.
@JsonSerializable(explicitToJson: true)
class AuctionStateRes {
  final String? sessionStatus;
  final AuctionLotRes? lot;
  final List<AuctionBidEventRes> bidHistory;
  final List<AuctionBudgetRes> budgets;

  AuctionStateRes({
    this.sessionStatus,
    this.lot,
    required this.bidHistory,
    required this.budgets,
  });

  factory AuctionStateRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionStateResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionStateResToJson(this);
}

@JsonSerializable()
class AuctionLotRes {
  final String lotId;
  final String playerId;
  final String? playerName;
  final String? playerRole;
  final int basePrice;
  final int currentBid;
  final DateTime? endsAt;

  AuctionLotRes({
    required this.lotId,
    required this.playerId,
    this.playerName,
    this.playerRole,
    required this.basePrice,
    required this.currentBid,
    this.endsAt,
  });

  factory AuctionLotRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionLotResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionLotResToJson(this);
}

@JsonSerializable()
class AuctionBidEventRes {
  final String bidderTeamId;
  final String bidderTeamName;
  final int amount;
  final DateTime at;

  AuctionBidEventRes({
    required this.bidderTeamId,
    required this.bidderTeamName,
    required this.amount,
    required this.at,
  });

  factory AuctionBidEventRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionBidEventResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionBidEventResToJson(this);
}

@JsonSerializable()
class AuctionBudgetRes {
  final String teamId;
  final String teamName;
  final String ownerId;
  final int budget;
  final int spent;
  final int remaining;

  AuctionBudgetRes({
    required this.teamId,
    required this.teamName,
    required this.ownerId,
    required this.budget,
    required this.spent,
    required this.remaining,
  });

  factory AuctionBudgetRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionBudgetResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionBudgetResToJson(this);
}
