import 'package:json_annotation/json_annotation.dart';

part 'enroll_tournament_team_req.g.dart';

@JsonSerializable()
class EnrollTournamentTeamReq {
  final String teamId;

  EnrollTournamentTeamReq({required this.teamId});

  factory EnrollTournamentTeamReq.fromJson(Map<String, dynamic> json) =>
      _$EnrollTournamentTeamReqFromJson(json);

  Map<String, dynamic> toJson() => _$EnrollTournamentTeamReqToJson(this);
}
