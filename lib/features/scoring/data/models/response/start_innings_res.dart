import 'package:cricket_scorer/features/scoring/data/models/response/bowler.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_innings_res.g.dart';

@JsonSerializable(explicitToJson: true)
class StartInningsRes {
  final String matchId;
  final String inningsId;
  final int inningsNumber;

  /// `teamA` / `teamB`.
  final String battingTeam;
  final String bowlingTeam;

  /// The openers. Carries no `rotated`/`rotationReason` — no ball has been
  /// bowled yet.
  final Strike strike;

  /// Who bowls over 1.
  final Bowler? bowler;

  /// Null for innings 1 — nothing to chase yet. One more than innings 1's
  /// total for innings 2. See [ScoreBallRes.target] for why this is not the
  /// only place it arrives.
  final int? target;

  /// All zero on a fresh innings; echoed so a replaced-openers call returns the
  /// same shape as the first call.
  final InningsTotals inningsTotals;

  StartInningsRes({
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.strike,
    this.bowler,
    this.target,
    required this.inningsTotals,
  });

  factory StartInningsRes.fromJson(Map<String, dynamic> json) =>
      _$StartInningsResFromJson(json);

  Map<String, dynamic> toJson() => _$StartInningsResToJson(this);
}
