import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/playing_for_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_player_view_res.dart';

/// The read-only side of a team: what a linked roster player may see of a team
/// they do not run. A separate contract from `MatchRepository`/`TeamRepository`
/// so adding to it never touches the test doubles that stand in for those.
abstract class TeamPlayerViewRepository {
  /// `GET /v1/team/playing-for`.
  Future<Either<CricketResponse<PlayingForTeamsRes>, CricketFailure>>
  getPlayingForTeams({required int page, required int limit});

  /// `GET /v1/team/:teamId/player-view`.
  Future<Either<CricketResponse<TeamPlayerViewRes>, CricketFailure>>
  getTeamPlayerView({required String teamId});

  /// `GET /v1/team/:teamId/player-view/matches`.
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamPlayerMatches({
    required String teamId,
    required int page,
    required int limit,
    String status = 'all',
  });
}
