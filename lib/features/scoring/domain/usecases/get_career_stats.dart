import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetCareerStatsParams {
  final String playerId;

  GetCareerStatsParams({required this.playerId});
}

class GetCareerStatsUseCase
    implements
        UseCase<
          Either<CricketResponse<CareerStatsRes>, CricketFailure>,
          GetCareerStatsParams
        > {
  final MatchRepository matchRepository;

  GetCareerStatsUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<CareerStatsRes>, CricketFailure>> call({
    GetCareerStatsParams? params,
  }) {
    return matchRepository.getCareerStats(playerId: params!.playerId);
  }
}
