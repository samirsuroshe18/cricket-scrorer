import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';

class UpdatePlayerParams {
  final String playerId;
  final UpdatePlayerReq req;

  UpdatePlayerParams({required this.playerId, required this.req});
}

class UpdatePlayerUseCase
    implements
        UseCase<
          Either<CricketResponse<PlayerProfileRes>, CricketFailure>,
          UpdatePlayerParams
        > {
  final MatchRepository matchRepository;

  UpdatePlayerUseCase({required this.matchRepository});

  @override
  Future<Either<CricketResponse<PlayerProfileRes>, CricketFailure>> call({
    UpdatePlayerParams? params,
  }) {
    return matchRepository.updatePlayer(
      playerId: params!.playerId,
      params: params.req,
    );
  }
}
