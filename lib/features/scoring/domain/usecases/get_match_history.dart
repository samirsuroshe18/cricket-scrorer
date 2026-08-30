import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetMatchHistoryParams {
  final int page;
  final int limit;

  const GetMatchHistoryParams({this.page = 1, this.limit = 20});
}

class GetMatchHistoryUseCase
    implements
        UseCase<
          Either<CricketResponse<MatchHistoryRes>, CricketFailure>,
          GetMatchHistoryParams
        > {
  final MatchRepository matchRepository;

  GetMatchHistoryUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>> call({
    GetMatchHistoryParams? params,
  }) {
    final resolved = params ?? const GetMatchHistoryParams();
    return matchRepository.getMatchHistory(
      page: resolved.page,
      limit: resolved.limit,
    );
  }
}
