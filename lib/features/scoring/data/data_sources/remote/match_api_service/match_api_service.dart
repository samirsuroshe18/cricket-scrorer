import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_match_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_player_req.dart';

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

  Future<Either<ApiResponseModel, CricketFailure>> abandonMatch({
    required String matchId,
  }) async {
    return await apiClient.post(endpoint: matchEndpoint.abandon(matchId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> deleteMatch({
    required String matchId,
  }) async {
    return await apiClient.delete(endpoint: matchEndpoint.delete(matchId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> getMatchHistory({
    required int page,
    required int limit,
  }) async {
    return await apiClient.get(
      endpoint: matchEndpoint.history,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  /// `GET /v1/team` — the caller's own teams.
  Future<Either<ApiResponseModel, CricketFailure>> getMyTeams() async {
    return await apiClient.get(endpoint: matchEndpoint.myTeams);
  }

  /// `GET /v1/team/:teamId` — display name plus roster. `verifyJwt` plus a
  /// `createdBy` ownership check server-side, same shape as [getScorecard].
  Future<Either<ApiResponseModel, CricketFailure>> getTeamProfile({
    required String teamId,
  }) async {
    return await apiClient.get(endpoint: matchEndpoint.teamProfile(teamId));
  }

  /// `GET /v1/team/:teamId/matches` — byte-for-byte the same shape as
  /// [getMatchHistory], scoped to one team instead of the caller.
  Future<Either<ApiResponseModel, CricketFailure>> getTeamMatches({
    required String teamId,
    required int page,
    required int limit,
  }) async {
    return await apiClient.get(
      endpoint: matchEndpoint.teamMatches(teamId),
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> updateTeamOrganization({
    required String teamId,
    required String? organizationId,
  }) async {
    return await apiClient.patch(
      endpoint: matchEndpoint.updateTeamOrganization(teamId),
      data: {'organizationId': organizationId},
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

  Future<Either<ApiResponseModel, CricketFailure>> sync({
    required String matchId,
    required SyncReq? params,
  }) async {
    return await apiClient.post(
      endpoint: matchEndpoint.sync(matchId),
      data: params?.toJson(),
    );
  }

  /// verifyJwt, plus a createdBy ownership check server-side — this is the
  /// scorer's own screen, not the spectator's, so unlike [getPublicMatch] the
  /// token is expected to be attached.
  Future<Either<ApiResponseModel, CricketFailure>> getScorecard({
    required String matchId,
  }) async {
    return await apiClient.get(endpoint: matchEndpoint.scorecard(matchId));
  }

  /// verifyJwt, plus a createdBy ownership check server-side, same shape as
  /// [getScorecard] — a Player belongs to the scorer who created it.
  Future<Either<ApiResponseModel, CricketFailure>> getCareerStats({
    required String playerId,
  }) async {
    return await apiClient.get(endpoint: matchEndpoint.careerStats(playerId));
  }

  /// Same ownership shape as [getCareerStats].
  Future<Either<ApiResponseModel, CricketFailure>> updatePlayer({
    required String playerId,
    required UpdatePlayerReq params,
  }) async {
    return await apiClient.patch(
      endpoint: matchEndpoint.playerProfile(playerId),
      data: params.toJson(),
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

  Future<Either<ApiResponseModel, CricketFailure>> getScorerCandidates({
    required String matchId,
  }) async {
    return await apiClient.get(
      endpoint: matchEndpoint.scorerCandidates(matchId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> assignScorer({
    required String matchId,
    required String? scorerId,
  }) async {
    return await apiClient.patch(
      endpoint: matchEndpoint.assignScorer(matchId),
      data: {'scorerId': scorerId},
    );
  }
}
