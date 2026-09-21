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
}
