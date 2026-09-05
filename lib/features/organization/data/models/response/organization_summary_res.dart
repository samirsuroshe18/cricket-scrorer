import 'package:json_annotation/json_annotation.dart';

part 'organization_summary_res.g.dart';

/// One row of `GET /v1/organization` — the list of orgs the caller owns or
/// belongs to. Deliberately lighter than `OrganizationDetailRes`: the list
/// screen never needs the full member/team rows, just enough to decide
/// which org to open.
@JsonSerializable()
class OrganizationSummaryRes {
  final String id;
  final String name;

  /// `'owner'` or `'member'` — the caller's own role in this org.
  final String myRole;
  final int memberCount;
  final int teamCount;

  OrganizationSummaryRes({
    required this.id,
    required this.name,
    required this.myRole,
    required this.memberCount,
    required this.teamCount,
  });

  factory OrganizationSummaryRes.fromJson(Map<String, dynamic> json) =>
      _$OrganizationSummaryResFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationSummaryResToJson(this);
}

/// `GET /v1/organization` — the envelope around [OrganizationSummaryRes].
@JsonSerializable(explicitToJson: true)
class MyOrganizationsRes {
  final List<OrganizationSummaryRes> organizations;

  MyOrganizationsRes({required this.organizations});

  factory MyOrganizationsRes.fromJson(Map<String, dynamic> json) =>
      _$MyOrganizationsResFromJson(json);

  Map<String, dynamic> toJson() => _$MyOrganizationsResToJson(this);
}
