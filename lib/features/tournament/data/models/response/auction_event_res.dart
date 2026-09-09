import 'package:json_annotation/json_annotation.dart';

part 'auction_event_res.g.dart';

/// The four broadcast payloads a joined auction-room socket receives, each
/// parsed straight off its own event — see [AuctionSocketService].

@JsonSerializable()
class AuctionBidAcceptedRes {
  final String lotId;
  final int amount;
  final String bidderTeamId;
  final String bidderTeamName;
  final DateTime endsAt;

  AuctionBidAcceptedRes({
    required this.lotId,
    required this.amount,
    required this.bidderTeamId,
    required this.bidderTeamName,
    required this.endsAt,
  });

  factory AuctionBidAcceptedRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionBidAcceptedResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionBidAcceptedResToJson(this);
}

@JsonSerializable()
class AuctionBidRejectedRes {
  final String code;
  final String message;

  AuctionBidRejectedRes({required this.code, required this.message});

  factory AuctionBidRejectedRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionBidRejectedResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionBidRejectedResToJson(this);
}

@JsonSerializable()
class AuctionLotResolvedRes {
  final String lotId;
  final String outcome;
  final int? soldPrice;
  final String? soldTo;

  /// The winning team's own updated budget figures — present only when
  /// [outcome] is `'sold'`. Sent so the client applies the server's
  /// authoritative post-charge number rather than computing it itself from
  /// a possibly-stale local `budgets` cache (see
  /// AuctionRoomController.watchAuctionLotResolved's own comment on why
  /// that used to be a real bug).
  final int? spent;
  final int? remaining;

  AuctionLotResolvedRes({
    required this.lotId,
    required this.outcome,
    this.soldPrice,
    this.soldTo,
    this.spent,
    this.remaining,
  });

  factory AuctionLotResolvedRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionLotResolvedResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionLotResolvedResToJson(this);
}

@JsonSerializable()
class AuctionResumedRes {
  final DateTime? currentLotEndsAt;

  AuctionResumedRes({this.currentLotEndsAt});

  factory AuctionResumedRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionResumedResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionResumedResToJson(this);
}
