import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart'
    show MatchUserRef;
import 'package:json_annotation/json_annotation.dart';

part 'assign_scorer_res.g.dart';

/// `PATCH /v1/match/:matchId/scorer`'s response. [assignedScorer] is null
/// after a clear (`scorerId: null` in the request).
@JsonSerializable(explicitToJson: true)
class AssignScorerRes {
  final String matchId;
  final MatchUserRef? assignedScorer;

  AssignScorerRes({required this.matchId, this.assignedScorer});

  factory AssignScorerRes.fromJson(Map<String, dynamic> json) =>
      _$AssignScorerResFromJson(json);

  Map<String, dynamic> toJson() => _$AssignScorerResToJson(this);
}
