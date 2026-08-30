import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'match_history_res.g.dart';

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
  final int totalOvers;

  /// `upcoming` / `live` / `innings_break` / `completed` / `abandoned` — the
  /// same enum `Match.status` carries server-side. What a tap on this card
  /// routes to: the live states reopen the scoring console, the two terminal
  /// ones open the result screen.
  final String status;
  final MatchResultInfo? result;
  final String createdAt;

  MatchHistoryItem({
    required this.matchId,
    required this.teamA,
    required this.teamB,
    required this.totalOvers,
    required this.status,
    this.result,
    required this.createdAt,
  });

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
