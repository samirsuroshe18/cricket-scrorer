import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/fixture_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/standings_row_res.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentApiService tournamentApiService;

  TournamentRepositoryImpl({required this.tournamentApiService});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> createTournament({
    required String orgId,
    required CreateTournamentReq? params,
  }) async {
    final response = await tournamentApiService.createTournament(
      orgId: orgId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>>
  getTournament({required String tournamentId}) async {
    final response = await tournamentApiService.getTournament(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: TournamentDetailRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> updateTournament({
    required String tournamentId,
    required UpdateTournamentReq params,
  }) async {
    final response = await tournamentApiService.updateTournament(
      tournamentId: tournamentId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTournament({
    required String tournamentId,
  }) async {
    final response = await tournamentApiService.deleteTournament(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> enrollTeam({
    required String tournamentId,
    required EnrollTournamentTeamReq? params,
  }) async {
    final response = await tournamentApiService.enrollTeam(
      tournamentId: tournamentId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> removeTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    final response = await tournamentApiService.removeTeam(
      tournamentId: tournamentId,
      teamId: teamId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> generateFixtures({
    required String tournamentId,
  }) async {
    final response = await tournamentApiService.generateFixtures(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<List<FixtureRes>>, CricketFailure>>
  getFixtures({required String tournamentId}) async {
    final response = await tournamentApiService.getFixtures(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      final data = response.result.data as Map<String, dynamic>;
      final fixturesJson = data['fixtures'] as List<dynamic>;
      return Either.result(
        CricketResponse(
          data: fixturesJson
              .map((json) => FixtureRes.fromJson(json as Map<String, dynamic>))
              .toList(),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>>
  startFixtureMatch({
    required String tournamentId,
    required String fixtureId,
    required StartFixtureMatchReq params,
  }) async {
    final response = await tournamentApiService.startFixtureMatch(
      tournamentId: tournamentId,
      fixtureId: fixtureId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: CreateMatchRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> resolveFixture({
    required String tournamentId,
    required String fixtureId,
    required ResolveFixtureReq params,
  }) async {
    final response = await tournamentApiService.resolveFixture(
      tournamentId: tournamentId,
      fixtureId: fixtureId,
      params: params,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<List<StandingsRowRes>>, CricketFailure>>
  getStandings({required String tournamentId}) async {
    final response = await tournamentApiService.getStandings(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      final data = response.result.data as Map<String, dynamic>;
      final standingsJson = data['standings'] as List<dynamic>;
      return Either.result(
        CricketResponse(
          data: standingsJson
              .map((json) => StandingsRowRes.fromJson(json as Map<String, dynamic>))
              .toList(),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<TournamentLeaderboardsRes>, CricketFailure>>
  getLeaderboards({required String tournamentId}) async {
    final response = await tournamentApiService.getLeaderboards(
      tournamentId: tournamentId,
    );
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: TournamentLeaderboardsRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }
}
