import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
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
}
