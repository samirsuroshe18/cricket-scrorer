import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_row_res.g.dart';

/// One row of `GET /v1/tournament/:tournamentId/leaderboards`'
/// `battingLeaderboard` array — see `docs/api.md`. Field names and formulas
/// mirror `BattingCareerStats` exactly (same server-side pure functions),
/// scoped to one tournament's matches instead of a whole career. Already
/// sorted by the backend (runs desc, then average desc, then player name
/// asc), so this model carries no sort logic of its own.
@JsonSerializable(explicitToJson: true)
class BattingLeaderboardRowRes {
  final String playerId;
  final String playerName;
  final int inningsBatted;
  final int runs;
  final int ballsFaced;
  final int timesOut;
  final int notOuts;

  /// Null, not 0 — the divisor is [timesOut], and a player never dismissed
  /// has no average yet, same distinction `BattingCareerStats.average` draws.
  final double? average;
  final double strikeRate;
  final int fours;
  final int sixes;
  final int fifties;
  final int hundreds;
  final HighScore? highScore;

  BattingLeaderboardRowRes({
    required this.playerId,
    required this.playerName,
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

  factory BattingLeaderboardRowRes.fromJson(Map<String, dynamic> json) =>
      _$BattingLeaderboardRowResFromJson(json);

  Map<String, dynamic> toJson() => _$BattingLeaderboardRowResToJson(this);
}

/// One row of the same response's `bowlingLeaderboard` array. Mirrors
/// `BowlingCareerStats` exactly, scoped to one tournament.
@JsonSerializable(explicitToJson: true)
class BowlingLeaderboardRowRes {
  final String playerId;
  final String playerName;
  final int inningsBowled;
  final int legalDeliveries;
  final int runsConceded;
  final int wickets;
  final int maidens;
  final double economy;
  final BestBowling? bestBowling;

  BowlingLeaderboardRowRes({
    required this.playerId,
    required this.playerName,
    required this.inningsBowled,
    required this.legalDeliveries,
    required this.runsConceded,
    required this.wickets,
    required this.maidens,
    required this.economy,
    required this.bestBowling,
  });

  factory BowlingLeaderboardRowRes.fromJson(Map<String, dynamic> json) =>
      _$BowlingLeaderboardRowResFromJson(json);

  Map<String, dynamic> toJson() => _$BowlingLeaderboardRowResToJson(this);
}

/// `GET /v1/tournament/:tournamentId/leaderboards`'s full response `data`.
/// Both lists are already sorted server-side and may be empty (a tournament
/// with no completed matches, or a player who never bowled) — that's not an
/// error state, just an empty list.
@JsonSerializable(explicitToJson: true)
class TournamentLeaderboardsRes {
  final String tournamentId;
  final List<BattingLeaderboardRowRes> battingLeaderboard;
  final List<BowlingLeaderboardRowRes> bowlingLeaderboard;

  TournamentLeaderboardsRes({
    required this.tournamentId,
    required this.battingLeaderboard,
    required this.bowlingLeaderboard,
  });

  factory TournamentLeaderboardsRes.fromJson(Map<String, dynamic> json) =>
      _$TournamentLeaderboardsResFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentLeaderboardsResToJson(this);
}
