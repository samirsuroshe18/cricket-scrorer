import 'package:json_annotation/json_annotation.dart';

part 'team_profile_res.g.dart';

/// One row of `GET /v1/team/:teamId`'s `roster` — the same lightweight
/// identity fields already embedded in `Scorecard.battingScores`/
/// `bowlingScores`; there is no separate, heavier "player-summary" object to
/// reuse for a roster row. See docs/api.md's "Team profile" section.
@JsonSerializable()
class TeamRosterPlayer {
  final String playerId;
  final String playerName;

  /// Null when the player has never been assigned one.
  final int? jerseyNumber;

  /// `batsman` / `bowler` / `allrounder` / `wicketkeeper` / `unknown`.
  final String role;

  TeamRosterPlayer({
    required this.playerId,
    required this.playerName,
    this.jerseyNumber,
    required this.role,
  });

  factory TeamRosterPlayer.fromJson(Map<String, dynamic> json) =>
      _$TeamRosterPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$TeamRosterPlayerToJson(this);
}

/// `GET /v1/team/:teamId` — a team's display identity plus every player
/// accumulated onto its roster across every match it has been attached to
/// (directly, or via `teamAId`/`teamBId` reuse on match creation).
/// `roster` is `[]`, not an error, for a team no one has been rostered onto
/// yet. Deliberately carries no aggregate stats (wins/losses/win%) — v1 is
/// roster + past results only, see docs/api.md.
@JsonSerializable(explicitToJson: true)
class TeamProfileRes {
  final String teamId;
  final String name;
  final String? shortName;
  final List<TeamRosterPlayer> roster;

  TeamProfileRes({
    required this.teamId,
    required this.name,
    this.shortName,
    required this.roster,
  });

  factory TeamProfileRes.fromJson(Map<String, dynamic> json) =>
      _$TeamProfileResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamProfileResToJson(this);
}
