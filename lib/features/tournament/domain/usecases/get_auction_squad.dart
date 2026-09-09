import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_report_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetAuctionSquadParams {
  final String tournamentId;
  GetAuctionSquadParams({required this.tournamentId});
}

class GetAuctionSquadUseCase
    implements UseCase<Either<CricketResponse<AuctionSquadRes>, CricketFailure>, GetAuctionSquadParams> {
  final TournamentRepository tournamentRepository;
  GetAuctionSquadUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionSquadRes>, CricketFailure>> call({
    GetAuctionSquadParams? params,
  }) {
    return tournamentRepository.getAuctionSquad(tournamentId: params!.tournamentId);
  }
}
