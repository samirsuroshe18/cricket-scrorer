import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_report_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetAuctionHistoryParams {
  final String tournamentId;
  GetAuctionHistoryParams({required this.tournamentId});
}

class GetAuctionHistoryUseCase
    implements UseCase<Either<CricketResponse<AuctionHistoryRes>, CricketFailure>, GetAuctionHistoryParams> {
  final TournamentRepository tournamentRepository;
  GetAuctionHistoryUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionHistoryRes>, CricketFailure>> call({
    GetAuctionHistoryParams? params,
  }) {
    return tournamentRepository.getAuctionHistory(tournamentId: params!.tournamentId);
  }
}
