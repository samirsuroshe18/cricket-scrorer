import 'package:json_annotation/json_annotation.dart';

part 'create_team_req.g.dart';

/// Body of `POST /v1/team`. Same two fields as `CreateOrganizationTeamReq`;
/// kept separate because the two endpoints are different wire contracts that
/// only coincidentally match today.
@JsonSerializable()
class CreateTeamReq {
  final String name;
  final String? shortName;

  CreateTeamReq({required this.name, this.shortName});

  factory CreateTeamReq.fromJson(Map<String, dynamic> json) =>
      _$CreateTeamReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTeamReqToJson(this);
}
