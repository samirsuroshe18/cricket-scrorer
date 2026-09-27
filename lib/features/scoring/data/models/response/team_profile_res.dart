import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart'
    show OrganizationRef;
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

  /// Team-level defaults (`Team.captainId` / `viceCaptainId`), not the
  /// per-match squad designations. Absent on an older server, so `false`.
  @JsonKey(defaultValue: false)
  final bool isCaptain;
  @JsonKey(defaultValue: false)
  final bool isViceCaptain;

  /// `pending` while the player has an unanswered invite to a real account;
  /// null otherwise (and on an older server that doesn't send it).
  final String? inviteStatus;

  TeamRosterPlayer({
    required this.playerId,
    required this.playerName,
    this.jerseyNumber,
    required this.role,
    this.isCaptain = false,
    this.isViceCaptain = false,
    this.inviteStatus,
  });

  factory TeamRosterPlayer.fromJson(Map<String, dynamic> json) =>
      _$TeamRosterPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$TeamRosterPlayerToJson(this);
}

/// `stats` of `GET /v1/team/:teamId`, computed server-side from the team's
/// completed matches. `form` is up to the last 5 outcomes, newest first, coded
/// `W`/`L`/`T`/`N`.
@JsonSerializable()
class TeamStatsRes {
  @JsonKey(defaultValue: 0)
  final int played;
  @JsonKey(defaultValue: 0)
  final int won;
  @JsonKey(defaultValue: 0)
  final int lost;
  @JsonKey(defaultValue: 0)
  final int tied;
  @JsonKey(defaultValue: 0)
  final int noResult;
  @JsonKey(defaultValue: 0.0)
  final double winPercentage;
  @JsonKey(defaultValue: <String>[])
  final List<String> form;

  TeamStatsRes({
    required this.played,
    required this.won,
    required this.lost,
    required this.tied,
    required this.noResult,
    required this.winPercentage,
    required this.form,
  });

  factory TeamStatsRes.fromJson(Map<String, dynamic> json) =>
      _$TeamStatsResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamStatsResToJson(this);
}

/// `GET /v1/team/:teamId` — a team's display identity plus every player
/// accumulated onto its roster across every match it has been attached to
/// (directly, or via `teamAId`/`teamBId` reuse on match creation).
/// `roster` is `[]`, not an error, for a team no one has been rostered onto
/// yet. `stats` is null only when talking to a server that predates it.
/// `organization` is non-null
/// when this team belongs to one — see `TeamSummary.organization`'s own
/// comment for why this reuses [OrganizationRef] rather than a second
/// identical type.
@JsonSerializable(explicitToJson: true)
class TeamProfileRes {
  final String teamId;
  final String name;
  final String? shortName;

  /// Cloudinary URL from `POST /v1/team/:teamId/logo`, or `null`.
  final String? logoUrl;
  final OrganizationRef? organization;

  /// True only for who may rename/delete this team — the team's creator
  /// (standalone) or its organization's owner (organization team). Everyone
  /// else who can open this profile can still view it and change its logo.
  final bool canManage;
  final List<TeamRosterPlayer> roster;
  final TeamStatsRes? stats;

  /// Team-level captain / vice-captain player ids, or null when unset.
  final String? captainId;
  final String? viceCaptainId;

  TeamProfileRes({
    required this.teamId,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.organization,
    required this.canManage,
    required this.roster,
    this.stats,
    this.captainId,
    this.viceCaptainId,
  });

  factory TeamProfileRes.fromJson(Map<String, dynamic> json) =>
      _$TeamProfileResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamProfileResToJson(this);
}
