import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_state_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class NextAuctionLotParams {
  final String tournamentId;
  NextAuctionLotParams({required this.tournamentId});
}

class NextAuctionLotUseCase
    implements UseCase<Either<CricketResponse<AuctionNextLotRes>, CricketFailure>, NextAuctionLotParams> {
  final TournamentRepository tournamentRepository;
  NextAuctionLotUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionNextLotRes>, CricketFailure>> call({
    NextAuctionLotParams? params,
  }) {
    return tournamentRepository.nextAuctionLot(tournamentId: params!.tournamentId);
  }
}
