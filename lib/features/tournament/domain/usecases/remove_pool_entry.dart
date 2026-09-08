import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class RemovePoolEntryParams {
  final String tournamentId;
  final String playerId;

  RemovePoolEntryParams({required this.tournamentId, required this.playerId});
}

class RemovePoolEntryUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            RemovePoolEntryParams> {
  final TournamentRepository tournamentRepository;

  RemovePoolEntryUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemovePoolEntryParams? params,
  }) {
    return tournamentRepository.removePoolEntry(
      tournamentId: params!.tournamentId,
      playerId: params.playerId,
    );
  }
}
