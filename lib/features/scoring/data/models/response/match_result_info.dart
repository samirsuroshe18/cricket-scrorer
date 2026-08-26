import 'package:json_annotation/json_annotation.dart';

part 'match_result_info.g.dart';

/// `winner` is the side label (`teamA`/`teamB`) or `tie` — never a resolved
/// team name. The server deliberately sends no description sentence; see
/// [marginType]'s doc. The client composes the display string from this plus
/// the team names it already holds, through `TranslationKeys` — see
/// `MatchResultBanner`, shared between the scorer's result screen and the
/// spectator screen so the two can never describe the same match differently.
///
/// Its own file rather than living on `ScorecardRes` (where it originated):
/// `PublicMatchInfo` needs it too, and `ScorecardRes` already imports
/// `public_match_res.dart` for `PublicTeamRef` — importing the other way as
/// well would be a cycle.
@JsonSerializable()
class MatchResultInfo {
  final String winner;

  /// `wickets`, `runs`, or null exactly when [winner] is `tie`.
  final String? marginType;
  final int? margin;

  MatchResultInfo({required this.winner, this.marginType, this.margin});

  bool get isTie => winner == 'tie';

  factory MatchResultInfo.fromJson(Map<String, dynamic> json) =>
      _$MatchResultInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MatchResultInfoToJson(this);
}
