import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';

class TeamRepositoryImpl extends TeamRepository {
  final MatchApiService matchApiService;

  TeamRepositoryImpl({required this.matchApiService});

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> createTeam({
    required CreateTeamReq params,
  }) async {
    final Either<ApiResponseModel, CricketFailure> response =
        await matchApiService.createTeam(params: params);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: CreatedTeamRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> updateTeam({
    required String teamId,
    required CreateTeamReq params,
  }) async {
    final Either<ApiResponseModel, CricketFailure> response =
        await matchApiService.updateTeam(teamId: teamId, params: params);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: CreatedTeamRes.fromJson(
            response.result.data as Map<String, dynamic>,
          ),
          message: response.result.message,
        ),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTeam({
    required String teamId,
  }) async {
    final response = await matchApiService.deleteTeam(teamId: teamId);
    if (response.isResult) {
      return Either.result(
        CricketResponse(data: null, message: response.result.message),
      );
    } else {
      return Either.fallback(response.fallback);
    }
  }
}
