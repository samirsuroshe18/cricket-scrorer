import 'package:json_annotation/json_annotation.dart';

part 'create_match_req.g.dart';

@JsonSerializable()
class CreateMatchReq {
  final String teamAName;
  final String teamBName;
  final int totalOvers;

  /// The Playing XI size range this match holds both sides to — same pair
  /// for both sides. Optional on the wire (the backend defaults to 2/11),
  /// but the Create Match screen always sends both, pre-filled.
  final int? minPlayingXi;

  /// See [minPlayingXi]. No ceiling.
  final int? maxPlayingXi;

  /// Both null (toss skipped) or both non-null — the server rejects one
  /// without the other. `teamA` / `teamB`.
  final String? tossWinner;

  /// `bat` / `bowl`.
  final String? tossDecision;

  /// An existing, caller-owned Team id to reuse for side A instead of
  /// creating one from [teamAName] — see `GET /v1/team` for the picker
  /// source. Passing this makes [teamAName] irrelevant server-side; it is
  /// still sent because the form always has a name in the field (either
  /// typed, or auto-filled from the selected team).
  final String? teamAId;

  /// Same as [teamAId], for side B.
  final String? teamBId;

  CreateMatchReq({
    required this.teamAName,
    required this.teamBName,
    required this.totalOvers,
    this.minPlayingXi,
    this.maxPlayingXi,
    this.tossWinner,
    this.tossDecision,
    this.teamAId,
    this.teamBId,
  });

  factory CreateMatchReq.fromJson(Map<String, dynamic> json) =>
      _$CreateMatchReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMatchReqToJson(this);
}
