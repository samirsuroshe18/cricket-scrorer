import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';

/// What the scoring pickers may offer, given the match's saved squad.
///
/// A side whose Playing XI is **set** is *locked*: the server accepts only its
/// XI for openers, bowlers and incoming batsmen, so the pickers narrow to those
/// players. An **unset** XI (`playingXI == null`, or no squad known at all)
/// restricts nothing — the pickers behave exactly as they did before squads
/// had an XI. A set-but-empty XI is locked and offers nobody.
class PlayingXiFilter {
  final MatchSquadRes? squad;

  const PlayingXiFilter(this.squad);

  SquadSideRes? _side(String teamId) {
    final squad = this.squad;
    if (squad == null) return null;
    if (squad.teamA.teamId == teamId) return squad.teamA;
    if (squad.teamB.teamId == teamId) return squad.teamB;
    return null;
  }

  Set<String>? _xiIds(String teamId) => _side(teamId)?.playingXI?.toSet();

  bool isLocked(String teamId) => _xiIds(teamId) != null;

  /// [all] narrowed to the XI of [teamId]'s side, or [all] untouched when that
  /// side is not locked.
  List<TeamRosterPlayer> roster(String teamId, List<TeamRosterPlayer> all) {
    final xi = _xiIds(teamId);
    if (xi == null) return all;
    return all.where((player) => xi.contains(player.playerId)).toList();
  }

  /// Same for bowlers. A bowler known only by name (learned from a live event,
  /// so with no id) is kept when that name belongs to an XI player.
  List<BowlerRef> bowlers(String teamId, List<BowlerRef> all) {
    final side = _side(teamId);
    final xi = side?.playingXI?.toSet();
    if (side == null || xi == null) return all;

    final xiNames = {
      for (final player in side.players)
        if (xi.contains(player.playerId)) player.name.trim().toLowerCase(),
    };
    return all
        .where(
          (bowler) => bowler.id != null
              ? xi.contains(bowler.id)
              : xiNames.contains(bowler.name.trim().toLowerCase()),
        )
        .toList();
  }
}
