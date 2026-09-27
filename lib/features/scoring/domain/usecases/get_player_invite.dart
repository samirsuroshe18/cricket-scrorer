import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_invite_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class GetPlayerInviteParams {
  final String inviteId;

  GetPlayerInviteParams({required this.inviteId});
}

class GetPlayerInviteUseCase
    implements
        UseCase<
          Either<CricketResponse<PlayerInviteRes>, CricketFailure>,
          GetPlayerInviteParams
        > {
  final PlayerInviteRepository playerInviteRepository;

  GetPlayerInviteUseCase({required this.playerInviteRepository});

  @override
  Future<Either<CricketResponse<PlayerInviteRes>, CricketFailure>> call({
    GetPlayerInviteParams? params,
  }) {
    return playerInviteRepository.getPlayerInvite(
      inviteId: params!.inviteId,
    );
  }
}
