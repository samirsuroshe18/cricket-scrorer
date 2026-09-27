import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class GetMyPlayersParams {
  final String teamId;
  final String? q;
  final int page;
  final int limit;

  GetMyPlayersParams({
    required this.teamId,
    this.q,
    this.page = 1,
    this.limit = 20,
  });
}

class GetMyPlayersUseCase
    implements
        UseCase<
          Either<CricketResponse<MyPlayersRes>, CricketFailure>,
          GetMyPlayersParams
        > {
  final PlayerInviteRepository playerInviteRepository;

  GetMyPlayersUseCase({required this.playerInviteRepository});

  @override
  Future<Either<CricketResponse<MyPlayersRes>, CricketFailure>> call({
    GetMyPlayersParams? params,
  }) {
    return playerInviteRepository.getMyPlayers(
      teamId: params!.teamId,
      q: params.q,
      page: params.page,
      limit: params.limit,
    );
  }
}
