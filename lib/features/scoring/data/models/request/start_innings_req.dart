import 'package:json_annotation/json_annotation.dart';

part 'start_innings_req.g.dart';

@JsonSerializable(includeIfNull: false)
class StartInningsReq {
  /// Takes strike for the first ball of the innings.
  final String strikerName;

  /// What tells the server "this exact rostered player" apart from "a new
  /// player who happens to share a name" — present when the scorer picked
  /// the striker from the batting side's roster, absent for a freshly-typed
  /// name. Same mechanism as `select-bowler`'s `bowlerId` — see docs/api.md's
  /// "Identity: bowlerId vs a bare name".
  final String? strikerId;
  final String nonStrikerName;
  final String? nonStrikerId;

  /// Bowls over 1. Required — the server 400s with `BOWLER_NAME_REQUIRED`
  /// without it, because `score-ball` refuses a delivery with no bowler set.
  ///
  /// Naming him here rather than through `select-bowler` is what keeps "you can
  /// score ball 1 straight after start-innings" true, and it means the openers
  /// prompt and the next-bowler prompt can never compete to open at the start
  /// of an innings. Law 17.6 cannot apply to over 1 — there is no previous
  /// over — so no exclusion is involved.
  final String bowlerName;
  final String? bowlerId;

  StartInningsReq({
    required this.strikerName,
    this.strikerId,
    required this.nonStrikerName,
    this.nonStrikerId,
    required this.bowlerName,
    this.bowlerId,
  });

  factory StartInningsReq.fromJson(Map<String, dynamic> json) =>
      _$StartInningsReqFromJson(json);

  Map<String, dynamic> toJson() => _$StartInningsReqToJson(this);
}
