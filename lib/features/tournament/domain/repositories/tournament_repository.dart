import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';

abstract class TournamentRepository {
  /// `POST /v1/organization/:orgId/tournaments` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> createTournament({
    required String orgId,
    required CreateTournamentReq? params,
  });

  /// `GET /v1/tournament/:tournamentId` — any org member.
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>>
  getTournament({required String tournamentId});

  /// `PATCH /v1/tournament/:tournamentId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> updateTournament({
    required String tournamentId,
    required UpdateTournamentReq params,
  });

  /// `DELETE /v1/tournament/:tournamentId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTournament({
    required String tournamentId,
  });

  /// `POST /v1/tournament/:tournamentId/teams` — owner-only, team must
  /// already belong to the tournament's own organization.
  Future<Either<CricketResponse<void>, CricketFailure>> enrollTeam({
    required String tournamentId,
    required EnrollTournamentTeamReq? params,
  });

  /// `DELETE /v1/tournament/:tournamentId/teams/:teamId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> removeTeam({
    required String tournamentId,
    required String teamId,
  });
}
