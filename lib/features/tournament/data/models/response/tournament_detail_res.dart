import 'package:json_annotation/json_annotation.dart';

part 'tournament_detail_res.g.dart';

/// `{id, name}` — the tournament's owning organization, as returned by
/// `GET /v1/tournament/:tournamentId`. Deliberately lighter than
/// `OrganizationDetailRes` (no owner, no members) — see
/// `TournamentDetailController` for how `isOwner` is derived by separately
/// fetching the full organization via this id.
@JsonSerializable()
class TournamentOrganizationRef {
  final String id;
  final String name;

  TournamentOrganizationRef({required this.id, required this.name});

  factory TournamentOrganizationRef.fromJson(Map<String, dynamic> json) =>
      _$TournamentOrganizationRefFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentOrganizationRefToJson(this);
}

/// One row of `TournamentDetailRes.teams` — an enrolled team, with the
/// timestamp it joined. Distinct from `OrganizationTeamRef` (no `joinedAt`)
/// even though both are `{id, name, shortName}` otherwise — matches this
/// codebase's established pattern of each feature owning its own
/// team-reference shape rather than sharing one across features.
@JsonSerializable()
class TournamentTeamRef {
  final String id;
  final String name;
  final String? shortName;
  final DateTime joinedAt;

  TournamentTeamRef({
    required this.id,
    required this.name,
    this.shortName,
    required this.joinedAt,
  });

  factory TournamentTeamRef.fromJson(Map<String, dynamic> json) =>
      _$TournamentTeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentTeamRefToJson(this);
}

/// `GET /v1/tournament/:tournamentId` — see docs/api.md.
@JsonSerializable(explicitToJson: true)
class TournamentDetailRes {
  final String id;
  final String name;

  /// `knockout` | `round_robin` | `league`.
  final String format;

  /// `upcoming` | `ongoing` | `completed`.
  final String status;
  final TournamentOrganizationRef organization;
  final List<TournamentTeamRef> teams;
  final DateTime createdAt;

  TournamentDetailRes({
    required this.id,
    required this.name,
    required this.format,
    required this.status,
    required this.organization,
    required this.teams,
    required this.createdAt,
  });

  factory TournamentDetailRes.fromJson(Map<String, dynamic> json) =>
      _$TournamentDetailResFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentDetailResToJson(this);
}
