import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class ResumeAuctionParams {
  final String tournamentId;
  ResumeAuctionParams({required this.tournamentId});
}

class ResumeAuctionUseCase
    implements UseCase<Either<CricketResponse<AuctionPauseResumeRes>, CricketFailure>, ResumeAuctionParams> {
  final TournamentRepository tournamentRepository;
  ResumeAuctionUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionPauseResumeRes>, CricketFailure>> call({
    ResumeAuctionParams? params,
  }) {
    return tournamentRepository.resumeAuction(tournamentId: params!.tournamentId);
  }
}
