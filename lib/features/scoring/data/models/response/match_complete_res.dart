import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:json_annotation/json_annotation.dart';

part 'match_complete_res.g.dart';

@JsonSerializable()
class MatchCompleteInningsSummary {
  final int inningsNumber;
  final String battingTeam;
  final int totalRuns;
  final int wickets;
  final String overs;

  MatchCompleteInningsSummary({
    required this.inningsNumber,
    required this.battingTeam,
    required this.totalRuns,
    required this.wickets,
    required this.overs,
  });

  factory MatchCompleteInningsSummary.fromJson(Map<String, dynamic> json) =>
      _$MatchCompleteInningsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MatchCompleteInningsSummaryToJson(this);
}

/// The `match:complete` socket event. Deliberately thin on the server side —
/// just enough for a result banner — so this is read as a trigger to fetch
/// [ScorecardRes], not as the data source for the result screen itself. See
/// docs/api.md's note on why the socket payload and the GET response are not
/// meant to be the same shape.
@JsonSerializable(explicitToJson: true)
class MatchCompleteRes {
  final String matchId;
  final MatchResultInfo result;
  final List<MatchCompleteInningsSummary> innings;

  MatchCompleteRes({
    required this.matchId,
    required this.result,
    required this.innings,
  });

  factory MatchCompleteRes.fromJson(Map<String, dynamic> json) =>
      _$MatchCompleteResFromJson(json);

  Map<String, dynamic> toJson() => _$MatchCompleteResToJson(this);
}
