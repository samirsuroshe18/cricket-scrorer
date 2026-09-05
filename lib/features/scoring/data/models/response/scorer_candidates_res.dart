import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart'
    show MatchUserRef;
import 'package:json_annotation/json_annotation.dart';

part 'scorer_candidates_res.g.dart';

/// `GET /v1/match/:matchId/scorer-candidates` — the members of whichever
/// org(s) own teamA/teamB, empty when neither team is org-linked.
@JsonSerializable(explicitToJson: true)
class ScorerCandidatesRes {
  final List<MatchUserRef> candidates;

  ScorerCandidatesRes({required this.candidates});

  factory ScorerCandidatesRes.fromJson(Map<String, dynamic> json) =>
      _$ScorerCandidatesResFromJson(json);

  Map<String, dynamic> toJson() => _$ScorerCandidatesResToJson(this);
}
