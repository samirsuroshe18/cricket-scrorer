import 'package:json_annotation/json_annotation.dart';

part 'my_players_res.g.dart';

/// One row of `GET /v1/player` — a player the caller created. `onTeam` is
/// only sent when the request named a team.
@JsonSerializable()
class MyPlayerRow {
  final String playerId;
  final String playerName;

  /// `batsman` / `bowler` / `allrounder` / `wicketkeeper` / `unknown`.
  @JsonKey(defaultValue: 'unknown')
  final String role;
  final int? jerseyNumber;

  /// Whether *someone* has linked this player to an account — never who.
  @JsonKey(defaultValue: false)
  final bool isClaimed;

  /// Already on the roster of the team the request named.
  @JsonKey(defaultValue: false)
  final bool onTeam;

  MyPlayerRow({
    required this.playerId,
    required this.playerName,
    this.role = 'unknown',
    this.jerseyNumber,
    this.isClaimed = false,
    this.onTeam = false,
  });

  factory MyPlayerRow.fromJson(Map<String, dynamic> json) =>
      _$MyPlayerRowFromJson(json);

  Map<String, dynamic> toJson() => _$MyPlayerRowToJson(this);
}

/// `data` of `GET /v1/player`.
@JsonSerializable()
class MyPlayersRes {
  final List<MyPlayerRow> players;
  final int page;
  final int limit;
  final int total;

  MyPlayersRes({
    required this.players,
    required this.page,
    required this.limit,
    required this.total,
  });

  bool get hasMore => page * limit < total;

  factory MyPlayersRes.fromJson(Map<String, dynamic> json) =>
      _$MyPlayersResFromJson(json);

  Map<String, dynamic> toJson() => _$MyPlayersResToJson(this);
}
