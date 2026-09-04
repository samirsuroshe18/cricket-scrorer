import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetMyTeamsUseCase
    implements
        UseCase<Either<CricketResponse<MyTeamsRes>, CricketFailure>, void> {
  final MatchRepository matchRepository;

  GetMyTeamsUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) {
    return matchRepository.getMyTeams();
  }
}
