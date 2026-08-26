import 'package:cricket_scorer/features/scoring/data/models/response/bowler_state.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/wicket.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_score_res.g.dart';

@JsonSerializable(explicitToJson: true)
class LastBall {
  final int runs;
  final int extras;
  final String? extraType;
  final String? runsFrom;
  final bool isLegal;
  final int overNumber;
  final int ballNumber;
  final int absoluteBallSeq;

  /// The dismissal this delivery produced, or null. It sits on the ball rather
  /// than beside `strike` because a wicket *is* a property of the delivery,
  /// where strike is innings state after it.
  final Wicket? wicket;

  LastBall({
    required this.runs,
    this.extras = 0,
    this.extraType,
    this.runsFrom,
    this.isLegal = true,
    required this.overNumber,
    required this.ballNumber,
    required this.absoluteBallSeq,
    this.wicket,
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

  /// Null in innings 1. Carried on every payload this model parses, not just
  /// once at start-innings, so required run rate stays computable across a
  /// reconnect — see docs/api.md's note on `target`.
  final int? target;

  /// Innings running extras totals — drives the scorecard's Extras line.
  final ExtrasBreakdown? extras;

  /// Who is on strike. Null on `match:state` when no innings has been started —
  /// no openers have been chosen yet.
  final Strike? strike;

  /// Who is bowling and who bowled the over before. Sent on `match:state` only
  /// — `score:update` does not carry it — and null when no innings exists yet,
  /// alongside a null [strike].
  ///
  /// This is what makes resuming mid-over-break work: the join ack alone tells
  /// the console a bowler is owed, with no local state remembered across a
  /// restart.
  final BowlerState? bowler;

  final LastBall? lastBall;

  LiveScoreRes({
    required this.matchId,
    this.inningsId,
    required this.inningsNumber,
    required this.totalRuns,
    required this.wickets,
    required this.overs,
    this.target,
    this.extras,
    this.strike,
    this.bowler,
    this.lastBall,
  });

  factory LiveScoreRes.fromJson(Map<String, dynamic> json) =>
      _$LiveScoreResFromJson(json);

  Map<String, dynamic> toJson() => _$LiveScoreResToJson(this);
}
