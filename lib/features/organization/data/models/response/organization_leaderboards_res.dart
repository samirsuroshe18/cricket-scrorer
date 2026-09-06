import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization_leaderboards_res.g.dart';

/// `GET /v1/organization/:orgId/leaderboards`'s full response `data`. Same
/// row shapes as `GET /v1/tournament/:tournamentId/leaderboards` — reused
/// directly from the tournament feature's response models rather than
/// duplicated, since both endpoints share the exact same
/// `computeLeaderboards` output shape server-side.
@JsonSerializable(explicitToJson: true)
class OrganizationLeaderboardsRes {
  final String organizationId;
  final List<BattingLeaderboardRowRes> battingLeaderboard;
  final List<BowlingLeaderboardRowRes> bowlingLeaderboard;

  OrganizationLeaderboardsRes({
    required this.organizationId,
    required this.battingLeaderboard,
    required this.bowlingLeaderboard,
  });

  factory OrganizationLeaderboardsRes.fromJson(Map<String, dynamic> json) =>
      _$OrganizationLeaderboardsResFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationLeaderboardsResToJson(this);
}
