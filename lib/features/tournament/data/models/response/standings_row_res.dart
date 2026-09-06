import 'package:json_annotation/json_annotation.dart';

part 'standings_row_res.g.dart';

/// One row of `GET /v1/tournament/:tournamentId/standings`' `standings`
/// array — see `docs/api.md`'s Fixture section. Already sorted by the
/// backend (points desc, then net run rate desc, then team name asc), so
/// this model carries no sort logic of its own — the screen just renders
/// the list in the order it arrives.
@JsonSerializable()
class StandingsRowRes {
  final String teamId;
  final String teamName;
  final int played;
  final int won;
  final int lost;
  final int tied;
  final int noResult;
  final int points;

  /// Net run rate, already rounded to 3 decimal places server-side.
  final double nrr;

  StandingsRowRes({
    required this.teamId,
    required this.teamName,
    required this.played,
    required this.won,
    required this.lost,
    required this.tied,
    required this.noResult,
    required this.points,
    required this.nrr,
  });

  factory StandingsRowRes.fromJson(Map<String, dynamic> json) =>
      _$StandingsRowResFromJson(json);

  Map<String, dynamic> toJson() => _$StandingsRowResToJson(this);
}
