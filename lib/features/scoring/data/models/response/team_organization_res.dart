import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart'
    show OrganizationRef;
import 'package:json_annotation/json_annotation.dart';

part 'team_organization_res.g.dart';

/// `PATCH /v1/team/:teamId/organization`'s response — deliberately smaller
/// than [TeamSummary]: attach/detach only ever needs to confirm the new
/// organization state, not re-send the team's name/shortName.
@JsonSerializable(explicitToJson: true)
class TeamOrganizationRes {
  final String id;
  final OrganizationRef? organization;

  TeamOrganizationRes({required this.id, this.organization});

  factory TeamOrganizationRes.fromJson(Map<String, dynamic> json) =>
      _$TeamOrganizationResFromJson(json);

  Map<String, dynamic> toJson() => _$TeamOrganizationResToJson(this);
}
