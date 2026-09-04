import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetTeamMatchesParams {
  final String teamId;
  final int page;
  final int limit;

  const GetTeamMatchesParams({
    required this.teamId,
    this.page = 1,
    this.limit = 20,
  });
}

class GetTeamMatchesUseCase
    implements
        UseCase<
          Either<CricketResponse<MatchHistoryRes>, CricketFailure>,
          GetTeamMatchesParams
        > {
  final MatchRepository matchRepository;

  GetTeamMatchesUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetTeamMatchesParams? params,
  }) {
    final resolved = params!;
    return matchRepository.getTeamMatches(
      teamId: resolved.teamId,
      page: resolved.page,
      limit: resolved.limit,
    );
  }
}
