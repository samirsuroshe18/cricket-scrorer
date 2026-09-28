import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_playing_xi_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_squad_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/squad_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';

class SquadRepositoryImpl extends SquadRepository {
  final MatchApiService matchApiService;

  SquadRepositoryImpl({required this.matchApiService});

  @override
  Future<Either<CricketResponse<SquadRes>, CricketFailure>> saveSquad({
    required String matchId,
    required SaveSquadReq params,
  }) async {
    final Either<ApiResponseModel, CricketFailure> response =
        await matchApiService.saveSquad(matchId: matchId, params: params);
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: SquadRes.fromJson(
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
  Future<Either<CricketResponse<MatchSquadRes>, CricketFailure>> getMatchSquad({
    required String matchId,
  }) async => _parse(
    await matchApiService.getMatchSquad(matchId: matchId),
    MatchSquadRes.fromJson,
  );

  @override
  Future<Either<CricketResponse<SquadSideRes>, CricketFailure>> savePlayingXi({
    required String matchId,
    required SavePlayingXiReq params,
  }) async => _parse(
    await matchApiService.savePlayingXi(matchId: matchId, params: params),
    SquadSideRes.fromJson,
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
