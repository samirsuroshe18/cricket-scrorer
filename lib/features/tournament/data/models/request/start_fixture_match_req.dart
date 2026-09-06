import 'package:json_annotation/json_annotation.dart';

part 'start_fixture_match_req.g.dart';

@JsonSerializable(includeIfNull: false)
class StartFixtureMatchReq {
  final int totalOvers;

  /// `teamA` / `teamB`. Both this and [tossDecision] are either both null
  /// (toss skipped) or both set — the sheet enforces that before this ever
  /// gets built, matching `POST /v1/match`'s own rule.
  final String? tossWinner;

  /// `bat` / `bowl`.
  final String? tossDecision;

  StartFixtureMatchReq({
    required this.totalOvers,
    this.tossWinner,
    this.tossDecision,
  });

  factory StartFixtureMatchReq.fromJson(Map<String, dynamic> json) =>
      _$StartFixtureMatchReqFromJson(json);

  Map<String, dynamic> toJson() => _$StartFixtureMatchReqToJson(this);
}
