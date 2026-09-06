import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/standings_row_res.dart';
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

  /// `POST /v1/tournament/:tournamentId/fixtures` — owner-only. Generates
  /// the full schedule (round_robin/league) or the next round (knockout).
  Future<Either<CricketResponse<void>, CricketFailure>> generateFixtures({
    required String tournamentId,
  });

  /// `GET /v1/tournament/:tournamentId/fixtures` — any org member.
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>>
  getFixtures({required String tournamentId});

  /// `POST /v1/tournament/:tournamentId/fixtures/:fixtureId/start-match` —
  /// any org member. Returns the same shape `POST /v1/match` does.
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>>
  startFixtureMatch({
    required String tournamentId,
    required String fixtureId,
    required StartFixtureMatchReq params,
  });

  /// `PATCH /v1/tournament/:tournamentId/fixtures/:fixtureId` — owner-only.
  Future<Either<CricketResponse<void>, CricketFailure>> resolveFixture({
    required String tournamentId,
    required String fixtureId,
    required ResolveFixtureReq params,
  });

  /// `GET /v1/tournament/:tournamentId/standings` — any org member.
  /// round_robin/league only; a knockout tournament fails with
  /// `STANDINGS_NOT_APPLICABLE`.
  Future<Either<CricketResponse<List<StandingsRowRes>>, CricketFailure>>
  getStandings({required String tournamentId});
}
