import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class StartAuctionParams {
  final String tournamentId;
  StartAuctionParams({required this.tournamentId});
}

class StartAuctionUseCase
    implements UseCase<Either<CricketResponse<AuctionStartRes>, CricketFailure>, StartAuctionParams> {
  final TournamentRepository tournamentRepository;
  StartAuctionUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionStartRes>, CricketFailure>> call({
    StartAuctionParams? params,
  }) {
    return tournamentRepository.startAuction(tournamentId: params!.tournamentId);
  }
}
