import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';

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
}
