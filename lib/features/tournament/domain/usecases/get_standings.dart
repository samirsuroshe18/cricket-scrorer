import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/standings_row_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetStandingsParams {
  final String tournamentId;

  GetStandingsParams({required this.tournamentId});
}

class GetStandingsUseCase
    implements
        UseCase<Either<CricketResponse<List<StandingsRowRes>>, CricketFailure>,
            GetStandingsParams> {
  final TournamentRepository tournamentRepository;

  GetStandingsUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<List<StandingsRowRes>>, CricketFailure>> call({
    GetStandingsParams? params,
  }) {
    return tournamentRepository.getStandings(tournamentId: params!.tournamentId);
  }
}
