import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetPublicMatchParams {
  final String code;

  GetPublicMatchParams({required this.code});
}

/// The only usecase the spectator binding constructs. [ScoreBallUseCase],
/// [StartInningsUseCase], [SelectBowlerUseCase] and [UndoBallUseCase] are
/// never injected into that binding — not hidden behind a permission check,
/// simply never built — so there is no method a spectator screen could call
/// to score anything even by mistake.
class GetPublicMatchUseCase
    implements
        UseCase<
          Either<CricketResponse<PublicMatchRes>, CricketFailure>,
          GetPublicMatchParams
        > {
  final MatchRepository matchRepository;

  GetPublicMatchUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<PublicMatchRes>, CricketFailure>> call({
    GetPublicMatchParams? params,
  }) {
    return matchRepository.getPublicMatch(code: params!.code);
  }
}
