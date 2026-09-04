import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class GetTeamProfileParams {
  final String teamId;

  GetTeamProfileParams({required this.teamId});
}

class GetTeamProfileUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamProfileRes>, CricketFailure>,
          GetTeamProfileParams
        > {
  final MatchRepository matchRepository;

  GetTeamProfileUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<TeamProfileRes>, CricketFailure>> call({
    GetTeamProfileParams? params,
  }) {
    return matchRepository.getTeamProfile(teamId: params!.teamId);
  }
}
