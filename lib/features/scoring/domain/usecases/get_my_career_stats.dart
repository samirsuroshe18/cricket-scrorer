import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetMyCareerStatsUseCase
    implements
        UseCase<
          Either<CricketResponse<MyCareerStatsRes>, CricketFailure>,
          void
        > {
  final MatchRepository matchRepository;

  GetMyCareerStatsUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<MyCareerStatsRes>, CricketFailure>> call({
    void params,
  }) {
    return matchRepository.getMyCareerStats();
  }
}
