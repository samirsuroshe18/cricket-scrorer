import 'package:json_annotation/json_annotation.dart';

part 'undo_ball_req.g.dart';

/// Removes a delivery, named explicitly rather than popped.
///
/// The server undoes [ballEventId] only while it is still the most recent ball
/// of the innings; an older one is refused with `BALL_NOT_LATEST`. Naming it is
/// also what makes the call idempotent — a ball that has already gone answers
/// `200` with `alreadyUndone`, so a double tap on patchy signal cannot remove a
/// second delivery.
@JsonSerializable()
class UndoBallReq {
  /// The `ballEventId` the `score-ball` response returned for that delivery.
  final String ballEventId;

  UndoBallReq({required this.ballEventId});

  factory UndoBallReq.fromJson(Map<String, dynamic> json) =>
      _$UndoBallReqFromJson(json);

  Map<String, dynamic> toJson() => _$UndoBallReqToJson(this);
}
