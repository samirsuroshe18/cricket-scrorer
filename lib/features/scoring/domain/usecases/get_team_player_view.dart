import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_player_view_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_player_view_repository.dart';

class GetTeamPlayerViewParams {
  final String teamId;

  const GetTeamPlayerViewParams({required this.teamId});
}

class GetTeamPlayerViewUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamPlayerViewRes>, CricketFailure>,
          GetTeamPlayerViewParams
        > {
  final TeamPlayerViewRepository teamPlayerViewRepository;

  GetTeamPlayerViewUseCase({required this.teamPlayerViewRepository});

  @override
  Future<Either<CricketResponse<TeamPlayerViewRes>, CricketFailure>> call({
    GetTeamPlayerViewParams? params,
  }) {
    final resolved = params!;
    return teamPlayerViewRepository.getTeamPlayerView(teamId: resolved.teamId);
  }
}
