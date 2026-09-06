import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/leaderboard_row_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetLeaderboardsParams {
  final String tournamentId;

  GetLeaderboardsParams({required this.tournamentId});
}

class GetLeaderboardsUseCase
    implements
        UseCase<Either<CricketResponse<TournamentLeaderboardsRes>, CricketFailure>,
            GetLeaderboardsParams> {
  final TournamentRepository tournamentRepository;

  GetLeaderboardsUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<TournamentLeaderboardsRes>, CricketFailure>> call({
    GetLeaderboardsParams? params,
  }) {
    return tournamentRepository.getLeaderboards(tournamentId: params!.tournamentId);
  }
}
