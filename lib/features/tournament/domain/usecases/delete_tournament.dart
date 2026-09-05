import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class DeleteTournamentParams {
  final String tournamentId;

  DeleteTournamentParams({required this.tournamentId});
}

class DeleteTournamentUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>, DeleteTournamentParams> {
  final TournamentRepository tournamentRepository;

  DeleteTournamentUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    DeleteTournamentParams? params,
  }) {
    return tournamentRepository.deleteTournament(tournamentId: params!.tournamentId);
  }
}
