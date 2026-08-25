import 'package:json_annotation/json_annotation.dart';

part 'create_match_res.g.dart';

@JsonSerializable()
class TeamRef {
  final String id;
  final String name;

  TeamRef({required this.id, required this.name});

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
  final String status;
  final String syncStatus;
  final String createdAt;

  CreateMatchRes({
    required this.matchId,
    this.joinCode,
    required this.teamA,
    required this.teamB,
    required this.totalOvers,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
  });

  factory CreateMatchRes.fromJson(Map<String, dynamic> json) =>
      _$CreateMatchResFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMatchResToJson(this);
}
