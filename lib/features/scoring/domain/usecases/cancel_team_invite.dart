import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class CancelTeamInviteParams {
  final String teamId;
  final String inviteId;

  CancelTeamInviteParams({required this.teamId, required this.inviteId});
}

class CancelTeamInviteUseCase
    implements
        UseCase<
          Either<CricketResponse<void>, CricketFailure>,
          CancelTeamInviteParams
        > {
  final PlayerInviteRepository playerInviteRepository;

  CancelTeamInviteUseCase({required this.playerInviteRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    CancelTeamInviteParams? params,
  }) {
    return playerInviteRepository.cancelTeamInvite(
      teamId: params!.teamId,
      inviteId: params.inviteId,
    );
  }
}
