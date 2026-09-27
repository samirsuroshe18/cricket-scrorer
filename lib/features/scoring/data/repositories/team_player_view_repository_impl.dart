import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/playing_for_teams_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_player_view_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_player_view_repository.dart';

class TeamPlayerViewRepositoryImpl extends TeamPlayerViewRepository {
  final MatchApiService matchApiService;

  TeamPlayerViewRepositoryImpl({required this.matchApiService});

  @override
  Future<Either<CricketResponse<PlayingForTeamsRes>, CricketFailure>>
  getPlayingForTeams({required int page, required int limit}) async => _parse(
    await matchApiService.getPlayingForTeams(page: page, limit: limit),
    PlayingForTeamsRes.fromJson,
  );

  @override
  Future<Either<CricketResponse<TeamPlayerViewRes>, CricketFailure>>
  getTeamPlayerView({required String teamId}) async => _parse(
    await matchApiService.getTeamPlayerView(teamId: teamId),
    TeamPlayerViewRes.fromJson,
  );

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamPlayerMatches({
    required String teamId,
    required int page,
    required int limit,
    String status = 'all',
  }) async => _parse(
    await matchApiService.getTeamPlayerMatches(
      teamId: teamId,
      page: page,
      limit: limit,
      status: status,
    ),
    MatchHistoryRes.fromJson,
  );

  Either<CricketResponse<T>, CricketFailure> _parse<T>(
    Either<ApiResponseModel, CricketFailure> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: fromJson(response.result.data as Map<String, dynamic>),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }
}
