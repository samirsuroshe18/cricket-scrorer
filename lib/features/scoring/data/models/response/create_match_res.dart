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
  final TeamRef teamA;
  final TeamRef teamB;
  final int totalOvers;
  final String status;
  final String syncStatus;
  final String createdAt;

  CreateMatchRes({
    required this.matchId,
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
