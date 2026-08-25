import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';

class MatchApiService {
  final ApiClient apiClient;
  final MatchEndpoint matchEndpoint;

  MatchApiService({required this.apiClient, required this.matchEndpoint});

  Future<Either<ApiResponseModel, CricketFailure>> createMatch({
    required CreateMatchReq? params,
  }) async {
    return await apiClient.post(
      endpoint: matchEndpoint.createMatch,
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> startInnings({
    required String matchId,
    required StartInningsReq? params,
  }) async {
    return await apiClient.post(
      endpoint: matchEndpoint.startInnings(matchId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> selectBowler({
    required String matchId,
    required SelectBowlerReq? params,
  }) async {
    return await apiClient.post(
      endpoint: matchEndpoint.selectBowler(matchId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> scoreBall({
    required String matchId,
    required ScoreBallReq? params,
  }) async {
    return await apiClient.post(
      endpoint: matchEndpoint.scoreBall(matchId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> undoBall({
    required String matchId,
    required UndoBallReq? params,
  }) async {
    return await apiClient.post(
      endpoint: matchEndpoint.undoBall(matchId),
      data: params?.toJson(),
    );
  }

  /// No token is attached deliberately — not because one is stripped, but
  /// because [ApiClient] only adds an `Authorization` header when
  /// [SecureStorageService] actually holds one, and a spectator session
  /// never signs in. Calling this from an authenticated session (e.g. the
  /// scorer previewing their own share link) works identically; the server
  /// route carries no `verifyJwt` either way.
  Future<Either<ApiResponseModel, CricketFailure>> getPublicMatch({
    required String code,
  }) async {
    return await apiClient.get(endpoint: matchEndpoint.publicMatch(code));
  }
}
