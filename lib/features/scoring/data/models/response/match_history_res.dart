import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'match_history_res.g.dart';

/// A `{id, name}` reference to a user — `MatchHistoryItem.createdBy`/
/// `.assignedScorer`, `ScorerCandidatesRes`, and `AssignScorerRes` all share
/// this shape since they're the same wire contract from the same feature
/// slice, unlike `OrganizationRef`/`OrganizationUserRef` (kept distinct
/// because those two coincidentally match across unrelated features).
@JsonSerializable()
class MatchUserRef {
  final String id;
  final String name;

  MatchUserRef({required this.id, required this.name});

  factory MatchUserRef.fromJson(Map<String, dynamic> json) =>
      _$MatchUserRefFromJson(json);

  Map<String, dynamic> toJson() => _$MatchUserRefToJson(this);
}

/// One row of `GET /v1/match/history`. `result` is only ever populated for a
/// `completed` match — an `abandoned` one has no winner, and the server sends
/// `null` for it — so the history/home screen must not assume a non-null
/// result just because a match is no longer live.
///
/// `teamA`/`teamB` are [TeamRef] (id + name), not the name-only
/// [PublicTeamRef] `getPublicMatch`/`getMatchScorecard` use — reopening the
/// console for a still-live match needs the ids, the same shape `create`
/// originally returned them in.
@JsonSerializable(explicitToJson: true)
class MatchHistoryItem {
  final String matchId;
  final TeamRef teamA;
  final TeamRef teamB;

  /// Null for matches created before share codes existed — see the scorer
  /// screen's share-icon guard, which hides the icon rather than offer to
  /// copy null.
  final String? joinCode;
  final int totalOvers;

  /// `upcoming` / `live` / `innings_break` / `completed` / `abandoned` — the
  /// same enum `Match.status` carries server-side. What a tap on this card
  /// routes to: the live states reopen the scoring console, the two terminal
  /// ones open the result screen.
  final String status;
  final MatchResultInfo? result;

  /// `teamA` / `teamB`, or null when the toss was skipped — same pair, same
  /// meaning, as `CreateMatchRes.tossWinner`/`tossDecision`. Needed here so
  /// reopening a live match from history can still show the toss line.
  final String? tossWinner;

  /// `bat` / `bowl`. Null exactly when [tossWinner] is null.
  final String? tossDecision;

  /// Who created this match — always present. Lets a client render
  /// "Assigned by X" when it differs from the viewer's own id (see
  /// [assignedScorer] below and docs/api.md's delegated-scoring contract).
  final MatchUserRef? createdBy;

  /// Non-null once the creator (or a qualifying org owner) has delegated
  /// scoring for this match to someone else. Null for every match created
  /// before this feature and every ad-hoc match since.
  final MatchUserRef? assignedScorer;

  final String createdAt;

  MatchHistoryItem({
    required this.matchId,
    required this.teamA,
    required this.teamB,
    this.joinCode,
    required this.totalOvers,
    required this.status,
    this.result,
    this.tossWinner,
    this.tossDecision,
    this.createdBy,
    this.assignedScorer,
    required this.createdAt,
  });

  /// Used after a successful `PATCH /v1/match/:matchId/scorer` to patch the
  /// cached list entry in place, so a controller doesn't need a full reload
  /// just to reflect the new assignment.
  MatchHistoryItem copyWith({MatchUserRef? assignedScorer}) => MatchHistoryItem(
    matchId: matchId,
    teamA: teamA,
    teamB: teamB,
    joinCode: joinCode,
    totalOvers: totalOvers,
    status: status,
    result: result,
    tossWinner: tossWinner,
    tossDecision: tossDecision,
    createdBy: createdBy,
    assignedScorer: assignedScorer,
    createdAt: createdAt,
  );

  factory MatchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$MatchHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$MatchHistoryItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MatchHistoryRes {
  final List<MatchHistoryItem> matches;
  final int page;
  final int limit;
  final int total;

  MatchHistoryRes({
    required this.matches,
    required this.page,
    required this.limit,
    required this.total,
  });

  /// Whether a subsequent page exists — the pull-to-refresh list's "load
  /// more" trigger reads this rather than comparing `matches.length` against
  /// `limit`, which would be wrong on the exact-multiple boundary (a `total`
  /// of exactly `page * limit` has no next page, but that comparison alone
  /// can't tell that apart from "the next page happens to be full too").
  bool get hasMore => page * limit < total;

  factory MatchHistoryRes.fromJson(Map<String, dynamic> json) =>
      _$MatchHistoryResFromJson(json);

  Map<String, dynamic> toJson() => _$MatchHistoryResToJson(this);
}
