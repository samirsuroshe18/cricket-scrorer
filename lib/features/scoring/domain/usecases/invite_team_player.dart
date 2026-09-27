import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class InviteTeamPlayerParams {
  final String teamId;
  final String userId;

  InviteTeamPlayerParams({required this.teamId, required this.userId});
}

class InviteTeamPlayerUseCase
    implements
        UseCase<
          Either<CricketResponse<TeamInviteRes>, CricketFailure>,
          InviteTeamPlayerParams
        > {
  final PlayerInviteRepository playerInviteRepository;

  InviteTeamPlayerUseCase({required this.playerInviteRepository});

  @override
  Future<Either<CricketResponse<TeamInviteRes>, CricketFailure>> call({
    InviteTeamPlayerParams? params,
  }) {
    return playerInviteRepository.inviteTeamPlayer(
      teamId: params!.teamId,
      userId: params.userId,
    );
  }
}
