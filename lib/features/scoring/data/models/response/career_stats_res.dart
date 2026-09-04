import 'package:json_annotation/json_annotation.dart';

part 'career_stats_res.g.dart';

@JsonSerializable()
class HighScore {
  final int runs;
  final bool isNotOut;
  final String matchId;

  HighScore({
    required this.runs,
    required this.isNotOut,
    required this.matchId,
  });

  factory HighScore.fromJson(Map<String, dynamic> json) =>
      _$HighScoreFromJson(json);

  Map<String, dynamic> toJson() => _$HighScoreToJson(this);
}

@JsonSerializable()
class BestBowling {
  final int wickets;
  final int runs;
  final String matchId;

  BestBowling({
    required this.wickets,
    required this.runs,
    required this.matchId,
  });

  factory BestBowling.fromJson(Map<String, dynamic> json) =>
      _$BestBowlingFromJson(json);

  Map<String, dynamic> toJson() => _$BestBowlingToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BattingCareerStats {
  final int inningsBatted;
  final int runs;
  final int ballsFaced;
  final int timesOut;
  final int notOuts;

  /// Null, not 0 — the divisor is [timesOut], and a player never dismissed
  /// has no average yet, same distinction the server draws. See
  /// `docs/api.md`'s career-stats section.
  final double? average;
  final double strikeRate;
  final int fours;
  final int sixes;
  final int fifties;
  final int hundreds;
  final HighScore? highScore;

  BattingCareerStats({
    required this.inningsBatted,
    required this.runs,
    required this.ballsFaced,
    required this.timesOut,
    required this.notOuts,
    required this.average,
    required this.strikeRate,
    required this.fours,
    required this.sixes,
    required this.fifties,
    required this.hundreds,
    required this.highScore,
  });

  factory BattingCareerStats.fromJson(Map<String, dynamic> json) =>
      _$BattingCareerStatsFromJson(json);

  Map<String, dynamic> toJson() => _$BattingCareerStatsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BowlingCareerStats {
  final int inningsBowled;
  final int legalDeliveries;
  final int runsConceded;
  final int wickets;
  final int maidens;
  final double economy;
  final BestBowling? bestBowling;

  BowlingCareerStats({
    required this.inningsBowled,
    required this.legalDeliveries,
    required this.runsConceded,
    required this.wickets,
    required this.maidens,
    required this.economy,
    required this.bestBowling,
  });

  factory BowlingCareerStats.fromJson(Map<String, dynamic> json) =>
      _$BowlingCareerStatsFromJson(json);

  Map<String, dynamic> toJson() => _$BowlingCareerStatsToJson(this);
}

/// `GET /v1/player/:playerId/career-stats`. A `Player` with no completed
/// match yet still returns `200` with every count at its zero value and
/// [BattingCareerStats.average]/[HighScore]/[BestBowling] null — not an
/// error — so the screen renders a "no matches yet" state, not an error
/// page.
@JsonSerializable(explicitToJson: true)
class CareerStatsRes {
  final String playerId;
  final String playerName;
  final int matchesPlayed;
  final BattingCareerStats batting;
  final BowlingCareerStats bowling;

  CareerStatsRes({
    required this.playerId,
    required this.playerName,
    required this.matchesPlayed,
    required this.batting,
    required this.bowling,
  });

  factory CareerStatsRes.fromJson(Map<String, dynamic> json) =>
      _$CareerStatsResFromJson(json);

  Map<String, dynamic> toJson() => _$CareerStatsResToJson(this);
}
