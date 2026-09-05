import 'package:json_annotation/json_annotation.dart';

part 'my_teams_res.g.dart';

/// The `{id, name}` an org-owned `Team` carries — shared by [TeamSummary]
/// and `TeamProfileRes`. Named distinctly from
/// `organization/OrganizationUserRef` even though the shape is identical:
/// that one is a *user* reference (owner/member), this one is an
/// *organization* reference. Collapsing them into one shared type would
/// couple two features' wire contracts that only coincidentally match today.
@JsonSerializable()
class OrganizationRef {
  final String id;
  final String name;

  OrganizationRef({required this.id, required this.name});

  factory OrganizationRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationRefFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationRefToJson(this);
}

/// One row of `GET /v1/team` — the source list for the "reuse this team"
/// picker on `CreateMatchScreen`. A team appears once regardless of how many
/// matches reference it.
@JsonSerializable(explicitToJson: true)
class TeamSummary {
  final String id;
  final String name;
  final String? shortName;

  /// Non-null when this team belongs to an organization the caller is a
  /// member of — see docs/api.md's `## Organization` section. Null for a
  /// standalone team, which is every team created before this feature
  /// shipped, and every ad-hoc team created since.
  final OrganizationRef? organization;

  TeamSummary({
    required this.id,
    required this.name,
    this.shortName,
    this.organization,
  });

  factory TeamSummary.fromJson(Map<String, dynamic> json) =>
      _$TeamSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$TeamSummaryToJson(this);
}

/// `GET /v1/team` — the caller's own teams.
@JsonSerializable(explicitToJson: true)
class MyTeamsRes {
  final List<TeamSummary> teams;

  MyTeamsRes({required this.teams});

  factory MyTeamsRes.fromJson(Map<String, dynamic> json) =>
      _$MyTeamsResFromJson(json);

  Map<String, dynamic> toJson() => _$MyTeamsResToJson(this);
}
