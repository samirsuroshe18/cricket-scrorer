import 'package:json_annotation/json_annotation.dart';

part 'playing_for_teams_res.g.dart';

/// One row of `GET /v1/team/playing-for` — a team the caller is on the roster
/// of through a linked player, under the name that player carries there.
@JsonSerializable()
class PlayingForTeam {
  final String id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String myPlayerName;

  PlayingForTeam({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    required this.myPlayerName,
  });

  factory PlayingForTeam.fromJson(Map<String, dynamic> json) =>
      _$PlayingForTeamFromJson(json);

  Map<String, dynamic> toJson() => _$PlayingForTeamToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlayingForTeamsRes {
  final List<PlayingForTeam> teams;
  final int page;
  final int limit;
  final int total;

  PlayingForTeamsRes({
    required this.teams,
    required this.page,
    required this.limit,
    required this.total,
  });

  bool get hasMore => page * limit < total;

  factory PlayingForTeamsRes.fromJson(Map<String, dynamic> json) =>
      _$PlayingForTeamsResFromJson(json);

  Map<String, dynamic> toJson() => _$PlayingForTeamsResToJson(this);
}
