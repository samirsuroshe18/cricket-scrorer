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

  AuctionLotResolvedRes({
    required this.lotId,
    required this.outcome,
    this.soldPrice,
    this.soldTo,
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
