import 'package:json_annotation/json_annotation.dart';

part 'create_match_req.g.dart';

@JsonSerializable()
class CreateMatchReq {
  final String teamAName;
  final String teamBName;
  final int totalOvers;

  /// Both null (toss skipped) or both non-null — the server rejects one
  /// without the other. `teamA` / `teamB`.
  final String? tossWinner;

  /// `bat` / `bowl`.
  final String? tossDecision;

  CreateMatchReq({
    required this.teamAName,
    required this.teamBName,
    required this.totalOvers,
    this.tossWinner,
    this.tossDecision,
  });

  factory CreateMatchReq.fromJson(Map<String, dynamic> json) =>
      _$CreateMatchReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMatchReqToJson(this);
}
