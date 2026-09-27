import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';

class UpdateTeamPlayerParams {
  final String teamId;
  final String playerId;
  final UpdateTeamPlayerReq req;

  UpdateTeamPlayerParams({
    required this.teamId,
    required this.playerId,
    required this.req,
  });
}

class UpdateTeamPlayerUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamRosterPlayer>, CricketFailure>,
          UpdateTeamPlayerParams
        > {
  final TeamRepository teamRepository;

  UpdateTeamPlayerUseCase({required this.teamRepository});

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> call({
    UpdateTeamPlayerParams? params,
  }) {
    return teamRepository.updatePlayer(
      teamId: params!.teamId,
      playerId: params.playerId,
      params: params.req,
    );
  }
}
