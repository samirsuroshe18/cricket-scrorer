import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_socket_service/match_socket_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class MatchRepositoryImpl extends MatchRepository {
  final MatchApiService matchApiService;
  final MatchSocketService matchSocketService;

  MatchRepositoryImpl({
    required this.matchApiService,
    required this.matchSocketService,
  });

  @override
  Future<Either<CricketResponse<CreateMatchRes>, CricketFailure>> createMatch({
    required CreateMatchReq? createMatchReq,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .createMatch(params: createMatchReq);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: CreateMatchRes.fromJson(
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
  Future<Either<CricketResponse<ScoreBallRes>, CricketFailure>> scoreBall({
    required String matchId,
    required ScoreBallReq? scoreBallReq,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .scoreBall(matchId: matchId, params: scoreBallReq);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: ScoreBallRes.fromJson(
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
  Stream<Either<LiveScoreRes, CricketFailure>> watchScoreUpdates({
    required String matchId,
  }) {
    return matchSocketService.watchScore(matchId);
  }
}
