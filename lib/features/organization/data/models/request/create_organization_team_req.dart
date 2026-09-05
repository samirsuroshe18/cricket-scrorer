import 'package:json_annotation/json_annotation.dart';

part 'create_organization_team_req.g.dart';

@JsonSerializable()
class CreateOrganizationTeamReq {
  final String name;
  final String? shortName;

  CreateOrganizationTeamReq({required this.name, this.shortName});

  factory CreateOrganizationTeamReq.fromJson(Map<String, dynamic> json) =>
      _$CreateOrganizationTeamReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrganizationTeamReqToJson(this);
}
