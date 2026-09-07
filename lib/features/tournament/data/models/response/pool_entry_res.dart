import 'package:json_annotation/json_annotation.dart';

part 'pool_entry_res.g.dart';

/// One entry in a tournament's auction pool — a `Player`'s existing Phase 2
/// profile fields plus this tournament's organizer-set `basePrice`.
/// Deliberately carries no career-stats field: base price never derives
/// from stats, and this response shouldn't imply otherwise. See
/// docs/api.md's "Player pool" section.
@JsonSerializable()
class PoolEntryRes {
  final String playerId;
  final String playerName;
  final String role;
  final int? jerseyNumber;
  final String? battingStyle;
  final String? bowlingStyle;
  final String? bio;
  final int basePrice;
  final String registeredAt;

  PoolEntryRes({
    required this.playerId,
    required this.playerName,
    required this.role,
    this.jerseyNumber,
    this.battingStyle,
    this.bowlingStyle,
    this.bio,
    required this.basePrice,
    required this.registeredAt,
  });

  factory PoolEntryRes.fromJson(Map<String, dynamic> json) =>
      _$PoolEntryResFromJson(json);

  Map<String, dynamic> toJson() => _$PoolEntryResToJson(this);
}
