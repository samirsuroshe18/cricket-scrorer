import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/pool_entry_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetPoolParams {
  final String tournamentId;

  GetPoolParams({required this.tournamentId});
}

class GetPoolUseCase
    implements
        UseCase<Either<CricketResponse<List<PoolEntryRes>>, CricketFailure>,
            GetPoolParams> {
  final TournamentRepository tournamentRepository;

  GetPoolUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<List<PoolEntryRes>>, CricketFailure>> call({
    GetPoolParams? params,
  }) {
    return tournamentRepository.getPool(tournamentId: params!.tournamentId);
  }
}
