import 'package:json_annotation/json_annotation.dart';

part 'my_career_stats_res.g.dart';

/// `GET /v1/user/me/career-stats` — the signed-in user's totals summed over
/// every Player they have claimed. `linkedPlayerCount == 0` means nothing is
/// claimed (all totals are then `0`), which the Home chips treat as "hide".
@JsonSerializable()
class MyCareerStatsRes {
  final int linkedPlayerCount;
  final int matchesPlayed;
  final int runs;
  final int wickets;

  MyCareerStatsRes({
    required this.linkedPlayerCount,
    required this.matchesPlayed,
    required this.runs,
    required this.wickets,
  });

  factory MyCareerStatsRes.fromJson(Map<String, dynamic> json) =>
      _$MyCareerStatsResFromJson(json);

  Map<String, dynamic> toJson() => _$MyCareerStatsResToJson(this);
}
