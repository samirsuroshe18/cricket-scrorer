import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class UpdateTournamentParams {
  final String tournamentId;
  final UpdateTournamentReq req;

  UpdateTournamentParams({required this.tournamentId, required this.req});
}

class UpdateTournamentUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>, UpdateTournamentParams> {
  final TournamentRepository tournamentRepository;

  UpdateTournamentUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    UpdateTournamentParams? params,
  }) {
    return tournamentRepository.updateTournament(
      tournamentId: params!.tournamentId,
      params: params.req,
    );
  }
}
