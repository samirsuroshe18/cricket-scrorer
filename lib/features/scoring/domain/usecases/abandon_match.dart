import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/abandon_match_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class AbandonMatchUseCase
    implements
        UseCase<
          Either<CricketResponse<AbandonMatchRes>, CricketFailure>,
          String
        > {
  final MatchRepository matchRepository;

  AbandonMatchUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<AbandonMatchRes>, CricketFailure>> call({
    String? params,
  }) {
    return matchRepository.abandonMatch(matchId: params!);
  }
}
