import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class CreateTournamentParams {
  final String orgId;
  final CreateTournamentReq req;

  CreateTournamentParams({required this.orgId, required this.req});
}

class CreateTournamentUseCase
    implements
        UseCase<Either<CricketResponse<void>, CricketFailure>, CreateTournamentParams> {
  final TournamentRepository tournamentRepository;

  CreateTournamentUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    CreateTournamentParams? params,
  }) {
    return tournamentRepository.createTournament(
      orgId: params!.orgId,
      params: params.req,
    );
  }
}
