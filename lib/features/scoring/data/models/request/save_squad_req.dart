import 'package:json_annotation/json_annotation.dart';

part 'save_squad_req.g.dart';

/// One player of a squad, as sent to `PUT /v1/match/:matchId/squad/:side`.
/// [playerId] is only set for a returning player picked from a team's roster;
/// the server resolves identity by name either way.
@JsonSerializable(includeIfNull: false)
class SquadPlayerReq {
  final String? playerId;
  final String name;

  /// `batsman` / `bowler` / `allrounder`.
  final String role;

  SquadPlayerReq({this.playerId, required this.name, required this.role});

  factory SquadPlayerReq.fromJson(Map<String, dynamic> json) =>
      _$SquadPlayerReqFromJson(json);

  Map<String, dynamic> toJson() => _$SquadPlayerReqToJson(this);
}

/// Body of `PUT /v1/match/:matchId/squad/:side`. [side] (`teamA` / `teamB`)
/// belongs to the path, so it is kept off the JSON body. [captain],
/// [viceCaptain] and [keeper] name a player in [players].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class SaveSquadReq {
  @JsonKey(includeToJson: false)
  final String side;
  final List<SquadPlayerReq> players;
  final String? captain;
  final String? viceCaptain;
  final String? keeper;

  SaveSquadReq({
    required this.side,
    required this.players,
    this.captain,
    this.viceCaptain,
    this.keeper,
  });

  factory SaveSquadReq.fromJson(Map<String, dynamic> json) =>
      _$SaveSquadReqFromJson(json);

  Map<String, dynamic> toJson() => _$SaveSquadReqToJson(this);
}
