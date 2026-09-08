import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class PauseAuctionParams {
  final String tournamentId;
  PauseAuctionParams({required this.tournamentId});
}

class PauseAuctionUseCase
    implements UseCase<Either<CricketResponse<AuctionPauseResumeRes>, CricketFailure>, PauseAuctionParams> {
  final TournamentRepository tournamentRepository;
  PauseAuctionUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionPauseResumeRes>, CricketFailure>> call({
    PauseAuctionParams? params,
  }) {
    return tournamentRepository.pauseAuction(tournamentId: params!.tournamentId);
  }
}
