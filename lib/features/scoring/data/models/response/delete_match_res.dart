import 'package:json_annotation/json_annotation.dart';

part 'delete_match_res.g.dart';

/// `DELETE /v1/match/:matchId`.
@JsonSerializable()
class DeleteMatchRes {
  final String matchId;

  DeleteMatchRes({required this.matchId});

  factory DeleteMatchRes.fromJson(Map<String, dynamic> json) =>
      _$DeleteMatchResFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteMatchResToJson(this);
}
