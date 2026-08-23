import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_score_res.g.dart';

@JsonSerializable()
class LastBall {
  final int runs;
  final int extras;
  final String? extraType;
  final String? runsFrom;
  final bool isLegal;
  final int overNumber;
  final int ballNumber;
  final int absoluteBallSeq;

  LastBall({
    required this.runs,
    this.extras = 0,
    this.extraType,
    this.runsFrom,
    this.isLegal = true,
    required this.overNumber,
    required this.ballNumber,
    required this.absoluteBallSeq,
  });

  factory LastBall.fromJson(Map<String, dynamic> json) =>
      _$LastBallFromJson(json);

  Map<String, dynamic> toJson() => _$LastBallToJson(this);
}

/// One unified model for both socket payloads this feature listens for —
/// `match:state` (join ack, no `lastBall`) and `score:update` (broadcast,
/// always carries `lastBall`).
@JsonSerializable(explicitToJson: true)
class LiveScoreRes {
  final String matchId;
  final String? inningsId;
  final int inningsNumber;
  final int totalRuns;
  final int wickets;
  final String overs;

  /// Innings running extras totals — drives the scorecard's Extras line.
  final ExtrasBreakdown? extras;
  final LastBall? lastBall;

  LiveScoreRes({
    required this.matchId,
    this.inningsId,
    required this.inningsNumber,
    required this.totalRuns,
    required this.wickets,
    required this.overs,
    this.extras,
    this.lastBall,
  });

  factory LiveScoreRes.fromJson(Map<String, dynamic> json) =>
      _$LiveScoreResFromJson(json);

  Map<String, dynamic> toJson() => _$LiveScoreResToJson(this);
}
