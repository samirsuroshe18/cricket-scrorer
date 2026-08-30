import 'package:json_annotation/json_annotation.dart';

part 'match_abandoned_res.g.dart';

/// The `match:abandoned` socket event — see docs/api.md and
/// `MatchSocketService.watchMatchAbandoned`. No `result` field: unlike
/// `match:complete`, an abandoned match never has one.
@JsonSerializable()
class MatchAbandonedRes {
  final String matchId;
  final String status;

  MatchAbandonedRes({required this.matchId, required this.status});

  factory MatchAbandonedRes.fromJson(Map<String, dynamic> json) =>
      _$MatchAbandonedResFromJson(json);

  Map<String, dynamic> toJson() => _$MatchAbandonedResToJson(this);
}
