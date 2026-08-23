import 'package:json_annotation/json_annotation.dart';

part 'score_ball_req.g.dart';

@JsonSerializable(includeIfNull: false)
class ScoreBallReq {
  /// Runs run/hit *beyond* the automatic 1-run penalty for a wide/no-ball —
  /// the server adds that itself. Always 0–6.
  final int runs;

  /// The delivery fault: `wide` | `no_ball`, or null for a legal delivery.
  final String? extraType;

  /// Who the runs are credited to: `bat` (default) | `bye` | `leg_bye`.
  /// Independent of [extraType] — a no-ball can also go for byes.
  final String? runsFrom;

  final String idempotencyKey;

  ScoreBallReq({
    required this.runs,
    this.extraType,
    this.runsFrom,
    required this.idempotencyKey,
  });

  factory ScoreBallReq.fromJson(Map<String, dynamic> json) =>
      _$ScoreBallReqFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreBallReqToJson(this);
}
