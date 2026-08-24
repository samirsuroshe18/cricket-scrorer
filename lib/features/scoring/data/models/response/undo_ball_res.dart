import 'package:cricket_scorer/features/scoring/data/models/response/bowler_state.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/wicket.dart';
import 'package:json_annotation/json_annotation.dart';

part 'undo_ball_res.g.dart';

/// The delivery that was removed.
///
/// Shaped like `score:update`'s `lastBall`, but named for removal rather than
/// for appending — nothing here is a ball to apply.
///
/// [absoluteBallSeq] and [overNumber] are not display fields: they are what the
/// console rewinds its two ordering guards to. See
/// `ScoreBallController.undoLastBall`.
@JsonSerializable(explicitToJson: true)
class UndoneBall {
  final String ballEventId;
  final int overNumber;
  final int ballNumber;
  final int absoluteBallSeq;
  final int runs;
  final int extras;
  final String? extraType;
  final String? runsFrom;
  final bool isLegal;

  /// The dismissal this ball carried, or null if it was an ordinary delivery.
  final Wicket? wicket;

  UndoneBall({
    required this.ballEventId,
    required this.overNumber,
    required this.ballNumber,
    required this.absoluteBallSeq,
    this.runs = 0,
    this.extras = 0,
    this.extraType,
    this.runsFrom,
    this.isLegal = true,
    this.wicket,
  });

  factory UndoneBall.fromJson(Map<String, dynamic> json) =>
      _$UndoneBallFromJson(json);

  Map<String, dynamic> toJson() => _$UndoneBallToJson(this);
}

/// A **complete state snapshot after the undo, never a diff.**
///
/// That is the contract with this endpoint, and it is why nothing here is
/// optional-looking: the console re-renders from these fields and never works
/// out the reversal itself. Undo is the one operation where a client that
/// thinks it knows what the ball did is most likely to be wrong — about strike
/// after a dismissal, about a bowler selection that has just been discarded,
/// about an over that has re-opened.
@JsonSerializable(explicitToJson: true)
class UndoBallRes {
  final String matchId;
  final String inningsId;
  final int inningsNumber;

  /// True when the named ball was already gone. The call still succeeded and
  /// everything below is current state — this is the double-tap answer, not an
  /// error, and [undone] is null.
  final bool alreadyUndone;

  /// What was removed, or null when [alreadyUndone].
  final UndoneBall? undone;

  /// The over the undone ball had completed is open again. Its
  /// `over:complete` card, if anything is showing one, is stale.
  final bool overReopened;

  /// The undone ball was the only one in its over, so the over itself is gone.
  /// Mutually exclusive with [overReopened] in practice — a single-delivery
  /// over can never have been complete.
  final bool overRemoved;

  /// The innings had ended on the undone ball and is in progress again.
  final bool inningsReopened;

  /// The pair at the crease afterwards. Carries no `rotated`/`rotationReason`:
  /// rotation is a property of a delivery, and this reports a state.
  final Strike? strike;

  /// Same shape `match:state` carries, so the console has one thing to parse
  /// for "who is bowling" whether it joined, resumed, or undid. **Never
  /// awaiting after a successful undo** — the server refuses a delivery with no
  /// bowler, so the snapshot it restored from always had one.
  final BowlerState? bowler;

  final InningsTotals inningsTotals;

  /// Formatted `<completedOvers>.<legalBallsInCurrentOver>`.
  final String overs;

  final bool inningsComplete;

  /// Whether any delivery remains in the innings. The console keeps its own
  /// stack of ball ids, so this is a cross-check rather than the source of
  /// truth for enabling the button.
  final bool canUndo;

  UndoBallRes({
    required this.matchId,
    required this.inningsId,
    required this.inningsNumber,
    this.alreadyUndone = false,
    this.undone,
    this.overReopened = false,
    this.overRemoved = false,
    this.inningsReopened = false,
    this.strike,
    this.bowler,
    required this.inningsTotals,
    required this.overs,
    this.inningsComplete = false,
    this.canUndo = false,
  });

  factory UndoBallRes.fromJson(Map<String, dynamic> json) =>
      _$UndoBallResFromJson(json);

  Map<String, dynamic> toJson() => _$UndoBallResToJson(this);
}
