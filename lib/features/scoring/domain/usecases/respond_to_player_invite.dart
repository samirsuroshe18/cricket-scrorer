import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_invite_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class RespondToPlayerInviteParams {
  final String inviteId;
  final bool accept;

  RespondToPlayerInviteParams({required this.inviteId, required this.accept});
}

class RespondToPlayerInviteUseCase
    implements
        UseCase<
          Either<CricketResponse<PlayerInviteAnswerRes>, CricketFailure>,
          RespondToPlayerInviteParams
        > {
  final PlayerInviteRepository playerInviteRepository;

  RespondToPlayerInviteUseCase({required this.playerInviteRepository});

  @override
  Future<Either<CricketResponse<PlayerInviteAnswerRes>, CricketFailure>> call({
    RespondToPlayerInviteParams? params,
  }) {
    return playerInviteRepository.respondToPlayerInvite(
      inviteId: params!.inviteId,
      accept: params.accept,
    );
  }
}
