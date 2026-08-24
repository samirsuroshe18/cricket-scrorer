import 'package:cricket_scorer/features/scoring/data/models/response/bowler.dart';
import 'package:json_annotation/json_annotation.dart';

part 'select_bowler_res.g.dart';

@JsonSerializable(explicitToJson: true)
class SelectBowlerRes {
  final String matchId;
  final String inningsId;

  /// The over this selection applies to (`oversCompleted + 1`), so a queued
  /// call can be confirmed to have landed on the over it meant.
  final int overNumber;

  final Bowler bowler;

  /// The bowler of the over just finished — whom the server will refuse.
  /// Null for over 1 of an innings, which has no previous over.
  final Bowler? previousBowler;

  SelectBowlerRes({
    required this.matchId,
    required this.inningsId,
    required this.overNumber,
    required this.bowler,
    this.previousBowler,
  });

  factory SelectBowlerRes.fromJson(Map<String, dynamic> json) =>
      _$SelectBowlerResFromJson(json);

  Map<String, dynamic> toJson() => _$SelectBowlerResToJson(this);
}
