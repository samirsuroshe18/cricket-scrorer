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

/// One delivery in [CurrentInningsSummary.recentBalls] — just what a ball
/// dot needs to draw itself, not the full `BallEvent`.
@JsonSerializable()
class RecentBall {
  /// `runs + extras` — everything the delivery added to the score.
  final int totalRuns;

  /// `wide` / `no_ball`, or null for a legal delivery.
  final String? extraType;
  final bool isWicket;

  RecentBall({
    required this.totalRuns,
    this.extraType,
    required this.isWicket,
  });

  factory RecentBall.fromJson(Map<String, dynamic> json) =>
      _$RecentBallFromJson(json);

  Map<String, dynamic> toJson() => _$RecentBallToJson(this);
}

/// `MatchHistoryItem.currentInnings` — a lightweight score summary, not the
/// full `innings` shape `getPublicMatch`/the spectator socket return
/// (no `extras`/`strike`/`partnership`/`bowler`; those need a
/// `BallEvent` read the history list deliberately skips to stay cheap across
/// a page of matches). Read straight off the `Inning` document's own running
/// totals server-side, per docs/api.md.
///
/// [battingTeam], [target] and [recentBalls] were added for the Home
/// dashboard's live cards; all three tolerate an older server that omits
/// them, so a stale backend degrades to the plain score instead of failing
/// the whole history parse.
@JsonSerializable(explicitToJson: true)
class CurrentInningsSummary {
  final int inningsNumber;

  /// `teamA` / `teamB` — which side [totalRuns] belongs to. Null only from a
  /// server that predates the field.
  final String? battingTeam;
  final int totalRuns;
  final int wickets;

  /// `"N.n"`, e.g. `"18.2"` — already formatted server-side, same convention
  /// as every other overs string this app displays.
  final String overs;

  /// Runs needed to win. Only ever set in innings 2; null while the first
  /// side bats.
  final int? target;

  /// The last up-to-six deliveries, oldest first. Empty for anything but a
  /// `live` match that has had a ball bowled.
  final List<RecentBall> recentBalls;

  CurrentInningsSummary({
    required this.inningsNumber,
    this.battingTeam,
    required this.totalRuns,
    required this.wickets,
    required this.overs,
    this.target,
    this.recentBalls = const [],
  });

  factory CurrentInningsSummary.fromJson(Map<String, dynamic> json) =>
      _$CurrentInningsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentInningsSummaryToJson(this);
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

  /// `local` / `syncing` / `synced` / `conflict` — `Match.syncStatus`
  /// verbatim, per docs/api.md. Always present, but `local` is heavily
  /// overloaded: it's both the default a match never touched by
  /// `POST /:matchId/sync` keeps forever (i.e. most matches scored entirely
  /// online) *and* what a genuinely queued-but-not-yet-synced match sits at.
  /// Those two cases aren't distinguishable from this field alone, so
  /// [MatchHistoryCard] only badges `conflict`/`syncing` — the two
  /// unambiguous states — and treats `local` the same as `synced`: no
  /// badge, rather than incorrectly flagging every online-scored match as
  /// "not synced".
  final String syncStatus;

  /// Non-null only while [status] is `live`/`innings_break` — see
  /// [CurrentInningsSummary] and docs/api.md.
  final CurrentInningsSummary? currentInnings;

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
    required this.syncStatus,
    this.currentInnings,
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
    syncStatus: syncStatus,
    currentInnings: currentInnings,
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
