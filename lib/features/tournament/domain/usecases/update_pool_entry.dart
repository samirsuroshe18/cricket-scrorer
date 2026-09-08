import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_pool_entry_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class UpdatePoolEntryParams {
  final String tournamentId;
  final String playerId;
  final int basePrice;

  UpdatePoolEntryParams({
    required this.tournamentId,
    required this.playerId,
    required this.basePrice,
  });
}

class UpdatePoolEntryUseCase
    implements
        UseCase<Either<CricketResponse<PoolEntryRes>, CricketFailure>,
            UpdatePoolEntryParams> {
  final TournamentRepository tournamentRepository;

  UpdatePoolEntryUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<PoolEntryRes>, CricketFailure>> call({
    UpdatePoolEntryParams? params,
  }) {
    return tournamentRepository.updatePoolEntry(
      tournamentId: params!.tournamentId,
      playerId: params.playerId,
      params: UpdatePoolEntryReq(basePrice: params.basePrice),
    );
  }
}
