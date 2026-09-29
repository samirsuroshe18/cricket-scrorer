import 'package:json_annotation/json_annotation.dart';

part 'create_match_res.g.dart';

@JsonSerializable()
class TeamRef {
  final String id;
  final String name;

  /// Cloudinary URL from `POST /v1/team/:teamId/logo`, or `null` for a team
  /// that never had one uploaded.
  final String? logoUrl;

  TeamRef({required this.id, required this.name, this.logoUrl});

  factory TeamRef.fromJson(Map<String, dynamic> json) =>
      _$TeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$TeamRefToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateMatchRes {
  final String matchId;

  /// The six-character share code. Reported here because this is the only
  /// moment the client learns it — nothing else \`create\` returns carries
  /// one. Kept past this response so the scorer's console can offer a "copy
  /// code" action.
  final String? joinCode;

  final TeamRef teamA;
  final TeamRef teamB;
  final int totalOvers;

  /// The Playing XI size range this match holds both sides to. Present when
  /// this response came straight from `POST /create`; `null` when it was
  /// synthesized from match-history data (see `toCreateMatchRes`), in which
  /// case the Squad screen just doesn't show the size hint.
  final int? minPlayingXi;
  final int? maxPlayingXi;

  /// Both null when the toss was skipped. `teamA` / `teamB`.
  final String? tossWinner;

  /// `bat` / `bowl`.
  final String? tossDecision;

  final String status;
  final String syncStatus;
  final String createdAt;

  CreateMatchRes({
    required this.matchId,
    this.joinCode,
    required this.teamA,
    required this.teamB,
    required this.totalOvers,
    this.minPlayingXi,
    this.maxPlayingXi,
    this.tossWinner,
    this.tossDecision,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
  });

  factory CreateMatchRes.fromJson(Map<String, dynamic> json) =>
      _$CreateMatchResFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMatchResToJson(this);
}
