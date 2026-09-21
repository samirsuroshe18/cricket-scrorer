import 'package:json_annotation/json_annotation.dart';

part 'created_team_res.g.dart';

/// `data` of `POST /v1/team`. The response also carries `logoUrl` and
/// `organization` (both null for a standalone team); they are ignored
/// because the Teams tab reloads `GET /v1/team` rather than patching its list.
@JsonSerializable()
class CreatedTeamRes {
  final String id;
  final String name;
  final String? shortName;

  CreatedTeamRes({required this.id, required this.name, this.shortName});

  factory CreatedTeamRes.fromJson(Map<String, dynamic> json) =>
      _$CreatedTeamResFromJson(json);

  Map<String, dynamic> toJson() => _$CreatedTeamResToJson(this);
}
