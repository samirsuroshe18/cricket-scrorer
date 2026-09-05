import 'package:json_annotation/json_annotation.dart';

part 'organization_detail_res.g.dart';

/// A user reference `{id, name}` — the shape `owner` and each `members`
/// entry share on `POST /v1/organization` and `GET /v1/organization/:orgId`.
@JsonSerializable()
class OrganizationUserRef {
  final String id;
  final String name;

  OrganizationUserRef({required this.id, required this.name});

  factory OrganizationUserRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationUserRefFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationUserRefToJson(this);
}

/// One row of `OrganizationDetailRes.members` — a user plus their role in
/// this specific organization.
@JsonSerializable()
class OrganizationMemberRes {
  final String id;
  final String name;

  /// `'owner'` or `'member'` — see docs/api.md's `## Organization` section.
  final String role;

  OrganizationMemberRes({
    required this.id,
    required this.name,
    required this.role,
  });

  factory OrganizationMemberRes.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMemberResFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationMemberResToJson(this);
}

/// One row of `OrganizationDetailRes.teams` — deliberately lighter than
/// `TeamSummary`: this list never needs to distinguish "which org" (it's
/// already scoped to one) the way the my-teams picker does.
@JsonSerializable()
class OrganizationTeamRef {
  final String id;
  final String name;
  final String? shortName;

  OrganizationTeamRef({required this.id, required this.name, this.shortName});

  factory OrganizationTeamRef.fromJson(Map<String, dynamic> json) =>
      _$OrganizationTeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationTeamRefToJson(this);
}

/// `POST /v1/organization` and `GET /v1/organization/:orgId` share this
/// exact response shape — see docs/api.md.
@JsonSerializable(explicitToJson: true)
class OrganizationDetailRes {
  final String id;
  final String name;
  final OrganizationUserRef owner;
  final List<OrganizationMemberRes> members;
  final List<OrganizationTeamRef> teams;

  OrganizationDetailRes({
    required this.id,
    required this.name,
    required this.owner,
    required this.members,
    required this.teams,
  });

  factory OrganizationDetailRes.fromJson(Map<String, dynamic> json) =>
      _$OrganizationDetailResFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationDetailResToJson(this);
}
