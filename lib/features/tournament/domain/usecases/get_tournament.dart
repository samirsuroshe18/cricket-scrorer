import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/tournament_detail_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetTournamentParams {
  final String tournamentId;

  GetTournamentParams({required this.tournamentId});
}

class GetTournamentUseCase
    implements
        UseCase<Either<CricketResponse<TournamentDetailRes>, CricketFailure>,
            GetTournamentParams> {
  final TournamentRepository tournamentRepository;

  GetTournamentUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<TournamentDetailRes>, CricketFailure>> call({
    GetTournamentParams? params,
  }) {
    return tournamentRepository.getTournament(tournamentId: params!.tournamentId);
  }
}
