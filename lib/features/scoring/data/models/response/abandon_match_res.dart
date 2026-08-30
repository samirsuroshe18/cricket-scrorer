import 'package:json_annotation/json_annotation.dart';

part 'abandon_match_res.g.dart';

/// `POST /v1/match/:matchId/abandon`.
@JsonSerializable()
class AbandonMatchRes {
  final String matchId;
  final String status;

  AbandonMatchRes({required this.matchId, required this.status});

  factory AbandonMatchRes.fromJson(Map<String, dynamic> json) =>
      _$AbandonMatchResFromJson(json);

  Map<String, dynamic> toJson() => _$AbandonMatchResToJson(this);
}
