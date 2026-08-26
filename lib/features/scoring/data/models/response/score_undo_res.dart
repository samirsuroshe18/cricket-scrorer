import 'package:cricket_scorer/features/scoring/data/models/response/bowler_state.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:json_annotation/json_annotation.dart';

part 'score_undo_res.g.dart';

/// Identifies the delivery that was removed — never a ball to *apply*. Named
/// [UndoneBallRef] rather than reusing [OverSummary]'s ball fields, because a
/// listener that once mixed this up with a scored ball would append instead
/// of removing.
@JsonSerializable()
class UndoneBallRef {
  final String? ballEventId;
  final int? overNumber;
  final int? ballNumber;
  final int? absoluteBallSeq;

  UndoneBallRef({
    this.ballEventId,
    this.overNumber,
    this.ballNumber,
    this.absoluteBallSeq,
  });

  factory UndoneBallRef.fromJson(Map<String, dynamic> json) =>
      _$UndoneBallRefFromJson(json);

  Map<String, dynamic> toJson() => _$UndoneBallRefToJson(this);
}

/// The `score:undo` socket event — broadcast to the room after a successful
/// undo, never for an `alreadyUndone` no-op (nothing changed, so nothing to
/// tell the room).
///
/// The totals fields ([totalRuns] through [bowler]) are the same shape
/// [PublicInningsState] and `score:update` carry, on purpose: a listener that
/// only tracks the score can fold this event through the same path as any
/// other state update. What it must NOT do is treat [undoneBall] the way it
/// treats `score:update`'s `lastBall` — this identifies a delivery to
/// *remove* from a ball-by-ball view, not one to append.
@JsonSerializable(explicitToJson: true)
class ScoreUndoRes {
  final String? matchId;
  final String? inningsId;
  final int? inningsNumber;
  final int totalRuns;
  final int wickets;
  final String overs;

  /// Null in innings 1. See [ScoreBallRes.target].
  final int? target;
  final ExtrasBreakdown extras;
  final Strike? strike;
  final BowlerState? bowler;
  final UndoneBallRef? undoneBall;

  /// The over the undone ball had completed is open again. A view holding an
  /// `over:complete` card for it should discard that card.
  final bool overReopened;

  /// The innings had ended on the undone ball and is in progress again.
  final bool inningsReopened;

  ScoreUndoRes({
    this.matchId,
    this.inningsId,
    this.inningsNumber,
    required this.totalRuns,
    required this.wickets,
    required this.overs,
    this.target,
    required this.extras,
    this.strike,
    this.bowler,
    this.undoneBall,
    this.overReopened = false,
    this.inningsReopened = false,
  });

  factory ScoreUndoRes.fromJson(Map<String, dynamic> json) =>
      _$ScoreUndoResFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreUndoResToJson(this);
}
