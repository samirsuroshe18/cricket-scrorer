import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:json_annotation/json_annotation.dart';

part 'over_complete_res.g.dart';

/// The `over:complete` socket event, broadcast after the `score:update` for the
/// delivery that ended the over.
///
/// Its obvious consumer is a spectator's end-of-over card, which doesn't exist
/// yet. The console listens anyway because it is a **recovery path**: if the
/// REST ack for the over-completing ball is lost on patchy signal, this still
/// carries [newBowlerRequired] and the bowler to exclude, which is everything
/// the next-bowler prompt needs.
///
/// The event deliberately carries no excluded-bowler field — the spectator room
/// is unauthenticated and has no picker to feed — so the console derives the
/// exclusion from [over]'s bowler, who by definition just bowled.
@JsonSerializable(explicitToJson: true)
class OverCompleteRes {
  final String matchId;
  final String? inningsId;
  final int inningsNumber;
  final int overNumber;

  /// The over's line. Note its own `overNumber` is absent here — this event
  /// carries it at the top level instead.
  final OverSummary over;

  /// The pair for the first ball of the next over. Carries no
  /// `rotated`/`rotationReason`: rotation is a property of a delivery and
  /// belongs to `score:update`; this event reports a state.
  final Strike? strike;

  final bool inningsComplete;

  /// False whenever [inningsComplete] is true — there is no next over to bowl.
  final bool newBowlerRequired;

  OverCompleteRes({
    required this.matchId,
    this.inningsId,
    required this.inningsNumber,
    required this.overNumber,
    required this.over,
    this.strike,
    this.inningsComplete = false,
    this.newBowlerRequired = false,
  });

  factory OverCompleteRes.fromJson(Map<String, dynamic> json) =>
      _$OverCompleteResFromJson(json);

  Map<String, dynamic> toJson() => _$OverCompleteResToJson(this);
}
