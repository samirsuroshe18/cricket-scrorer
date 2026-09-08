import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_setup_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class GetAuctionSetupParams {
  final String tournamentId;

  GetAuctionSetupParams({required this.tournamentId});
}

class GetAuctionSetupUseCase
    implements
        UseCase<Either<CricketResponse<AuctionSetupRes>, CricketFailure>,
            GetAuctionSetupParams> {
  final TournamentRepository tournamentRepository;

  GetAuctionSetupUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionSetupRes>, CricketFailure>> call({
    GetAuctionSetupParams? params,
  }) {
    return tournamentRepository.getAuctionSetup(tournamentId: params!.tournamentId);
  }
}
