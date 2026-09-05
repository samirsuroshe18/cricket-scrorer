import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class EnrollTournamentTeamParams {
  final String tournamentId;
  final String teamId;

  EnrollTournamentTeamParams({required this.tournamentId, required this.teamId});
}

class EnrollTournamentTeamUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>,
            EnrollTournamentTeamParams> {
  final TournamentRepository tournamentRepository;

  EnrollTournamentTeamUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    EnrollTournamentTeamParams? params,
  }) {
    return tournamentRepository.enrollTeam(
      tournamentId: params!.tournamentId,
      params: EnrollTournamentTeamReq(teamId: params.teamId),
    );
  }
}
