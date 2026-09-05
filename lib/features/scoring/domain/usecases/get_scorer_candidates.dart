import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorer_candidates_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetScorerCandidatesParams {
  final String matchId;

  const GetScorerCandidatesParams({required this.matchId});
}

class GetScorerCandidatesUseCase
    implements
        UseCase<
          Either<CricketResponse<ScorerCandidatesRes>, CricketFailure>,
          GetScorerCandidatesParams
        > {
  final MatchRepository matchRepository;

  GetScorerCandidatesUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<ScorerCandidatesRes>, CricketFailure>> call({
    GetScorerCandidatesParams? params,
  }) {
    return matchRepository.getScorerCandidates(matchId: params!.matchId);
  }
}
