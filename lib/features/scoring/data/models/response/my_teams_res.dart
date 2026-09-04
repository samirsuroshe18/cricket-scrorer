import 'package:json_annotation/json_annotation.dart';

part 'my_teams_res.g.dart';

/// One row of `GET /v1/team` — the source list for the "reuse this team"
/// picker on `CreateMatchScreen`. A team appears once regardless of how many
/// matches reference it.
@JsonSerializable()
class TeamSummary {
  final String id;
  final String name;
  final String? shortName;

  TeamSummary({required this.id, required this.name, this.shortName});

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
