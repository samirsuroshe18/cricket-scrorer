import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';

/// What the scoring pickers offer, given the match's saved squad.
///
/// A side whose Playing XI is **set** is *locked*: the server accepts only its
/// XI for openers, bowlers and incoming batsmen, and typed names are refused, so
/// the pickers offer exactly those players — **served from the squad itself**,
/// not from a network fetch. That matters: a locked picker has no typing
/// fallback, so it must never depend on a request that can fail, time out
/// offline, or (for the bowlers list) not exist yet on a fresh match.
///
/// An **unset** XI (`playingXI == null`, or no squad known at all) restricts
/// nothing and every method here returns null, leaving the pickers exactly as
/// they were before squads had an XI. A set-but-empty XI is locked and offers
/// nobody.
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

  /// [teamId]'s XI players in squad order, or null when the side is not locked.
  List<SquadSidePlayerRes>? _xiPlayers(String teamId) {
    final side = _side(teamId);
    final xi = side?.playingXI?.toSet();
    if (side == null || xi == null) return null;
    return side.players.where((p) => xi.contains(p.playerId)).toList();
  }

  bool isLocked(String teamId) => _side(teamId)?.playingXI != null;

  /// The XI as picker rows, or null when the side is not locked.
  List<TeamRosterPlayer>? xiRoster(String teamId) => _xiPlayers(teamId)
      ?.map(
        (p) => TeamRosterPlayer(
          playerId: p.playerId,
          playerName: p.name,
          role: p.role,
          jerseyNumber: p.jerseyNumber,
        ),
      )
      .toList();

  /// The XI as bowlers, or null when the side is not locked. Overs-bowled
  /// figures are carried over from a bowler in [seen] with the same id, so a
  /// chip shows them once they exist; a bowler not seen yet simply has none.
  List<BowlerRef>? xiBowlers(String teamId, List<BowlerRef> seen) {
    final players = _xiPlayers(teamId);
    if (players == null) return null;
    return [
      for (final p in players)
        BowlerRef(
          id: p.playerId,
          name: p.name,
          legalDeliveries: seen
              .where((b) => b.id == p.playerId)
              .map((b) => b.legalDeliveries)
              .firstOrNull,
        ),
    ];
  }
}
