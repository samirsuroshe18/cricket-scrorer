import 'package:json_annotation/json_annotation.dart';

part 'select_bowler_req.g.dart';

/// Names the bowler for the over that has not started yet.
///
/// The server refuses the previous over's bowler outright with
/// `BOWLER_CANNOT_BOWL_CONSECUTIVE_OVERS` (Law 17.6), and refuses a name change
/// once the over has a delivery with `OVER_ALREADY_STARTED`. The picker greys
/// the excluded bowler so the scorer sees the rule, but the server is what
/// enforces it.
///
/// [bowlerId] is what tells the server "this exact returning bowler" apart
/// from "a new player who happens to share a name" — present when the scorer
/// picked a bowler already known to this match, absent for a freshly-typed
/// name. See docs/api.md's "Identity: bowlerId vs a bare name".
@JsonSerializable(includeIfNull: false)
class SelectBowlerReq {
  final String bowlerName;
  final String? bowlerId;

  SelectBowlerReq({required this.bowlerName, this.bowlerId});

  factory SelectBowlerReq.fromJson(Map<String, dynamic> json) =>
      _$SelectBowlerReqFromJson(json);

  Map<String, dynamic> toJson() => _$SelectBowlerReqToJson(this);
}
