import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';

class GetMatchSquadParams {
  final String matchId;

  GetMatchSquadParams({required this.matchId});
}

class GetMatchSquadUseCase
    implements
        UseCase<
          Either<CricketResponse<MatchSquadRes>, CricketFailure>,
          GetMatchSquadParams
        > {
  final SquadRepository squadRepository;

  GetMatchSquadUseCase({required this.squadRepository});

  @override
  Future<Either<CricketResponse<MatchSquadRes>, CricketFailure>> call({
    GetMatchSquadParams? params,
  }) {
    return squadRepository.getMatchSquad(matchId: params!.matchId);
  }
}
