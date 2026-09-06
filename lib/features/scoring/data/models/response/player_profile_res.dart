import 'package:json_annotation/json_annotation.dart';

part 'player_profile_res.g.dart';

/// `PATCH /v1/player/:playerId`'s response — see `docs/api.md`. Same field
/// names/shapes as the profile portion of `CareerStatsRes`, deliberately not
/// shared as one type: this endpoint returns only the profile, not stats.
@JsonSerializable()
class PlayerProfileRes {
  final String playerId;
  final String playerName;
  final String role;
  final int? jerseyNumber;
  final String? bio;
  final String? battingStyle;
  final String? bowlingStyle;

  PlayerProfileRes({
    required this.playerId,
    required this.playerName,
    required this.role,
    required this.jerseyNumber,
    required this.bio,
    required this.battingStyle,
    required this.bowlingStyle,
  });

  factory PlayerProfileRes.fromJson(Map<String, dynamic> json) =>
      _$PlayerProfileResFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerProfileResToJson(this);
}
