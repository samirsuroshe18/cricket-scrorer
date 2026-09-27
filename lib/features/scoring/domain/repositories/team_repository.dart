import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/add_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/set_team_leadership_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';

/// Writes to `/v1/team`. Reads (`getMyTeams`, profile, matches) stay on
/// `MatchRepository`; this is a separate contract so adding to it never
/// touches the many test doubles that stand in for `MatchRepository`.
abstract class TeamRepository {
  /// `POST /v1/team` — a standalone team owned by the caller.
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> createTeam({
    required CreateTeamReq params,
  });

  /// `PATCH /v1/team/:teamId` — rename/re-set the short name of a team the
  /// caller manages. `params` is the same request shape as [createTeam]'s.
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> updateTeam({
    required String teamId,
    required CreateTeamReq params,
  });

  /// `DELETE /v1/team/:teamId` — soft-deletes a team the caller manages.
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTeam({
    required String teamId,
  });

  /// `POST /v1/team/:teamId/players` — add a player to the roster by name.
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> addPlayer({
    required String teamId,
    required AddTeamPlayerReq params,
  });

  /// `PATCH /v1/team/:teamId/players/:playerId` — edit a rostered player's
  /// role / jersey number.
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>>
  updatePlayer({
    required String teamId,
    required String playerId,
    required UpdateTeamPlayerReq params,
  });

  /// `DELETE /v1/team/:teamId/players/:playerId` — removes the player from the
  /// roster. Never deletes the `Player` document itself.
  Future<Either<CricketResponse<void>, CricketFailure>> removePlayer({
    required String teamId,
    required String playerId,
  });

  /// `PATCH /v1/team/:teamId` with `captainId` / `viceCaptainId`.
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>>
  setLeadership({
    required String teamId,
    required SetTeamLeadershipReq params,
  });
}
