import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_player_view_res.g.dart';

/// A roster row as a linked player sees it — no invite or claim state.
@JsonSerializable()
class TeamPlayerRosterPlayer {
  final String playerId;
  final String playerName;
  final String role;
  final int? jerseyNumber;
  @JsonKey(defaultValue: false)
  final bool isCaptain;
  @JsonKey(defaultValue: false)
  final bool isViceCaptain;

  TeamPlayerRosterPlayer({
    required this.playerId,
    required this.playerName,
    required this.role,
    this.jerseyNumber,
    this.isCaptain = false,
    this.isViceCaptain = false,
  });

  factory TeamPlayerRosterPlayer.fromJson(Map<String, dynamic> json) =>
      _$TeamPlayerRosterPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$TeamPlayerRosterPlayerToJson(this);
}

/// `GET /v1/team/:teamId/player-view` — the read-only team profile.
@JsonSerializable(explicitToJson: true)
class TeamPlayerViewRes {
  final String teamId;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final TeamStatsRes? stats;
  final String? captainId;
  final String? viceCaptainId;
  final List<TeamPlayerRosterPlayer> roster;

  TeamPlayerViewRes({
    required this.teamId,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.stats,
    this.captainId,
    this.viceCaptainId,
    required this.roster,
  });

  factory TeamPlayerViewRes.fromJson(Map<String, dynamic> json) =>
      _$TeamPlayerViewResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamPlayerViewResToJson(this);
}
