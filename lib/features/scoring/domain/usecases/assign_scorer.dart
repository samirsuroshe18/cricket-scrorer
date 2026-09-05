import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/assign_scorer_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class AssignScorerParams {
  final String matchId;
  final String? scorerId;

  const AssignScorerParams({required this.matchId, this.scorerId});
}

class AssignScorerUseCase
    implements
        UseCase<
          Either<CricketResponse<AssignScorerRes>, CricketFailure>,
          AssignScorerParams
        > {
  final MatchRepository matchRepository;

  AssignScorerUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<AssignScorerRes>, CricketFailure>> call({
    AssignScorerParams? params,
  }) {
    final resolved = params!;
    return matchRepository.assignScorer(
      matchId: resolved.matchId,
      scorerId: resolved.scorerId,
    );
  }
}
