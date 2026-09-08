import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/usecase/usecase.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_auction_setup_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/response/auction_setup_res.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';

class SetAuctionSetupParams {
  final String tournamentId;
  final int? minSquadSize;
  final int? maxSquadSize;
  final Map<String, int>? categoryCaps;
  final List<AuctionOwnerInput>? owners;

  SetAuctionSetupParams({
    required this.tournamentId,
    this.minSquadSize,
    this.maxSquadSize,
    this.categoryCaps,
    this.owners,
  });
}

class SetAuctionSetupUseCase
    implements
        UseCase<Either<CricketResponse<AuctionSetupRes>, CricketFailure>,
            SetAuctionSetupParams> {
  final TournamentRepository tournamentRepository;

  SetAuctionSetupUseCase({required this.tournamentRepository});

  @override
  Future<Either<CricketResponse<AuctionSetupRes>, CricketFailure>> call({
    SetAuctionSetupParams? params,
  }) {
    return tournamentRepository.setAuctionSetup(
      tournamentId: params!.tournamentId,
      params: UpdateAuctionSetupReq(
        minSquadSize: params.minSquadSize,
        maxSquadSize: params.maxSquadSize,
        categoryCaps: params.categoryCaps,
        owners: params.owners,
      ),
    );
  }
}
