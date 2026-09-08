import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/register_pool_player_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class RegisterPoolPlayerParams {
  final String tournamentId;
  final String? playerName;
  final String? playerId;
  final int basePrice;

  RegisterPoolPlayerParams({
    required this.tournamentId,
    this.playerName,
    this.playerId,
    required this.basePrice,
  });
}

class RegisterPoolPlayerUseCase
    implements
        UseCase<Either<CricketResponse<PoolEntryRes>, CricketFailure>,
            RegisterPoolPlayerParams> {
  final TournamentRepository tournamentRepository;

  RegisterPoolPlayerUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<PoolEntryRes>, CricketFailure>> call({
    RegisterPoolPlayerParams? params,
  }) {
    return tournamentRepository.registerPoolPlayer(
      tournamentId: params!.tournamentId,
      params: RegisterPoolPlayerReq(
        playerName: params.playerName,
        playerId: params.playerId,
        basePrice: params.basePrice,
      ),
    );
  }
}
