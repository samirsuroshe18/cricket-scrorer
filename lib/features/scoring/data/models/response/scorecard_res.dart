import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:json_annotation/json_annotation.dart';

export 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart'
    show MatchResultInfo;

part 'scorecard_res.g.dart';

@JsonSerializable()
class BattingLine {
  final String playerId;
  final String playerName;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final double strikeRate;
  final String? dismissalType;
  final bool isNotOut;

  BattingLine({
    required this.playerId,
    required this.playerName,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    this.dismissalType,
    required this.isNotOut,
  });

  factory BattingLine.fromJson(Map<String, dynamic> json) =>
      _$BattingLineFromJson(json);

  Map<String, dynamic> toJson() => _$BattingLineToJson(this);
}

@JsonSerializable()
class BowlingLine {
  final String playerId;
  final String playerName;

  /// "4.2" format — see the server's `formatOvers`.
  final String overs;
  final int maidens;
  final int runs;
  final int wickets;
  final double economy;
  final int wides;
  final int noBalls;

  BowlingLine({
    required this.playerId,
    required this.playerName,
    required this.overs,
    required this.maidens,
    required this.runs,
    required this.wickets,
    required this.economy,
    required this.wides,
    required this.noBalls,
  });

  factory BowlingLine.fromJson(Map<String, dynamic> json) =>
      _$BowlingLineFromJson(json);

  Map<String, dynamic> toJson() => _$BowlingLineToJson(this);
}

@JsonSerializable()
class ScorecardExtras {
  final int total;
  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;

  ScorecardExtras({
    required this.total,
    required this.wides,
    required this.noBalls,
    required this.byes,
    required this.legByes,
  });

  factory ScorecardExtras.fromJson(Map<String, dynamic> json) =>
      _$ScorecardExtrasFromJson(json);

  Map<String, dynamic> toJson() => _$ScorecardExtrasToJson(this);
}

@JsonSerializable(explicitToJson: true)
class InningsScorecard {
  final String inningsId;
  final int inningsNumber;

  /// Side label — `teamA`/`teamB` — never a resolved team name; the client
  /// pairs it against the [CreateMatchRes]/[PublicMatchInfo] it already holds.
  final String battingTeam;
  final List<BattingLine> battingScores;
  final List<BowlingLine> bowlingScores;
  final int totalRuns;
  final int totalWickets;

  /// "20.0" format.
  final String totalOvers;
  final ScorecardExtras extras;

  InningsScorecard({
    required this.inningsId,
    required this.inningsNumber,
    required this.battingTeam,
    required this.battingScores,
    required this.bowlingScores,
    required this.totalRuns,
    required this.totalWickets,
    required this.totalOvers,
    required this.extras,
  });

  factory InningsScorecard.fromJson(Map<String, dynamic> json) =>
      _$InningsScorecardFromJson(json);

  Map<String, dynamic> toJson() => _$InningsScorecardToJson(this);
}

/// `GET /v1/match/:matchId/scorecard`. Always length-2 `innings`, but an
/// entry can be `null` — a `completed` match always has both (it cannot
/// complete without playing out both), but an `abandoned` one only has
/// whichever innings actually started before play was called off, so
/// `innings[1]` is `null` if the match never reached innings 2. `result` is
/// `null` for the same reason an abandoned match has: no winner was ever
/// decided.
@JsonSerializable(explicitToJson: true)
class ScorecardRes {
  final String matchId;
  final MatchResultInfo? result;
  final List<InningsScorecard?> innings;

  /// Resolved names, unlike [InningsScorecard.battingTeam] and
  /// [MatchResultInfo.winner], which stay side labels. Reused from the
  /// public-match model rather than duplicated — the shape (name only, no
  /// id) is identical and for the same reason: this screen has no use for a
  /// team id either.
  final PublicTeamRef teamA;
  final PublicTeamRef teamB;

  ScorecardRes({
    required this.matchId,
    required this.teamA,
    required this.teamB,
    required this.result,
    required this.innings,
  });

  /// Resolves a side label (`teamA`/`teamB`) — as carried by
  /// [InningsScorecard.battingTeam] and [MatchResultInfo.winner] — to the
  /// name a scorer actually recognizes. Falls back to the label itself
  /// rather than null: a missing name is a display nit, not a reason to blank
  /// out who won.
  String nameFor(String sideLabel) {
    final name = sideLabel == 'teamA' ? teamA.name : teamB.name;
    return name ?? sideLabel;
  }

  factory ScorecardRes.fromJson(Map<String, dynamic> json) =>
      _$ScorecardResFromJson(json);

  Map<String, dynamic> toJson() => _$ScorecardResToJson(this);
}
