import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_socket_service/match_socket_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/live_score_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/over_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/select_bowler_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/undo_ball_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_complete_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/score_undo_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
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
  Future<Either<CricketResponse<StartInningsRes>, CricketFailure>>
  startInnings({
    required String matchId,
    required StartInningsReq? startInningsReq,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .startInnings(matchId: matchId, params: startInningsReq);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: StartInningsRes.fromJson(
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
  Future<Either<CricketResponse<SelectBowlerRes>, CricketFailure>>
  selectBowler({
    required String matchId,
    required SelectBowlerReq? selectBowlerReq,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .selectBowler(matchId: matchId, params: selectBowlerReq);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: SelectBowlerRes.fromJson(
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
  Future<Either<CricketResponse<UndoBallRes>, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? undoBallReq,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .undoBall(matchId: matchId, params: undoBallReq);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: UndoBallRes.fromJson(
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
  Future<Either<CricketResponse<SyncRes>, CricketFailure>> syncMatch({
    required String matchId,
    required SyncReq? syncReq,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .sync(matchId: matchId, params: syncReq);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: SyncRes.fromJson(
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

  @override
  Stream<Either<OverCompleteRes, CricketFailure>> watchOverComplete({
    required String matchId,
  }) {
    return matchSocketService.watchOverComplete(matchId);
  }

  @override
  Stream<Either<ScoreUndoRes, CricketFailure>> watchScoreUndo({
    required String matchId,
  }) {
    return matchSocketService.watchScoreUndo(matchId);
  }

  @override
  Future<Either<CricketResponse<PublicMatchRes>, CricketFailure>>
  getPublicMatch({required String code}) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .getPublicMatch(code: code);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: PublicMatchRes.fromJson(
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
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  }) async {
    Either<ApiResponseModel, CricketFailure> response = await matchApiService
        .getScorecard(matchId: matchId);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: ScorecardRes.fromJson(
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
  Stream<Either<MatchCompleteRes, CricketFailure>> watchMatchComplete({
    required String matchId,
  }) {
    return matchSocketService.watchMatchComplete(matchId);
  }
}
