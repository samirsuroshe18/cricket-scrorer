import 'package:json_annotation/json_annotation.dart';

part 'auction_setup_res.g.dart';

/// A tournament's current auction setup — squad rules plus the resolved
/// owner list. `minSquadSize`/`maxSquadSize`/`categoryCaps` are `null`
/// until ever set, independently of each other and of `owners`.
@JsonSerializable(explicitToJson: true)
class AuctionSetupRes {
  final String tournamentId;
  final int? minSquadSize;
  final int? maxSquadSize;
  final Map<String, int>? categoryCaps;
  final List<AuctionOwnerRes> owners;

  AuctionSetupRes({
    required this.tournamentId,
    this.minSquadSize,
    this.maxSquadSize,
    this.categoryCaps,
    required this.owners,
  });

  factory AuctionSetupRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionSetupResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionSetupResToJson(this);
}

/// One resolved owner row — team and user names included for display,
/// exactly as `docs/api.md`'s response example shows.
@JsonSerializable()
class AuctionOwnerRes {
  final String teamId;
  final String teamName;
  final String userId;
  final String userName;
  final int budget;

  AuctionOwnerRes({
    required this.teamId,
    required this.teamName,
    required this.userId,
    required this.userName,
    required this.budget,
  });

  factory AuctionOwnerRes.fromJson(Map<String, dynamic> json) =>
      _$AuctionOwnerResFromJson(json);

  Map<String, dynamic> toJson() => _$AuctionOwnerResToJson(this);
}
