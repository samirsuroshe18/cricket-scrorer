import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetScorecardParams {
  final String matchId;

  GetScorecardParams({required this.matchId});
}

/// The only usecase [ResultBinding] constructs — same "no scoring capability
/// reachable, not hidden but never built" guarantee as
/// [GetPublicMatchUseCase]/[SpectatorBinding], even though this screen is
/// authenticated: a result screen has no scoring action to perform either way.
class GetScorecardUseCase
    implements
        UseCase<
          Either<CricketResponse<ScorecardRes>, CricketFailure>,
          GetScorecardParams
        > {
  final MatchRepository matchRepository;

  GetScorecardUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> call({
    GetScorecardParams? params,
  }) {
    return matchRepository.getScorecard(matchId: params!.matchId);
  }
}
