import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class RemoveTournamentTeamParams {
  final String tournamentId;
  final String teamId;

  RemoveTournamentTeamParams({required this.tournamentId, required this.teamId});
}

class RemoveTournamentTeamUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            RemoveTournamentTeamParams> {
  final TournamentRepository tournamentRepository;

  RemoveTournamentTeamUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    RemoveTournamentTeamParams? params,
  }) {
    return tournamentRepository.removeTeam(
      tournamentId: params!.tournamentId,
      teamId: params.teamId,
    );
  }
}
