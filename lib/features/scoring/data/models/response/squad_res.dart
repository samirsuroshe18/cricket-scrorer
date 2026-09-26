import 'package:json_annotation/json_annotation.dart';

part 'squad_res.g.dart';

@JsonSerializable()
class SquadPlayerRes {
  final String playerId;
  final String name;
  final String role;

  SquadPlayerRes({
    required this.playerId,
    required this.name,
    required this.role,
  });

  factory SquadPlayerRes.fromJson(Map<String, dynamic> json) =>
      _$SquadPlayerResFromJson(json);

  Map<String, dynamic> toJson() => _$SquadPlayerResToJson(this);
}

/// Response of `PUT /v1/match/:matchId/squad/:side` — the saved side with
/// resolved player ids. The three designation ids are null when unset.
@JsonSerializable(explicitToJson: true)
class SquadRes {
  final String side;
  final List<SquadPlayerRes> players;
  final String? captainId;
  final String? viceCaptainId;
  final String? keeperId;

  SquadRes({
    required this.side,
    required this.players,
    this.captainId,
    this.viceCaptainId,
    this.keeperId,
  });

  factory SquadRes.fromJson(Map<String, dynamic> json) =>
      _$SquadResFromJson(json);

  Map<String, dynamic> toJson() => _$SquadResToJson(this);
}
