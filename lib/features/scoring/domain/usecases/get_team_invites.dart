import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class GetTeamInvitesParams {
  final String teamId;

  GetTeamInvitesParams({required this.teamId});
}

class GetTeamInvitesUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamInvitesRes>, CricketFailure>,
          GetTeamInvitesParams
        > {
  final PlayerInviteRepository playerInviteRepository;

  GetTeamInvitesUseCase({required this.playerInviteRepository});

  @override
  Future<Either<CricketResponse<TeamInvitesRes>, CricketFailure>> call({
    GetTeamInvitesParams? params,
  }) {
    return playerInviteRepository.getTeamInvites(teamId: params!.teamId);
  }
}
