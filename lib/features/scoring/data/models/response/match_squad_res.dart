import 'package:json_annotation/json_annotation.dart';

part 'match_squad_res.g.dart';

@JsonSerializable()
class SquadSidePlayerRes {
  final String playerId;
  final String name;
  final String role;
  final int? jerseyNumber;

  SquadSidePlayerRes({
    required this.playerId,
    required this.name,
    required this.role,
    this.jerseyNumber,
  });

  factory SquadSidePlayerRes.fromJson(Map<String, dynamic> json) =>
      _$SquadSidePlayerResFromJson(json);

  Map<String, dynamic> toJson() => _$SquadSidePlayerResToJson(this);
}

/// One side of a saved match squad — also the `data` of
/// `PATCH …/squad/:side/playing-xi`, whose extra `side` key is ignored.
@JsonSerializable(explicitToJson: true)
class SquadSideRes {
  final String teamId;

  /// Empty for a side that was never saved.
  @JsonKey(defaultValue: <SquadSidePlayerRes>[])
  final List<SquadSidePlayerRes> players;
  final String? captainId;
  final String? viceCaptainId;
  final String? keeperId;

  /// Player ids. **Null means the scorer never chose an XI** (nothing is
  /// restricted); an empty list is a deliberately empty XI. Never collapse the
  /// two — only a set XI restricts who scoring accepts.
  final List<String>? playingXI;

  /// ISO timestamp of the last `PUT` for this side; null if never saved.
  final String? savedAt;

  SquadSideRes({
    required this.teamId,
    this.players = const [],
    this.captainId,
    this.viceCaptainId,
    this.keeperId,
    this.playingXI,
    this.savedAt,
  });

  factory SquadSideRes.fromJson(Map<String, dynamic> json) =>
      _$SquadSideResFromJson(json);

  Map<String, dynamic> toJson() => _$SquadSideResToJson(this);
}

/// `data` of `GET /v1/match/:matchId/squad`.
@JsonSerializable(explicitToJson: true)
class MatchSquadRes {
  final String matchId;

  /// True once an innings exists — from then on the squad is saved with the
  /// playing-xi `PATCH` (ids only), not `PUT`.
  @JsonKey(defaultValue: false)
  final bool inningsStarted;
  final SquadSideRes teamA;
  final SquadSideRes teamB;

  MatchSquadRes({
    required this.matchId,
    this.inningsStarted = false,
    required this.teamA,
    required this.teamB,
  });

  factory MatchSquadRes.fromJson(Map<String, dynamic> json) =>
      _$MatchSquadResFromJson(json);

  Map<String, dynamic> toJson() => _$MatchSquadResToJson(this);
}
